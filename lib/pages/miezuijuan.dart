import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'footer.dart';

// ── 風格常數 ────────────────────────────────────────────────────
const _kGold          = Color(0xFFF5C518);
const _kGoldDim       = Color(0xFFB8960E);
const _kGoldBorderDim = Color(0x26F5C518); // gold @ 15%
const _kHeaderBorder  = Color(0x4DF5C518); // gold @ 30%
const _kTagDeco = BoxDecoration(
  border: Border.fromBorderSide(BorderSide(color: _kGoldBorderDim, width: 1)),
  borderRadius: BorderRadius.all(Radius.circular(20)),
);
const _kTagStyle = TextStyle(fontSize: 11, color: _kGoldDim, letterSpacing: 0.5);
const _kSectionTitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kGold, height: 1.7);
const _kBodyStyle = TextStyle(fontSize: 15, color: _kGold, height: 2.0);
const _kHeaderTitleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kGold, height: 1.5);

// ── RWD 斷點（與 footer / AppBar 一致）──────────────────────────
bool _isMobile(BuildContext ctx) => MediaQuery.sizeOf(ctx).width < 600;
bool _isTablet(BuildContext ctx) => MediaQuery.sizeOf(ctx).width < 1024;

/// 水平內距：與 SumeruFooter._hPad() 完全對齊
///   mobile  < 600  → 16 px
///   tablet  < 1024 → 32 px
///   desktop ≥ 1024 → 動態留白，讓內容區最寬 960 px，兩側置中
EdgeInsets _hPad(BuildContext ctx) {
  if (_isMobile(ctx)) return const EdgeInsets.symmetric(horizontal: 16);
  if (_isTablet(ctx)) return const EdgeInsets.symmetric(horizontal: 32);
  final w = MediaQuery.sizeOf(ctx).width;
  final side = ((w - 960) / 2).clamp(48.0, double.infinity);
  return EdgeInsets.symmetric(horizontal: side);
}

// ── 支援語言（與 video_teaching.dart 共用相同定義）───────────────
enum AppLang {
  zhTW, zhCN, en, ja, es, fr, de, ar, hi, ko, th, pt, vi, it, la, id, bo,
}

extension AppLangX on AppLang {
  String get label => switch (this) {
    AppLang.zhTW => '繁中',
    AppLang.zhCN => '简中',
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
    AppLang.zhTW => '繁體中文',
    AppLang.zhCN => '简体中文',
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
  String get targetCode => switch (this) {
    AppLang.zhTW => 'zh-TW',
    AppLang.zhCN => 'zh-CN',
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
}

// ── 翻譯快取 ──────────────────────────────────────────────────
class _TranslationCache {
  static final _cache = <String, String>{};
  static String _key(String text, AppLang lang) => '${lang.name}::$text';
  static String? get(String text, AppLang lang) =>
      lang == AppLang.zhTW ? text : _cache[_key(text, lang)];
  static void set(String text, AppLang lang, String translated) =>
      _cache[_key(text, lang)] = translated;
}

// ── 翻譯服務 ──────────────────────────────────────────────────
abstract class TranslationService {
  static Future<String> translate(String text, AppLang target) async {
    if (target == AppLang.zhTW || text.trim().isEmpty) return text;
    final cached = _TranslationCache.get(text, target);
    if (cached != null) return cached;
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=zh-TW&tl=${target.targetCode}&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) return text;
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      final segments = data[0] as List;
      final translated = segments.map((s) => s[0] as String).join();
      _TranslationCache.set(text, target, translated);
      return translated;
    } catch (_) {
      return text;
    }
  }
}

// ── 原文段落（供翻譯與複製使用）────────────────────────────────
const _kPageTitle    = '諦深大師開示滅自己執見';
const _kSectionTitle = '二、滅自己執見　滅諸邪魔外道侵染罪';
const _kTagLabel1    = '滅罪卷';
const _kTagLabel2    = '破障';
const _kTagLabel3    = '2016 / 01 / 01'; // 日期保持原樣不翻譯

