import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'yingshijuan_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'footer.dart';

// ── 常數 ────────────────────────────────────────────────────────
const _kGold    = Color(0xFFF5C518);
const _kGoldDim = Color(0xFFB8960E);
const _kPageSize = 24;

const _kGoldBorder    = Color(0x59F5C518);
const _kGoldBorderNav = Color(0x73F5C518);
const _kGoldBorderDim = Color(0x26F5C518);
const _kGoldIconDim   = Color(0x40F5C518);
const _kCopyIconColor = Color(0x99B8960E);
const _kDividerColor  = Color(0x33F5C518);
const _kNavShadow  = BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2));
const _kCardShadow = BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4));

const _kCardDeco = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16)), boxShadow: [_kCardShadow]);
const _kCardDecoHi = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16)), border: Border.fromBorderSide(BorderSide(color: _kGold, width: 2)), boxShadow: [_kCardShadow]);
const _kCardPad = EdgeInsets.fromLTRB(18, 20, 14, 16);
const _kSearchDeco = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12)), boxShadow: [_kNavShadow]);

const _kBodyStyle   = TextStyle(fontSize: 13.5, color: _kGoldDim, height: 1.7);
const _kTitleStyle  = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kGold, height: 1.4);
const _kExpandStyle = TextStyle(fontSize: 12, color: _kGold, fontWeight: FontWeight.w600);
const _kDateStyle   = TextStyle(fontSize: 11, color: _kGoldBorder, letterSpacing: 1);
const _kDialogStyle = TextStyle(fontSize: 14, color: _kGoldDim, height: 1.8);

const _kCheckIcon = Icon(Icons.check_rounded, key: ValueKey(true), size: 16, color: _kGold);
const _kArrowIcon = Icon(Icons.keyboard_arrow_down, size: 16, color: _kGold);
const _kCopyIcon  = Icon(Icons.copy_rounded, key: ValueKey(false), size: 16, color: _kCopyIconColor);
const _kDivider   = Divider(color: _kDividerColor, height: 1, thickness: 1);

typedef _Card = ({String title, String? date, String body});

// ── 支援語言 ────────────────────────────────────────────────────
enum AppLang {
  zhCN, zhTW, en, ja, es, fr, de, ar, hi, ko, th, pt, vi, it, la, id, bo,
}

extension AppLangX on AppLang {
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
}

int _gridCols(double w) =>
    w < 480 ? 1 : w < 720 ? 2 : w < 960 ? 3 : w < 1200 ? 4 : w < 1440 ? 5 : 6;

// ── 翻譯快取 ──────────────────────────────────────────────────
class _TranslationCache {
  static final _cache = <String, String>{};

  static String _key(String text, AppLang lang) => '${lang.name}::$text';

  static String? get(String text, AppLang lang) =>
      lang == AppLang.zhCN ? text : _cache[_key(text, lang)];

  static void set(String text, AppLang lang, String translated) =>
      _cache[_key(text, lang)] = translated;
}

// ── 翻譯服務 ──────────────────────────────────────────────────
// ⚠️ 壞掉的原因：_apiKey 一直是佔位字串 'YOUR_GOOGLE_CLOUD_TRANSLATE_API_KEY'，
// 從沒填入真正的金鑰，所以每次呼叫 Google Cloud Translation API 都會得到
// 400/403 錯誤，被 catch 吞掉後直接 return 原文，畫面看起來就是「切換語言但
// 內容不變」。
// 改用免金鑰、原生支援 CORS 的 MyMemory Translation API，瀏覽器可直接呼叫，
// 不需要任何金鑰設定，也不會有金鑰外洩到編譯後前端程式碼的問題。
// 免費額度：匿名每日約 5000 字元，單次請求建議在 500 字元內，
// 超過的長文在下面用 _translateInChunks 依行切割後分段翻譯。
abstract class TranslationService {
  static const int _chunkSize = 480;

