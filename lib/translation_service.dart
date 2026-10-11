import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

// ── 支援語言 ────────────────────────────────────────────────────
enum AppLang {
  zhCN, zhTW, en, ja, es, fr, de, ar, hi, ko, th, pt, vi, it, la, id, bo,
}

extension AppLangX on AppLang {
  /// 切換器上顯示的短標籤
  String get label => switch (this) {
    AppLang.zhCN => '简中',
    AppLang.zhTW => '繁中',
    AppLang.en   => 'EN',
    AppLang.ja   => 'JP',
    AppLang.es   => 'ES',
    AppLang.fr   => 'FR',
    AppLang.de   => 'DE',
    AppLang.ar   => 'AR',
    AppLang.hi   => 'HI',
    AppLang.ko   => 'KO',
    AppLang.th   => 'TH',
    AppLang.pt   => 'PT',
    AppLang.vi   => 'VI',
    AppLang.it   => 'IT',
    AppLang.la   => 'LA',
    AppLang.id   => 'ID',
    AppLang.bo   => 'BO',
  };

  /// 選單中顯示的語言全名（用該語言自己的文字）
  String get fullName => switch (this) {
    AppLang.zhCN => '简体中文',
    AppLang.zhTW => '繁體中文',
    AppLang.en   => 'English',
    AppLang.ja   => '日本語',
    AppLang.es   => 'Español',
    AppLang.fr   => 'Français',
    AppLang.de   => 'Deutsch',
    AppLang.ar   => 'العربية',
    AppLang.hi   => 'हिन्दी',
    AppLang.ko   => '한국어',
    AppLang.th   => 'ภาษาไทย',
    AppLang.pt   => 'Português',
    AppLang.vi   => 'Tiếng Việt',
    AppLang.it   => 'Italiano',
    AppLang.la   => 'Latina',
    AppLang.id   => 'Bahasa Indonesia',
    AppLang.bo   => 'བོད་ཡིག',
  };

  /// MyMemory 的語言代碼
  String get apiCode => switch (this) {
    AppLang.zhCN => 'zh-CN',
    AppLang.zhTW => 'zh-TW',
    AppLang.en   => 'en',
    AppLang.ja   => 'ja',
    AppLang.es   => 'es',
    AppLang.fr   => 'fr',
    AppLang.de   => 'de',
    AppLang.ar   => 'ar',
    AppLang.hi   => 'hi',
    AppLang.ko   => 'ko',
    AppLang.th   => 'th',
    AppLang.pt   => 'pt',
    AppLang.vi   => 'vi',
    AppLang.it   => 'it',
    AppLang.la   => 'la',
    AppLang.id   => 'id',
    AppLang.bo   => 'bo',
  };

  /// flutter_tts 的語言代碼；拉丁文、藏文沒有一般裝置內建的語音，回傳 null 代表不支援朗讀
  String? get ttsCode => switch (this) {
    AppLang.zhCN => 'zh-CN',
    AppLang.zhTW => 'zh-TW',
    AppLang.en   => 'en-US',
    AppLang.ja   => 'ja-JP',
    AppLang.es   => 'es-ES',
    AppLang.fr   => 'fr-FR',
    AppLang.de   => 'de-DE',
    AppLang.ar   => 'ar-SA',
    AppLang.hi   => 'hi-IN',
    AppLang.ko   => 'ko-KR',
    AppLang.th   => 'th-TH',
    AppLang.pt   => 'pt-BR',
    AppLang.vi   => 'vi-VN',
    AppLang.it   => 'it-IT',
    AppLang.la   => null,
    AppLang.id   => 'id-ID',
    AppLang.bo   => null,
  };

  /// 由右至左書寫
  bool get isRtl => this == AppLang.ar;

  /// 詞與詞之間不使用空白（合併分段譯文時用 '' 而不是 ' '）
  bool get isSpaceless => switch (this) {
    AppLang.zhCN || AppLang.zhTW || AppLang.ja || AppLang.th || AppLang.bo => true,
    _ => false,
  };
}

// ── 全站語言狀態 ────────────────────────────────────────────────
//
// main.dart 用 [TranslationScope] 包住整個 App，讓任何頁面都能透過
// TranslationScope.of(context) 讀取／切換目前的全站語言，不需要每個
// 頁面各自維護一份語言狀態。
class TranslationNotifier extends ValueNotifier<AppLang> {
  TranslationNotifier([AppLang initial = AppLang.zhTW]) : super(initial);
}