const _kParagraphs = <String>[
  '開悟滅諸漏，開悟稱漏盡。凡夫未悟時，亦有滅漏法，其稱諸戒律。對於諸修行，卻漏戒中來。',
  '善知識，所謂佛寶，乃應清淨佛光所化，因之開悟之大勢因緣而生，是興大慈悲之方便度眾之身，故稱佛寶。是故如來，無所從來無所去，以得度者成就化身，稱為如來。佛說滅度，實未曾滅，只是眾生罪孽深重，多於知見量度佛法，共鳴知見以為大善，於佛本指失於敬信，丟失佛所本指，執見為障不得見佛，而稱為滅。',
  '善知識，所謂法寶，乃佛示現智慧之藏，譬如以手示月，若為指做種種說，不見於月亦不見真指，指月雙丟。如是等佛門諸子，為護佛法，雖為未悟之人，但佛為做證無有罪過，十方如來皆救拔之，終獲出離。',
  '執見狂人，未得開悟，以自己執見種種假說、種種見解、種種引用以彰己之知見，以如來假說，實立自己名相，令眾迷失。是等各個稱證無上道，共鳴罪眾如螻蟻多，實則未證謂證、未得謂得，褻瀆慈悲，罪孽自造。是等因自己執見成業，誆騙徒眾成其轉世業報，於無量劫受大罪苦。是等為求迴避受侵而設業障，越設越固，如作繭自縛，成就地獄，自不求出，求出難出，十方如來皆淚視此等，苦中無度。',
  '善知識，所謂僧寶，乃佛法傳承用相，以戒律為體，不持戒律即非僧寶。若以相取之，即墮大坑。僧寶分大行僧、獨行僧、布道僧、傳承僧、修道僧等，若假僧衣而無戒相，即波旬顯前。若無僧寶，佛法失傳。僧寶之體，相用多門。有一戒僧相、兩戒僧相，如是乃至若干戒相，此乃佛用，勿於誹謗。圓滿戒相，以心為用，佛陀住世。若一戒不持，非佛門人。',
];

// ── 主頁面（StatefulWidget，因需翻譯狀態）────────────────────
class MieZuiJuanPage extends StatefulWidget {
  const MieZuiJuanPage({super.key});

  @override
  State<MieZuiJuanPage> createState() => _MieZuiJuanPageState();
}

class _MieZuiJuanPageState extends State<MieZuiJuanPage> {
  AppLang _lang = AppLang.zhTW;
  bool _translating = false;
  String _pageTitle    = _kPageTitle;
  String _sectionTitle = _kSectionTitle;
  String _tagLabel1    = _kTagLabel1;
  String _tagLabel2    = _kTagLabel2;
  List<String> _paragraphs = List.of(_kParagraphs);
  bool _copied = false; // 複製按鈕狀態
  String _labelCopy    = '複製全文';
  String _labelCopied  = '已複製';
  String _tooltipLang  = '切換語言';

  void _onLangChanged(AppLang lang) {
    setState(() => _lang = lang);
    _loadTranslations(lang);
  }

  Future<void> _loadTranslations(AppLang lang) async {
    if (lang == AppLang.zhTW) {
      setState(() {
        _pageTitle    = _kPageTitle;
        _sectionTitle = _kSectionTitle;
        _tagLabel1    = _kTagLabel1;
        _tagLabel2    = _kTagLabel2;
        _paragraphs   = List.of(_kParagraphs);
        _labelCopy    = '複製全文';
        _labelCopied  = '已複製';
        _tooltipLang  = '切換語言';
        _translating  = false;
      });
      return;
    }
    setState(() => _translating = true);

    // 批次翻譯所有可見文字（含 UI 標籤），全部完成後一次 setState
    final results = await Future.wait([
      TranslationService.translate(_kPageTitle, lang),   // 0
      TranslationService.translate(_kSectionTitle, lang), // 1
      TranslationService.translate(_kTagLabel1, lang),   // 2
      TranslationService.translate(_kTagLabel2, lang),   // 3
      TranslationService.translate('複製全文', lang),     // 4
      TranslationService.translate('已複製', lang),       // 5
      TranslationService.translate('切換語言', lang),     // 6
      ...(_kParagraphs.map((p) => TranslationService.translate(p, lang))), // 7+
    ]);
    if (!mounted) return;
    setState(() {
      _pageTitle    = results[0];
      _sectionTitle = results[1];
      _tagLabel1    = results[2];
      _tagLabel2    = results[3];
      _labelCopy    = results[4];
      _labelCopied  = results[5];
      _tooltipLang  = results[6];
      _paragraphs   = results.sublist(7);
      _translating  = false;
    });
  }