  static Future<String> translate(String text, AppLang target) async {
    if (target == AppLang.zhCN || text.trim().isEmpty) return text;

    final cached = _TranslationCache.get(text, target);
    if (cached != null) return cached;

    final targetCode = switch (target) {
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

    try {
      final translated = text.length > _chunkSize
          ? await _translateInChunks(text, targetCode)
          : await _translateOnce(text, targetCode);
      _TranslationCache.set(text, target, translated);
      return translated;
    } catch (e) {
      // ignore: avoid_print
      print('翻譯例外: $e');
      return text;
    }
  }

  // ── 分段翻譯：依 \n 行切割，累積不超過 _chunkSize 再送出 ─────────────
  static Future<String> _translateInChunks(String text, String targetCode) async {
    final lines = text.split('\n');
    final chunks = <String>[];
    final buf = StringBuffer();

    for (final line in lines) {
      if (buf.length + line.length + 1 > _chunkSize && buf.isNotEmpty) {
        chunks.add(buf.toString());
        buf.clear();
      }
      if (buf.isNotEmpty) buf.write('\n');
      buf.write(line);
    }
    if (buf.isNotEmpty) chunks.add(buf.toString());

    final results = <String>[];
    for (final chunk in chunks) {
      results.add(await _translateOnce(chunk, targetCode));
    }
    return results.join('\n');
  }

  static Future<String> _translateOnce(String text, String targetCode) async {
    if (text.trim().isEmpty) return text;

    // 原文是繁體佛教教學內容，來源語言固定用 zh，讓 MyMemory 自行判斷繁簡。
    final uri = Uri.https('api.mymemory.translated.net', '/get', {
      'q': text,
      'langpair': 'zh|$targetCode',
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      // ignore: avoid_print
      print('翻譯失敗 (${res.statusCode}): ${res.body}');
      return text;
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final status = data['responseStatus'];
    if (status != 200 && status != '200') {
      // ignore: avoid_print
      print('MyMemory 回應異常: ${data['responseDetails']}');
      return text;
    }

    return (data['responseData']['translatedText'] as String);
  }
}

// ── 語音導讀服務 ──────────────────────────────────────────────────
// 全域單例：同一時間只播放一段文字，切換卡片/語言/分頁時會自動停止前一段。
class TtsService extends ChangeNotifier {
  TtsService._() {
    _tts.setCompletionHandler(() => _setPlaying(null));
    _tts.setCancelHandler(() => _setPlaying(null));
    _tts.setErrorHandler((msg) {
      // ignore: avoid_print
      print('語音導讀錯誤: $msg');
      _setPlaying(null);
    });
  }

  static final TtsService instance = TtsService._();
  final FlutterTts _tts = FlutterTts();

  String? _playingId;
  String? get playingId => _playingId;
  bool isPlaying(String id) => _playingId == id;

  void _setPlaying(String? id) {
    _playingId = id;
    notifyListeners();
  }

  // AppLang → TTS 語音代碼（BCP-47）。部分語言（拉丁語、藏語）多數裝置引擎
  // 沒有內建語音包，會退而求其次改用發音較接近的語言，仍會朗讀出文字內容。
  static const Map<AppLang, String> _locales = {
    AppLang.zhCN: 'zh-CN',
    AppLang.zhTW: 'zh-TW',
    AppLang.en:   'en-US',
    AppLang.ja:   'ja-JP',
    AppLang.es:   'es-ES',
    AppLang.fr:   'fr-FR',
    AppLang.de:   'de-DE',
    AppLang.ar:   'ar-SA',
    AppLang.hi:   'hi-IN',
    AppLang.ko:   'ko-KR',
    AppLang.th:   'th-TH',
    AppLang.pt:   'pt-PT',
    AppLang.vi:   'vi-VN',
    AppLang.it:   'it-IT',
    AppLang.la:   'it-IT', // 拉丁語裝置引擎大多不支援，退而求其次
    AppLang.id:   'id-ID',
    AppLang.bo:   'zh-CN', // 藏語裝置引擎大多不支援，退而求其次
  };

  /// 播放/暫停切換：再次點擊同一段文字會停止；點擊其他段落會先停止前一段再開始新的。
  Future<void> toggle(String id, String text, AppLang lang) async {
    if (_playingId == id) {
      await stop();
      return;
    }
    await _tts.stop();
    _setPlaying(id);
    try {
      await _tts.setLanguage(_locales[lang] ?? 'zh-CN');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.48);
      final result = await _tts.speak(text);
      if (result != 1 && _playingId == id) _setPlaying(null);
    } catch (e) {
      // ignore: avoid_print
      print('語音導讀例外: $e');
      if (_playingId == id) _setPlaying(null);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _setPlaying(null);
  }
}

// ── 語音導讀按鈕 ──────────────────────────────────────────────────
class _ReadAloudButton extends StatelessWidget {
  const _ReadAloudButton({required this.id, required this.text, required this.lang, this.size = 16});
  final String id;
  final String text;
  final AppLang lang;
  final double size;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: TtsService.instance,
    builder: (context, _) {
      final playing = TtsService.instance.isPlaying(id);
      return GestureDetector(
        onTap: text.trim().isEmpty ? null : () => TtsService.instance.toggle(id, text, lang),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            playing ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
            key: ValueKey(playing),
            size: size,
            color: text.trim().isEmpty ? _kGoldIconDim : (playing ? _kGold : _kCopyIconColor),
          ),
        ),
      );
    },
  );
}