class TranslationScope extends InheritedNotifier<TranslationNotifier> {
  const TranslationScope({
    Key? key,
    required TranslationNotifier notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  /// 取得 [TranslationNotifier]，可用來讀取或變更（.value = ...）目前語言。
  /// 預設會註冊監聽，語言變動時呼叫端會自動重建；若只是想在事件callback
  /// 裡取得目前值而不訂閱重建，傳入 listen: false。
  static TranslationNotifier of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<TranslationScope>()
        : context
            .getElementForInheritedWidgetOfExactType<TranslationScope>()
            ?.widget as TranslationScope?;
    assert(scope != null, 'TranslationScope 未包住此 widget 樹');
    return scope!.notifier!;
  }

  /// 直接取得目前語言（語言變動時會觸發呼叫端重建）。
  static AppLang langOf(BuildContext context) => of(context).value;
}

// ── 翻譯失敗 ────────────────────────────────────────────────────
class TranslationException implements Exception {
  TranslationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 免費額度用完。[retryAt] 是預估的恢復時間；在這之前服務不會再打 API，
/// 而是直接丟出這個例外。繼承自 [TranslationException]，既有的 catch
/// (on TranslationException) 不需要修改就能同時接住兩者；若想特別處理
/// 額度用完的情況（例如顯示倒數、隱藏翻譯按鈕），可另外 catch 這個型別。
class TranslationQuotaException extends TranslationException {
  TranslationQuotaException(String message, this.retryAt) : super(message);
  final DateTime retryAt;
}

// ── 翻譯快取（只存成功的結果）──────────────────────────────────
class _TranslationCache {
  static final _cache = <String, String>{};

  static String key(String text, AppLang source, AppLang target) =>
      '${source.name}>${target.name}::$text';

  static String? get(String text, AppLang source, AppLang target) =>
      _cache[key(text, source, target)];

  static void set(String text, AppLang source, AppLang target, String translated) =>
      _cache[key(text, source, target)] = translated;
}

// ── 額度斷路器 ──────────────────────────────────────────────────
//
// MyMemory 額度用完後，接下來每一次請求都只會換來同樣的 429／警告文字，
// 且倒數時間不會因為多打幾次而縮短。第一次收到「額度用完」的回應後，
// 就記住預估的恢復時間，在那之前所有請求直接在本地丟出例外，不再發出
// 任何網路請求——避免每次重建畫面、切換語言、或使用者連續操作時，都對
// 同一份免費額度再打一輪、把 log 洗成一整頁 429。
class _QuotaGate {
  static DateTime? _until;

  /// 目前封鎖到何時；沒有被封鎖時回傳 null（過了時間也視為 null，並自動解除）。
  static DateTime? get until {
    final u = _until;
    if (u == null) return null;
    if (DateTime.now().isAfter(u)) {
      _until = null;
      return null;
    }
    return u;
  }

  /// 收到額度用完的回應時呼叫一次。[detail] 是 MyMemory 回應中的警告文字，
  /// 內含類似「NEXT AVAILABLE IN 23 HOURS 25 MINUTES 22 SECONDS」的敘述，
  /// 解析得到就用它估算恢復時間，解析不到就保守地封鎖 1 小時。
  static DateTime trip(String? detail) {
    var wait = const Duration(hours: 1);
    if (detail != null) {
      final m = RegExp(
        r'(\d+)\s*HOURS?\s*(\d+)\s*MINUTES?\s*(\d+)\s*SECONDS?',
        caseSensitive: false,
      ).firstMatch(detail);
      if (m != null) {
        wait = Duration(
          hours: int.parse(m.group(1)!),
          minutes: int.parse(m.group(2)!),
          seconds: int.parse(m.group(3)!),
        );
      }
    }
    // 多留 1 分鐘緩衝，避免卡在邊界又立刻踩到同一個 429
    final until = DateTime.now().add(wait + const Duration(minutes: 1));
    _until = until;
    return until;
  }
}

// ── 翻譯服務（MyMemory，免金鑰、支援 CORS）─────────────────────
//
// 用法：
//   final out = await TranslationService.translate(
//     text, AppLang.en,
//     source: AppLang.zhTW,                 // 原文語言，預設繁中
//     onProgress: (done, total) { ... },    // 長文分段時回報進度
//   );
//
// 失敗時丟出 [TranslationException]，呼叫端自行決定要顯示原文或提示使用者。
// 額度用完時丟出其子類別 [TranslationQuotaException]，並在預估恢復時間之前
// 不再發出任何請求。
// 失敗結果不會進快取，重試時已翻好的段落會直接命中快取、不再重複耗用額度。
abstract class TranslationService {
  /// MyMemory 匿名額度約 5,000 字元／日；填入有效信箱後（de 參數）可提高到約 50,000 字元／日。
  /// 留空則以匿名方式呼叫。
  static const String contactEmail = '';

  /// 單次請求上限。MyMemory 限制約 500 bytes，中文一字 3 bytes，
  /// 這裡以 UTF-8 位元組數保守切段，不會被截斷。
  static const int _maxBytes = 450;