  /// 全文複製（使用當前顯示語言的文字）
  Future<void> _copyAll() async {
    final buf = StringBuffer();
    buf.writeln(_pageTitle);
    buf.writeln();
    buf.writeln(_sectionTitle);
    buf.writeln();
    for (final p in _paragraphs) {
      buf.writeln(p);
      buf.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buf.toString().trimRight()));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildBody(context),
            const SumeruFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  // 結構：全寬容器（無線條）→ 內部加 padding → 最底部手動畫線
  // 這樣線條與文字內容同寬，跟隨 RWD padding
  Widget _buildHeader(BuildContext context) {
    final hPad = _hPad(context);
    return Padding(
      padding: hPad.copyWith(top: 48, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 標題列：文字 + 右側工具欄（語言切換 + 複製）──────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題文字，佔剩餘空間
              Expanded(
                child: Text(
                  _pageTitle,
                  style: _kHeaderTitleStyle,
                ),
              ),
              const SizedBox(width: 12),
              // 右側工具欄
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 語言切換
                  _LangSwitcher(
                    current: _lang,
                    onChanged: _onLangChanged,
                    tooltip: _tooltipLang,
                  ),
                  const SizedBox(height: 8),
                  // 全文複製按鈕
                  _CopyAllButton(
                    copied: _copied,
                    loading: _translating,
                    labelCopy: _labelCopy,
                    labelCopied: _labelCopied,
                    onTap: _translating ? null : _copyAll,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(_tagLabel1),
              _Tag(_tagLabel2),
              const _Tag(_kTagLabel3), // 日期保持原樣
            ],
          ),
          const SizedBox(height: 20),
          // ── 分隔線：在 padding 內繪製，所以與文字同寬 ──────────
          Container(height: 1, color: _kHeaderBorder),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: _hPad(context).copyWith(top: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 小節標題 + 翻譯 loading 指示
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(_sectionTitle, style: _kSectionTitleStyle),
              ),
              if (_translating) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _kGold),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // 段落
          for (final p in _paragraphs) _para(p),
          const _Ellipsis(),
        ],
      ),
    );
  }

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(text, textAlign: TextAlign.justify, style: _kBodyStyle),
      );
}

// ── 語言切換器（與 video_teaching 相同風格）──────────────────
class _LangSwitcher extends StatelessWidget {
  const _LangSwitcher({required this.current, required this.onChanged, this.tooltip = '切換語言'});
  final AppLang current;
  final ValueChanged<AppLang> onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.fromBorderSide(BorderSide(color: _kGoldBorderDim, width: 1)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: PopupMenuButton<AppLang>(
        tooltip: tooltip,
        offset: const Offset(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        initialValue: current,
        onSelected: onChanged,
        constraints: const BoxConstraints(maxHeight: 360),
        itemBuilder: (ctx) => AppLang.values.map((l) => PopupMenuItem(
          value: l,
          child: Row(children: [
            if (l == current)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check, size: 14, color: _kGold),
              )
            else
              const SizedBox(width: 22),
            Text(
              l.fullName,
              style: TextStyle(
                fontSize: 13,
                color: l == current ? _kGold : const Color(0xFF555555),
                fontWeight: l == current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ]),
        )).toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.translate_rounded, size: 14, color: _kGold),
            const SizedBox(width: 4),
            Text(current.label, style: const TextStyle(fontSize: 12, color: _kGold, fontWeight: FontWeight.w600)),
            const Icon(Icons.arrow_drop_down, size: 14, color: _kGold),
          ]),
        ),
      ),
    );
  }
}

// ── 全文複製按鈕 ───────────────────────────────────────────
class _CopyAllButton extends StatelessWidget {
  const _CopyAllButton({
    required this.copied,
    required this.loading,
    this.labelCopy = '複製全文',
    this.labelCopied = '已複製',
    this.onTap,
  });
  final bool copied;
  final bool loading;
  final String labelCopy;
  final String labelCopied;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: copied ? _kGold : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.fromBorderSide(
            BorderSide(color: copied ? _kGold : _kGoldBorderDim, width: 1),
          ),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 14,
              color: copied ? Colors.white : _kGoldDim,
            ),
            const SizedBox(width: 4),
            Text(
              copied ? labelCopied : labelCopy,
              style: TextStyle(
                fontSize: 12,
                color: copied ? Colors.white : _kGoldDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag ──────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: _kTagDeco,
        child: Text(label, style: _kTagStyle),
      );
}

// ── Ellipsis ──────────────────────────────────────────────────
class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            '· · ·',
            style: TextStyle(fontSize: 18, color: _kGoldDim, letterSpacing: 8),
          ),
        ),
      );
}