// ── Page ────────────────────────────────────────────────────────
class YingShiJuanPage extends StatefulWidget {
  const YingShiJuanPage({super.key});
  @override
  State<YingShiJuanPage> createState() => _YingShiJuanPageState();
}

class _YingShiJuanPageState extends State<YingShiJuanPage> {
  final _scroll = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;
  String _query = '';
  String? _highlight;
  AppLang _lang = AppLang.zhCN;

  List<_Card> get _filtered {
    if (_query.isEmpty) return kYingShiJuanCards;
    final q = _query.toLowerCase();
    return kYingShiJuanCards.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.body.toLowerCase().contains(q) ||
        (c.date?.toLowerCase().contains(q) ?? false)
    ).toList(growable: false);
  }

  int _pageCount(int len) => (len / _kPageSize).ceil().clamp(1, double.infinity).toInt();

  @override
  void dispose() {
    TtsService.instance.stop();
    _scroll.dispose();
    super.dispose();
  }

  void _goToPage(int page, int pageCount) {
    if (page < 0 || page >= pageCount || page == _page) return;
    TtsService.instance.stop();
    setState(() => _page = page);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll.jumpTo(0));
  }

  void _onSearchChanged(String v) => setState(() { _query = v; _page = 0; });

  void _jumpToCard(_Card card, List<_Card> f) {
    final idx = f.indexOf(card);
    if (idx == -1) return;
    setState(() {
      _page = idx ~/ _kPageSize;
      _highlight = card.title;
    });
    _scaffoldKey.currentState?.closeDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll.jumpTo(0));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlight = null);
    });
  }

  void _onLangChanged(AppLang lang) {
    TtsService.instance.stop();
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pageCount = _pageCount(filtered.length);
    final start = (_page * _kPageSize).clamp(0, filtered.length);
    final items = filtered.sublist(start, (start + _kPageSize).clamp(0, filtered.length));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kGold),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _kSearchDeco,
                child: Row(children: [
                  const Icon(Icons.search, size: 18, color: _kGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14, color: _kGold),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '搜尋標題或內容…',
                        hintStyle: TextStyle(fontSize: 13, color: _kGoldBorder),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            _LangSwitcher(current: _lang, onChanged: _onLangChanged),
          ]),
        ),
      ),
      drawer: _IndexDrawer(cards: filtered, lang: _lang, onSelect: (c) => _jumpToCard(c, filtered)),
      body: filtered.isEmpty
          ? Center(child: Text('找不到符合「$_query」的卡片', style: const TextStyle(fontSize: 14, color: _kGoldBorder)))
          : LayoutBuilder(
              builder: (_, c) => CustomScrollView(
                controller: _scroll,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridCols(c.maxWidth),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 260,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _TeachingCard(
                          key: ValueKey('${items[i].title}_${_lang.name}'),
                          card: items[i],
                          highlighted: items[i].title == _highlight,
                          lang: _lang,
                        ),
                        childCount: items.length,
                        addRepaintBoundaries: true,
                        addAutomaticKeepAlives: false,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    sliver: SliverToBoxAdapter(
                      child: _PageNav(page: _page, pageCount: pageCount, onChanged: (p) => _goToPage(p, pageCount)),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SumeruFooter()),
                ],
              ),
            ),
    );
  }
}