  /// 同時進行的請求數
  static const int _concurrency = 3;

  static const Duration _timeout = Duration(seconds: 15);

  // 句子切分：「…標點」或最後一段沒有標點的尾巴
  static final _sentenceExp = RegExp(r'[^。！？；!?;]*[。！？；!?;]+|[^。！？；!?;]+');

  /// 同一段文字若已有請求在飛行中，後來者直接掛在同一個 Future 上，
  /// 不重複打 API（例如使用者連按翻譯鈕、或同一段文字同時出現在畫面多處）。
  static final _inflight = <String, Future<String>>{};

  /// 額度用完時的預估恢復時間；目前可正常使用則為 null。
  /// UI 可以用它決定是否要先隱藏翻譯功能、顯示倒數或提示文字。
  static DateTime? get quotaBlockedUntil => _QuotaGate.until;

  static Future<String> translate(
    String text,
    AppLang target, {
    AppLang source = AppLang.zhTW,
    void Function(int done, int total)? onProgress,
  }) async {
    if (target == source || text.trim().isEmpty) return text;

    final cached = _TranslationCache.get(text, source, target);
    if (cached != null) return cached;

    _throwIfBlocked();

    // 逐行處理，保留段落與空行結構；過長的行再依句子切開
    final lines = text.split('\n');
    final pieceLists = <List<String>?>[]; // null = 空行
    final jobs = <String>[];
    for (final line in lines) {
      final t = line.trim();
      if (t.isEmpty) {
        pieceLists.add(null);
        continue;
      }
      final pieces = _splitLine(t);
      pieceLists.add(pieces);
      jobs.addAll(pieces);
    }

    final results = List<String>.filled(jobs.length, '');
    onProgress?.call(0, jobs.length);
    for (var i = 0; i < jobs.length; i += _concurrency) {
      final end = min(i + _concurrency, jobs.length);
      final batch = await Future.wait([
        for (var j = i; j < end; j++) _translatePiece(jobs[j], source, target),
      ]);
      for (var j = 0; j < batch.length; j++) {
        results[i + j] = batch[j];
      }
      onProgress?.call(end, jobs.length);
    }

    // 依原本的行結構組回去
    final sep = target.isSpaceless ? '' : ' ';
    final out = <String>[];
    var k = 0;
    for (final pieces in pieceLists) {
      if (pieces == null) {
        out.add('');
        continue;
      }
      out.add(results.sublist(k, k + pieces.length).join(sep));
      k += pieces.length;
    }

    final translated = out.join('\n');
    _TranslationCache.set(text, source, target, translated);
    return translated;
  }

  // ── 額度封鎖 ────────────────────────────────────────────────
  static void _throwIfBlocked() {
    final until = _QuotaGate.until;
    if (until != null) throw _quotaException(until);
  }

  static TranslationQuotaException _quotaException(DateTime until) {
    final left = until.difference(DateTime.now());
    final hours = left.inHours;
    final mins = left.inMinutes.remainder(60);
    final when = hours > 0 ? '約 $hours 小時 $mins 分鐘' : '約 ${left.inMinutes.clamp(1, 59)} 分鐘';
    return TranslationQuotaException('今日免費翻譯額度已用完，$when後恢復', until);
  }

  // ── 單段翻譯（≤ _maxBytes）──────────────────────────────────
  static Future<String> _translatePiece(String text, AppLang source, AppLang target) {
    final cached = _TranslationCache.get(text, source, target);
    if (cached != null) return Future.value(cached);

    // 額度已被封鎖時，不建立新的 inflight 請求，直接同步丟出例外
    final blockedUntil = _QuotaGate.until;
    if (blockedUntil != null) {
      return Future.error(_quotaException(blockedUntil));
    }

    final key = _TranslationCache.key(text, source, target);
    final running = _inflight[key];
    if (running != null) return running;

    final future = _fetchPiece(text, source, target).whenComplete(() => _inflight.remove(key));
    _inflight[key] = future;
    return future;
  }