// ── 語言切換器 ─────────────────────────────────────────────────
class _LangSwitcher extends StatelessWidget {
  const _LangSwitcher({required this.current, required this.onChanged});
  final AppLang current;
  final ValueChanged<AppLang> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: _kSearchDeco,
    child: PopupMenuButton<AppLang>(
      tooltip: '切換語言',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      initialValue: current,
      onSelected: onChanged,
      constraints: const BoxConstraints(maxHeight: 400),
      itemBuilder: (ctx) => AppLang.values.map((l) => PopupMenuItem(
        value: l,
        child: Row(children: [
          if (l == current) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.check, size: 16, color: _kGold)),
          if (l != current) const SizedBox(width: 24),
          Text(l.fullName, style: TextStyle(fontSize: 13, color: l == current ? _kGold : _kGoldDim, fontWeight: l == current ? FontWeight.bold : FontWeight.normal)),
        ]),
      )).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.translate_rounded, size: 16, color: _kGold),
          const SizedBox(width: 4),
          Text(current.label, style: const TextStyle(fontSize: 13, color: _kGold, fontWeight: FontWeight.w600)),
          const Icon(Icons.arrow_drop_down, size: 16, color: _kGold),
        ]),
      ),
    ),
  );
}

// ── 目錄側欄 ────────────────────────────────────────────────────
class _IndexDrawer extends StatefulWidget {
  const _IndexDrawer({required this.cards, required this.lang, required this.onSelect});
  final List<_Card> cards;
  final AppLang lang;
  final ValueChanged<_Card> onSelect;

  @override
  State<_IndexDrawer> createState() => _IndexDrawerState();
}

class _IndexDrawerState extends State<_IndexDrawer> {
  // key = original title, value = translated title
  final Map<String, String> _titleCache = {};
  final Map<String, String> _dateCache = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  @override
  void didUpdateWidget(_IndexDrawer old) {
    super.didUpdateWidget(old);
    if (old.lang != widget.lang || old.cards != widget.cards) {
      _loadTitles();
    }
  }

  Future<void> _loadTitles() async {
    if (widget.lang == AppLang.zhCN) {
      setState(() { _titleCache.clear(); _dateCache.clear(); _loading = false; });
      return;
    }
    setState(() => _loading = true);
    for (final c in widget.cards) {
      if (!mounted) return;
      _titleCache[c.title] = await TranslationService.translate(c.title, widget.lang);
      if (c.date != null) {
        _dateCache[c.date!] = await TranslationService.translate(c.date!, widget.lang);
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  String _t(String original) =>
      widget.lang == AppLang.zhCN ? original : (_titleCache[original] ?? original);

  String? _d(String? original) {
    if (original == null) return null;
    if (widget.lang == AppLang.zhCN) return original;
    return _dateCache[original] ?? original;
  }

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: Colors.white,
    child: SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            const Icon(Icons.menu_book_rounded, size: 18, color: _kGold),
            const SizedBox(width: 8),
            Text('目錄（${widget.cards.length}）', style: const TextStyle(fontSize: 14, color: _kGold)),
            if (_loading) ...[
              const SizedBox(width: 8),
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: _kGold)),
            ],
          ]),
        ),
        _kDivider,
        Expanded(
          child: widget.cards.isEmpty
              ? const Center(child: Text('無符合項目', style: TextStyle(fontSize: 13, color: _kGoldBorder)))
              : ListView.builder(
                  itemCount: widget.cards.length,
                  itemBuilder: (ctx, i) {
                    final c = widget.cards[i];
                    return ListTile(
                      dense: true,
                      title: Text(_t(c.title), style: const TextStyle(fontSize: 14, color: _kGold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: _d(c.date) != null ? Text(_d(c.date!)!, style: _kDateStyle) : null,
                      onTap: () => widget.onSelect(c),
                    );
                  },
                ),
        ),
      ]),
    ),
  );
}

// ── 分頁導覽列 ────────────────────────────────────────────────────
class _PageNav extends StatelessWidget {
  const _PageNav({required this.page, required this.pageCount, required this.onChanged});
  final int page, pageCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Center(
    child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
      _NavBtn(icon: Icons.chevron_left_rounded, enabled: page > 0, onTap: () => onChanged(page - 1)),
      for (var i = 0; i < pageCount; i++)
        _PageDot(key: ValueKey(i), index: i, selected: i == page, onTap: () => onChanged(i)),
      _NavBtn(icon: Icons.chevron_right_rounded, enabled: page < pageCount - 1, onTap: () => onChanged(page + 1)),
    ]),
  );
}

class _PageDot extends StatelessWidget {
  const _PageDot({super.key, required this.index, required this.selected, required this.onTap});
  final int index;
  final bool selected;
  final VoidCallback onTap;

  static const _sel = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white);
  static const _unsel = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGoldDim);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36, alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _kGold : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: selected ? _kGold : _kGoldBorder, width: 1.2),
      ),
      child: Text('${index + 1}', style: selected ? _sel : _unsel),
    ),
  );
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 36, height: 36, alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: enabled ? _kGoldBorderNav : _kGoldBorderDim, width: 1.2),
      ),
      child: Icon(icon, size: 18, color: enabled ? _kGold : _kGoldIconDim),
    ),
  );
}