  static Future<String> _fetchPiece(String text, AppLang source, AppLang target) async {
    _throwIfBlocked();

    final uri = Uri.https('api.mymemory.translated.net', '/get', {
      'q': text,
      'langpair': '${source.apiCode}|${target.apiCode}',
      if (contactEmail.isNotEmpty) 'de': contactEmail,
    });

    final http.Response res;
    try {
      res = await http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw TranslationException('連線逾時');
    } catch (e) {
      throw TranslationException('網路錯誤：$e');
    }

    // 少數情況 HTTP 層就直接回 429，且 body 不一定是合法 JSON
    if (res.statusCode == 429) {
      throw _quotaException(_QuotaGate.trip(null));
    }
    if (res.statusCode != 200) {
      throw TranslationException('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw TranslationException('回應格式錯誤');
    }

    final rd = data['responseData'];
    final raw = rd is Map ? rd['translatedText'] : null;
    final translated = raw is String ? raw : '';

    final status = int.tryParse('${data['responseStatus']}');
    // 額度用完：responseStatus 為 429，內容通常是
    // "MYMEMORY WARNING: YOU USED ALL AVAILABLE FREE TRANSLATIONS FOR TODAY.
    //  NEXT AVAILABLE IN 23 HOURS 25 MINUTES 22 SECONDS ..."
    if (status == 429 || translated.startsWith('MYMEMORY WARNING')) {
      final detail = '${data['responseDetails'] ?? ''} $translated';
      throw _quotaException(_QuotaGate.trip(detail));
    }
    if (status != 200) {
      throw TranslationException('${data['responseDetails'] ?? '未知錯誤（$status）'}');
    }
    if (translated.trim().isEmpty) {
      throw TranslationException('翻譯結果為空');
    }

    final result = _unescape(translated);
    _TranslationCache.set(text, source, target, result);
    return result;
  }

  // ── 切段 ────────────────────────────────────────────────────
  static int _bytes(String s) => utf8.encode(s).length;

  static List<String> _splitLine(String line) {
    if (_bytes(line) <= _maxBytes) return [line];

    final pieces = <String>[];
    final buf = StringBuffer();
    var bufBytes = 0;

    void flush() {
      if (bufBytes > 0) {
        pieces.add(buf.toString());
        buf.clear();
        bufBytes = 0;
      }
    }

    for (final m in _sentenceExp.allMatches(line)) {
      for (final seg in _hardSplit(m.group(0)!)) {
        final b = _bytes(seg);
        if (bufBytes + b > _maxBytes) flush();
        buf.write(seg);
        bufBytes += b;
      }
    }
    flush();
    return pieces;
  }

  // 單一句子仍超過上限時，按字元硬切
  static Iterable<String> _hardSplit(String s) sync* {
    if (_bytes(s) <= _maxBytes) {
      yield s;
      return;
    }
    final buf = StringBuffer();
    var n = 0;
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      final b = utf8.encode(ch).length;
      if (n + b > _maxBytes) {
        yield buf.toString();
        buf.clear();
        n = 0;
      }
      buf.write(ch);
      n += b;
    }
    if (n > 0) yield buf.toString();
  }

  // MyMemory 偶爾會回傳 HTML 實體
  static String _unescape(String s) => s
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}

// ── 可翻譯文字 widget ───────────────────────────────────────────
//
// 用法（介面比照一般 [Text]）：
//   TranslatableText('你好', style: myStyle, textAlign: TextAlign.center)
//
// 會透過 [TranslationScope] 讀取目前的全站語言：
//   - 語言與原文語言（預設繁中 [AppLang.zhTW]）相同時，直接顯示原文。
//   - 不同時，先照樣顯示原文，同時非同步呼叫 [TranslationService] 翻譯，
//     翻譯完成後才更新畫面；翻譯中或翻譯失敗（含額度用完）都維持顯示
//     原文，不會讓畫面出現空白或例外。
//   - 语言再次切换、或 [text] 內容改變時，會自動重新翻譯。
//
// 注意：這個 widget 需要在 [TranslationScope] 底下使用，才能感知目前
// 的全站語言；若沒有 [TranslationScope]，[TranslationScope.of] 會在
// debug 模式下觸發 assert。
class TranslatableText extends StatefulWidget {
  const TranslatableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.source = AppLang.zhTW,
  });

  /// 原文（預設語言為 [source]，通常是繁體中文）
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// [text] 所使用的原文語言，預設繁中
  final AppLang source;

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  AppLang? _lang;
  String? _translated;

  // 避免舊的非同步翻譯結果，在語言或文字已經切換後才回來把畫面蓋回去
  int _requestId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = TranslationScope.langOf(context);
    if (lang != _lang) {
      _lang = lang;
      _translate(lang);
    }
  }

  @override
  void didUpdateWidget(covariant TranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.source != widget.source) {
      _translated = null;
      if (_lang != null) _translate(_lang!);
    }
  }

  Future<void> _translate(AppLang lang) async {
    if (lang == widget.source || widget.text.trim().isEmpty) {
      if (mounted) setState(() => _translated = null);
      return;
    }
    final id = ++_requestId;
    try {
      final result = await TranslationService.translate(
        widget.text,
        lang,
        source: widget.source,
      );
      if (!mounted || id != _requestId) return;
      setState(() => _translated = result);
    } catch (_) {
      // 翻譯失敗（含額度用完）：維持顯示原文，不中斷畫面
      if (!mounted || id != _requestId) return;
      setState(() => _translated = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translated ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }
}