// ── 教學卡片 ────────────────────────────────────────────────────
class _TeachingCard extends StatefulWidget {
  const _TeachingCard({super.key, required this.card, this.highlighted = false, required this.lang});
  final _Card card;
  final bool highlighted;
  final AppLang lang;

  @override
  State<_TeachingCard> createState() => _TeachingCardState();
}

class _TeachingCardState extends State<_TeachingCard> {
  bool _copied = false;
  bool _loadingTranslation = false;
  String? _displayTitle;
  String? _displayBody;
  String? _displayDate;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.card.title;
    _displayBody = widget.card.body;
    _displayDate = widget.card.date;
    _loadTranslation();
  }

  @override
  void didUpdateWidget(_TeachingCard old) {
    super.didUpdateWidget(old);
    if (old.lang != widget.lang || old.card != widget.card) {
      if (TtsService.instance.isPlaying(widget.card.title)) TtsService.instance.stop();
      _loadTranslation();
    }
  }

  @override
  void dispose() {
    if (TtsService.instance.isPlaying(widget.card.title)) TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _loadTranslation() async {
    final c = widget.card;
    if (widget.lang == AppLang.zhCN) {
      setState(() {
        _displayTitle = c.title;
        _displayBody = c.body;
        _displayDate = c.date;
        _loadingTranslation = false;
      });
      return;
    }
    setState(() => _loadingTranslation = true);
    final title = await TranslationService.translate(c.title, widget.lang);
    final body  = await TranslationService.translate(c.body, widget.lang);
    final date  = c.date != null ? await TranslationService.translate(c.date!, widget.lang) : null;
    if (!mounted) return;
    setState(() {
      _displayTitle = title;
      _displayBody  = body;
      _displayDate  = date;
      _loadingTranslation = false;
    });
  }

  Future<void> _copy() async {
    if (_copied) return;
    final date  = _displayDate;
    final title = _displayTitle ?? widget.card.title;
    final body  = _displayBody  ?? widget.card.body;
    await Clipboard.setData(ClipboardData(text: [if (date != null) date, title, body].join('\n\n')));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  void _showFull() {
    final title = _displayTitle ?? widget.card.title;
    final date  = _displayDate;
    final body  = _displayBody  ?? widget.card.body;
    final dialogId = '${widget.card.title}_full';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: Text(title, style: _kTitleStyle)),
                _ReadAloudButton(id: dialogId, text: body, lang: widget.lang, size: 20),
                const SizedBox(width: 4),
                IconButton(icon: const Icon(Icons.close, color: _kGold, size: 20), onPressed: () => Navigator.of(ctx).pop()),
              ]),
              if (date != null) ...[const SizedBox(height: 4), Text(date, style: _kDateStyle)],
              const SizedBox(height: 12),
              _kDivider,
              const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(child: Text(body, style: _kDialogStyle))),
            ]),
          ),
        ),
      ),
    ).then((_) {
      if (TtsService.instance.isPlaying(dialogId)) TtsService.instance.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _displayTitle ?? widget.card.title;
    final date  = _displayDate;
    final body  = _displayBody  ?? widget.card.body;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: _showFull,
        child: DecoratedBox(
          decoration: widget.highlighted ? _kCardDecoHi : _kCardDeco,
          child: Padding(
            padding: _kCardPad,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: _copy,
                  child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: _copied ? _kCheckIcon : _kCopyIcon),
                ),
                const Spacer(),
                _ReadAloudButton(id: widget.card.title, text: body, lang: widget.lang),
              ]),
              const SizedBox(height: 8),
              Text(title, style: _kTitleStyle),
              if (date != null) ...[const SizedBox(height: 4), Text(date, style: _kDateStyle)],
              const SizedBox(height: 12),
              _kDivider,
              const SizedBox(height: 12),
              Expanded(
                child: _loadingTranslation
                    ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _kGold)))
                    : Text(body, maxLines: 4, overflow: TextOverflow.ellipsis, style: _kBodyStyle),
              ),
              const SizedBox(height: 12),
              Row(mainAxisSize: MainAxisSize.min, children: const [
                Text('閱讀全文', style: _kExpandStyle),
                SizedBox(width: 4),
                _kArrowIcon,
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}