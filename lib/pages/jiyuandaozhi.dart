import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'footer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

// ── 風格常數（與 yingshijuan.dart 一致）────────────────────────
const _kGold = Color(0xFFF5C518);
const _kGoldDim = Color(0xFFB8960E);
const _kGoldBorder = Color(0x59F5C518);
const _kGoldBorderDim = Color(0x26F5C518);
const _kCopyIconColor = Color(0x99B8960E);
const _kNavShadow = BoxShadow(
  color: Color(0x0D000000),
  blurRadius: 6,
  offset: Offset(0, 2),
);
const _kCardShadow = BoxShadow(
  color: Color(0x14000000),
  blurRadius: 10,
  offset: Offset(0, 4),
);

const _kCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(BorderSide(color: _kGoldBorder, width: 1)),
  boxShadow: [_kCardShadow],
);
const _kSearchDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [_kNavShadow],
);
const _kTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: _kGold,
  height: 1.4,
);
const _kBodyStyle = TextStyle(fontSize: 13.5, color: _kGoldDim, height: 1.7);
const _kTagDeco = BoxDecoration(
  color: Color(0x0DF5C518),
  border: Border.fromBorderSide(BorderSide(color: _kGoldBorderDim, width: 1)),
  borderRadius: BorderRadius.all(Radius.circular(6)),
);
const _kTagStyle = TextStyle(fontSize: 11, color: _kGoldDim);
const _kDivider = Divider(color: Color(0x33F5C518), height: 1, thickness: 1);
const _kCheckIcon = Icon(
  Icons.check_rounded,
  key: ValueKey(true),
  size: 16,
  color: _kGold,
);
const _kCopyIcon = Icon(
  Icons.copy_rounded,
  key: ValueKey(false),
  size: 16,
  color: _kCopyIconColor,
);

// ── 支援語言 ────────────────────────────────────────────────────
enum AppLang {
  zhCN,
  zhTW,
  en,
  ja,
  es,
  fr,
  de,
  ar,
  hi,
  ko,
  th,
  pt,
  vi,
  it,
  la,
  id,
  bo,
}

extension AppLangX on AppLang {
  String get label => switch (this) {
    AppLang.zhCN => '简中',
    AppLang.zhTW => '繁中',
    AppLang.en => 'EN',
    AppLang.ja => 'JP',
    AppLang.es => 'ES',
    AppLang.fr => 'FR',
    AppLang.de => 'DE',
    AppLang.ar => 'AR',
    AppLang.hi => 'HI',
    AppLang.ko => 'KO',
    AppLang.th => 'TH',
    AppLang.pt => 'PT',
    AppLang.vi => 'VI',
    AppLang.it => 'IT',
    AppLang.la => 'LA',
    AppLang.id => 'ID',
    AppLang.bo => 'BO',
  };
  String get fullName => switch (this) {
    AppLang.zhCN => '简体中文',
    AppLang.zhTW => '繁體中文',
    AppLang.en => 'English',
    AppLang.ja => '日本語',
    AppLang.es => 'Español',
    AppLang.fr => 'Français',
    AppLang.de => 'Deutsch',
    AppLang.ar => 'العربية',
    AppLang.hi => 'हिन्दी',
    AppLang.ko => '한국어',
    AppLang.th => 'ภาษาไทย',
    AppLang.pt => 'Português',
    AppLang.vi => 'Tiếng Việt',
    AppLang.it => 'Italiano',
    AppLang.la => 'Latina',
    AppLang.id => 'Bahasa Indonesia',
    AppLang.bo => 'བོད་ཡིག',
  };
  String get _code => switch (this) {
    AppLang.zhCN => 'zh-CN',
    AppLang.zhTW => 'zh-TW',
    AppLang.en => 'en',
    AppLang.ja => 'ja',
    AppLang.es => 'es',
    AppLang.fr => 'fr',
    AppLang.de => 'de',
    AppLang.ar => 'ar',
    AppLang.hi => 'hi',
    AppLang.ko => 'ko',
    AppLang.th => 'th',
    AppLang.pt => 'pt',
    AppLang.vi => 'vi',
    AppLang.it => 'it',
    AppLang.la => 'la',
    AppLang.id => 'id',
    AppLang.bo => 'bo',
  };

  // flutter_tts 用的語音朗讀 locale（部分語言裝置引擎不一定支援，
  // 拉丁文、藏文等罕見語系會退回較接近的語言，避免完全發不出聲音）。
  String get ttsLocale => switch (this) {
    AppLang.zhCN => 'zh-CN',
    AppLang.zhTW => 'zh-TW',
    AppLang.en => 'en-US',
    AppLang.ja => 'ja-JP',
    AppLang.es => 'es-ES',
    AppLang.fr => 'fr-FR',
    AppLang.de => 'de-DE',
    AppLang.ar => 'ar-SA',
    AppLang.hi => 'hi-IN',
    AppLang.ko => 'ko-KR',
    AppLang.th => 'th-TH',
    AppLang.pt => 'pt-PT',
    AppLang.vi => 'vi-VN',
    AppLang.it => 'it-IT',
    AppLang.la => 'it-IT',
    AppLang.id => 'id-ID',
    AppLang.bo => 'zh-CN',
  };
}

// ── 翻譯快取 ────────────────────────────────────────────────────
class _TranslationCache {
  static final _cache = <String, String>{};
  static String _key(String text, AppLang lang) => '${lang.name}::$text';
  static String? get(String text, AppLang lang) =>
      lang == AppLang.zhCN ? text : _cache[_key(text, lang)];
  static void set(String text, AppLang lang, String translated) =>
      _cache[_key(text, lang)] = translated;
}

// ── 翻譯服務 ────────────────────────────────────────────────────
// Google 的 translate_a/single 端點對單一 q 參數的長度很敏感：文字一長
// （像「得戒」這篇開示，超過兩千字），GET 請求常直接被拒絕或回傳不完整
// 結果，程式又把任何例外吞掉、回傳原文，於是長文「看起來像沒被翻譯」。
// 修法：先按段落切成安全長度的小塊，逐塊翻譯後再接回去。
abstract class TranslationService {
  static const int _maxChunkLength = 1500;

  static Future<String> translate(String text, AppLang target) async {
    if (target == AppLang.zhCN || text.trim().isEmpty) return text;
    final cached = _TranslationCache.get(text, target);
    if (cached != null) return cached;
    try {
      final chunks = _splitIntoChunks(text, _maxChunkLength);
      final buffer = StringBuffer();
      for (final chunk in chunks) {
        buffer.write(await _translateChunk(chunk, target));
      }
      final translated = buffer.toString();
      _TranslationCache.set(text, target, translated);
      return translated;
    } catch (_) {
      return text;
    }
  }

  static Future<String> _translateChunk(String text, AppLang target) async {
    if (text.isEmpty) return text;
    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx&sl=zh-CN&tl=${target._code}&dt=t&q=${Uri.encodeComponent(text)}',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) return text;
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return (data[0] as List).map((s) => s[0] as String).join();
  }

  // 依換行切段，盡量在段落邊界斷開；單段仍超長時再依字元數硬切，
  // 確保任何長度的文字都能安全送出。
  static List<String> _splitIntoChunks(String text, int maxLength) {
    if (text.length <= maxLength) return [text];

    final lines = text.split('\n');
    final rough = <String>[];
    var current = StringBuffer();
    for (final line in lines) {
      final piece = current.isEmpty ? line : '\n$line';
      if (current.isNotEmpty && current.length + piece.length > maxLength) {
        rough.add(current.toString());
        current = StringBuffer(line);
      } else {
        current.write(piece);
      }
    }
    if (current.isNotEmpty) rough.add(current.toString());

    final result = <String>[];
    for (final part in rough) {
      if (part.length <= maxLength) {
        result.add(part);
        continue;
      }
      for (var i = 0; i < part.length; i += maxLength) {
        result.add(part.substring(i, (i + maxLength).clamp(0, part.length)));
      }
    }
    return result;
  }
}

// ── 語音朗讀服務 ────────────────────────────────────────────────
// 用單一 FlutterTts 實例集中管理播放狀態，確保同一時間只有一段語音在播，
// 切換卡片、切換語言或關閉彈窗時都能正確停止並還原按鈕狀態。
abstract class _TtsService {
  static final FlutterTts _tts = FlutterTts();
  static String? _speakingId;
  static bool _inited = false;

  static Future<void> _ensureInit() async {
    if (_inited) return;
    _inited = true;
    await _tts.awaitSpeakCompletion(true);
  }

  static bool isSpeaking(String id) => _speakingId == id;

  static Future<void> speak(
    String id,
    String text,
    String locale,
    VoidCallback onDone,
  ) async {
    await _ensureInit();
    if (_speakingId != null) await stop();
    if (text.trim().isEmpty) return;
    _speakingId = id;
    try {
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {}
    _tts.setCompletionHandler(() {
      if (_speakingId == id) {
        _speakingId = null;
        onDone();
      }
    });
    _tts.setCancelHandler(() {
      if (_speakingId == id) {
        _speakingId = null;
        onDone();
      }
    });
    _tts.setErrorHandler((_) {
      if (_speakingId == id) {
        _speakingId = null;
        onDone();
      }
    });
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    final id = _speakingId;
    _speakingId = null;
    if (id != null) {
      try {
        await _tts.stop();
      } catch (_) {}
    }
  }
}

// ── 自定義 ScrollBehavior ────────────────────────────────────────
class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

// ── 語言切換器 ──────────────────────────────────────────────────
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
      itemBuilder: (ctx) => AppLang.values
          .map(
            (l) => PopupMenuItem(
              value: l,
              child: Row(
                children: [
                  if (l == current)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.check, size: 16, color: _kGold),
                    ),
                  if (l != current) const SizedBox(width: 24),
                  Text(
                    l.fullName,
                    style: TextStyle(
                      fontSize: 13,
                      color: l == current ? _kGold : _kGoldDim,
                      fontWeight: l == current
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 16, color: _kGold),
            const SizedBox(width: 4),
            Text(
              current.label,
              style: const TextStyle(
                fontSize: 13,
                color: _kGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16, color: _kGold),
          ],
        ),
      ),
    ),
  );
}

// ── 資料模型 ────────────────────────────────────────────────────
typedef _CardData = ({String title, String tag, String content});

const _kCards = <_CardData>[
  (
    title: '諦深大師傳戒法音摘弘',
    tag: '開示子集：持戒   2014/03/15',
    content: '''我慢戒註：
\n所謂我慢，乃盧舍那佛設戒啟分，與貪、嗔、癡、殺、盜、妄共為攀緣罪根七分，淫戒為攀緣用分。而我慢又是貪嗔癡殺盜妄之相體，故依慢做傳戒中一註。
\n我慢不除，險道自成。因，若有人附，則慢成癡與情體，幻成淫根，若有人逆則慢成：弱則殺、強則嗔、盜、妄緣，狂妄是我慢的行為表徵，是故人之入戒修道，慢為第一戒障。
\n若有道行遇慢中人，當斷共住。何為斷共住？
\n即從此捨，不再續緣。2014佛佛涅槃日''',
  ),
  (
    title: '諦深大師開示：得戒',
    tag: '開示子集：持戒   2013/02/17',
    content: '''1、不殺生。所謂不殺戒相，不斷一切眾生性命，亦不傷之。修持者云，不踏生草，表決定性。
\n釋：殺為眾生諸罪頭等，是罪惡之極，若不斷殺，諸戒難立。殺為斷現前因緣之最罪業，若不斷殺，道場不立。
\n生命為眾生種種因緣應相，為識心托處，種種因緣所化，顯前因緣為相互依托之本。若斷之命，現前因緣被斷，即處轉惡殺因緣，於本心中生惡殺本分，於之殺業成惡緣纏。有殺業者，必轉生被殺途中，難有出期。鬼神之道以殺為本，處處現殺。鬼神之屬於佛法難於行道，因其殺業極盛，道場無以立相。
\n是故，不殺為了惡之始，人欲修行需先了惡，若不了惡，因緣更纏，說出六道，妄中求妄也。

\n2、不盜。不盜戒相，為應戒第二。不取非予之物，稱不盜戒。不盜雖為不殺支分，但另含新分自成一體。
\n釋：盜為斷眾生因緣命相之做，是故亦稱次等殺生。
\n不盜戒為第二大戒。何故是說？眾生生命非一口氣耳，諸多因緣共同稱為之之生命。盜取人之物品，實為斷殺其之命因之一，是故稱盜為殺戒第二。
\n不盜戒分為輕重層析，重盜於殺等；輕盜受如下等報：一者，困苦潦倒報；二者，遭人攻擊報；三者，或獲遭殺報。
\n是故，入門應戒，不盜第二。
\n若有人盜如來種種品；沙彌、比丘種種品；清淨道場種種品，為重罪。或遭與殺戒等報。

\n3、不淫。不淫戒相，男女交媾，為應戒第三。不與種種異屬關係，是稱不淫。
\n釋：淫為因緣合和六道之本，淫心為輪轉之處，種種因緣於此獲轉。欲出六道，淫為第一道帳。雖淫心為第一道障，但是，於淫欲界中，淫能遏殺，能以不被殺滅而立道場，是故不淫第三。
\n淫欲有因緣集結功用，眾生緣分顯為淫心。若淫欲旺，實為因緣所使，殺盜淫妄皆於其中。殺、盜、淫、妄等等所有因緣，相互輪轉成相即是淫心。殺、盜、淫、妄為淫心大根，淫何故亦在淫根之列？因淫為轉集，層次甚多，諸多因緣相轉都落淫相。
\n不淫，有不再多遭眾生因緣相托之續大用，但，如殺心盜心等等不除，說不淫者，同於水中求月，徒然用功。淫心又是因緣再輪之初，雖不顯殺盜等等諸相，但淫轉之後，諸相會隨緣分運行相繼顯現。因諸相不直接顯現故，不淫戒為第三大戒。

\n4、不妄。不妄，實而不虛諸相。虛妄為世界之初始，造種種業之始。眾生之妄為妄中之妄，若不破除，難於修道。是故，不妄為根本大戒。
\n釋：妄為六道之本，何故為第四戒，而非第一戒律？因未悟之前眼、耳、鼻等諸業已就，眾生以此為實，而所謂為實，其中又生諸妄，諸妄又生種種。修行之者所持初之妄戒，實為次之又次之妄，之於殺、盜、淫等業之眾生頂罪惡相大本為次，是故，不妄第四。
\n善者，不妄之者並非妄語一乘，含概諸多，因以妄語為表象，釋迦如來滅後，長久以來，傳戒者不清淨故於戒有失，是故，以不妄語代不妄戒傳稱至今。
\n佛地門戒要

\n5、不貪。貪為攀緣之相，是眾生之本。貪有兩分，一者侵分，二者狂根分。
\n侵分為占有別人之相，於是獲嗔，因嗔生爭，因爭生鬥，因鬥生殺。
\n狂根分以獲取體大為相，因大生慢，以慢為強，以強凌弱，凌為殺因；
\n又侵狂未成殺盜之時，相纏成體，纏之成相，造諸相欺、相瞞、相用等等諸相，以造虛偽，借用等鬼道用相，等等。是故貪為諸戒壞處，自成一體，為第五大戒。

\n6、不嗔。為殺之導引，當斷習氣。因習氣故，對不入汝之習氣者生嗔恨心，因嗔恨故誕生惡念。
\n不嗔戒，為殺盜等根本戒體之構成支分戒，是不殺戒的分戒、不盜等諸戒的緣分戒。雖為殺盜淫等緣分，但自成一體，是故為第六大戒。
\n嗔為不殺律之一藏，是殺之導引。殺心之初處之一為嗔，由嗔生殺，是故修行之者當不嗔。
\n如何不嗔？當斷習氣。習氣之成，造我為相。因習氣故，對不入汝之習氣者生嗔恨心，因嗔恨故誕生惡念。是故，斷嗔為如來第六戒相要旨。

\n7、不癡。癡為以不明、糊塗、執著、迷信等為行為之相。乃諸惡依附之本。
\n不癡戒，為破眾生輪轉之本之如來加持應戒。因癡人於善法難於生信，是故如來以「不可思議」說菠蘿蜜為慈悲法布施眾生。
\n癡為以不明、糊塗、執著、迷信等為行為之相。是殺盜等諸惡胚體，乃諸惡依附之本，入佛國土，癡之不除，養虎為患，眾生之大障。

\n8、不慢戒。為攀緣體相戒，乃諸多戒之同分戒。不慢卻攀緣心根，止纏縛造惡之本，有遏止六道根本生相之用。
\n如何是慢？慢為以己之得處，鄙視無者。
\n慢心成處：
\n一者，以希冀追求、生攀緣心；以攀緣造業成體、為如願，得成「墮落願望」心；以願望心發墮落願；以自己所造之業為得、做頂、生傲視心，如是成就我慢心。
\n二者，妄中求得，以妄中有求、視為己勝而成妄得，妄得既成而成傲視心，以此成頂造就慢心。
\n三者，習業為體，據業為勝，鄙視來者，以成傲視心，因此為得成就慢心。
\n修行之道不去慢心，無有成處。是故，不慢為如來第八根本戒處。
\n......
\n（選自《普修行藏》三、《機緣道旨妙法入門》中第五品《得戒》共有20戒。）''',
  ),
  (
    title: '諦深大師開示：攝緣',
    tag: '開示子集：攝緣   2013/01/25',
    content:
        '''各位弟子，入於佛之法座下，是稱入十方佛攝緣法。十方世界妄心攀緣成因、因因造業，業成緣分、緣緣相扣、成就緣起，緣起成像，造諸種類。種類起緣，各業互牽，又造共業，諸多種類，為攀緣故，遞弱為食，互相凌滅，滅後互轉，成就六道。
\n諸善因緣，汝等因慈悲故而獲救度，是大果報，非一世、兩世、乃至千世萬世無量世劫因緣所至。汝等無始劫來，種種修行造種種善，成就善種，善種量吸成因，滋潤伸展，吐善成根，蔽惡納善，獲普洽甘露，享六波羅蜜，於是善成佛緣，生成佛種。
\n爾等佛種發芽，大福報現前，入佛門下得獲救法，此稱攝緣。攝緣既成，成佛國土，此稱成佛。攝緣乃十方諸佛興慈悲法，是十方諸佛甘露施法，是十方眾生成佛之法。
\n釋迦如來、三藏十二部，彌陀如來四十八願，乃至文殊普賢、觀音勢至十方大善，所行道法，皆攝緣法。
\n。。。。。。。
\n（註：摘自諦深大師《普修行藏》，因為這是具戒比丘與具戒大沙彌專用，大部分章節非具戒者不能傳閱，望廣大修行善解。）''',
  ),
];

// ── 主頁面 ──────────────────────────────────────────────────────
class JiYuanDaoZhiPage extends StatefulWidget {
  const JiYuanDaoZhiPage({super.key});
  @override
  State<JiYuanDaoZhiPage> createState() => _JiYuanDaoZhiPageState();
}

class _JiYuanDaoZhiPageState extends State<JiYuanDaoZhiPage> {
  AppLang _lang = AppLang.zhCN;

  void _onLangChanged(AppLang lang) => setState(() => _lang = lang);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Spacer(),
              _LangSwitcher(current: _lang, onChanged: _onLangChanged),
            ],
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: NoScrollbarBehavior(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w > 1000 ? 3 : (w > 600 ? 2 : 1);
            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _kCards
                            .map(
                              (c) => _CardWidget(
                                key: ValueKey('${c.title}_${_lang.name}'),
                                data: c,
                                screenWidth: w,
                                cols: cols,
                                lang: _lang,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SumeruFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── 卡片 Widget ─────────────────────────────────────────────────
class _CardWidget extends StatefulWidget {
  const _CardWidget({
    super.key,
    required this.data,
    required this.screenWidth,
    required this.cols,
    required this.lang,
  });
  final _CardData data;
  final double screenWidth;
  final int cols;
  final AppLang lang;

  @override
  State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget> {
  bool _copied = false;
  bool _loading = false;
  bool _speaking = false;
  String? _displayTitle;
  String? _displayTag;
  String? _displayContent;

  String get _ttsId => 'card_${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    _resetDisplay();
    _loadTranslation();
  }

  @override
  void didUpdateWidget(_CardWidget old) {
    super.didUpdateWidget(old);
    if (old.lang != widget.lang || old.data != widget.data) {
      if (_speaking) {
        _TtsService.stop();
        _speaking = false;
      }
      _loadTranslation();
    }
  }

  @override
  void dispose() {
    if (_speaking) _TtsService.stop();
    super.dispose();
  }

  // extraRebuild 讓彈窗（_showFull）裡的獨立 StatefulBuilder 也能同步更新按鈕圖示。
  Future<void> _toggleSpeak([VoidCallback? extraRebuild]) async {
    if (_speaking) {
      await _TtsService.stop();
      if (mounted) setState(() => _speaking = false);
      extraRebuild?.call();
      return;
    }
    final text = [
      _displayTitle ?? widget.data.title,
      _displayContent ?? widget.data.content,
    ].join('。 ');
    if (mounted) setState(() => _speaking = true);
    extraRebuild?.call();
    await _TtsService.speak(_ttsId, text, widget.lang.ttsLocale, () {
      if (mounted) setState(() => _speaking = false);
      extraRebuild?.call();
    });
  }

  void _resetDisplay() {
    _displayTitle = widget.data.title;
    _displayTag = widget.data.tag;
    _displayContent = widget.data.content;
  }

  Future<void> _loadTranslation() async {
    if (widget.lang == AppLang.zhCN) {
      setState(() {
        _resetDisplay();
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final title = await TranslationService.translate(
      widget.data.title,
      widget.lang,
    );
    final tag = await TranslationService.translate(
      widget.data.tag,
      widget.lang,
    );
    final content = await TranslationService.translate(
      widget.data.content,
      widget.lang,
    );
    if (!mounted) return;
    setState(() {
      _displayTitle = title;
      _displayTag = tag;
      _displayContent = content;
      _loading = false;
    });
  }

  Future<void> _copy() async {
    if (_copied) return;
    final text = [
      _displayTitle ?? widget.data.title,
      _displayTag ?? widget.data.tag,
      _displayContent ?? widget.data.content,
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  void _showFull() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _displayTitle ?? widget.data.title,
                        style: _kTitleStyle,
                      ),
                    ),
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _speaking
                              ? Icons.stop_circle_rounded
                              : Icons.volume_up_rounded,
                          key: ValueKey(_speaking),
                          color: _kGold,
                          size: 20,
                        ),
                      ),
                      tooltip: _speaking ? '停止朗讀' : '朗讀全文',
                      onPressed: () =>
                          _toggleSpeak(() => setDialogState(() {})),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: _kGold, size: 20),
                      onPressed: () async {
                        if (_speaking) await _toggleSpeak();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _Tag(_displayTag ?? widget.data.tag),
                const SizedBox(height: 12),
                _kDivider,
                const SizedBox(height: 14),
                Flexible(
                  child: ScrollConfiguration(
                    behavior: NoScrollbarBehavior(),
                    child: SingleChildScrollView(
                      child: Text(
                        _displayContent ?? widget.data.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _kGoldDim,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.screenWidth;
    final cardWidth =
        ((w < 600 ? w - 32 : w / widget.cols - 24.0 * widget.cols)).clamp(
          300.0,
          450.0,
        );

    return GestureDetector(
      onTap: _showFull,
      child: Container(
        width: cardWidth,
        height: 550,
        padding: const EdgeInsets.all(20),
        decoration: _kCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _displayTitle ?? widget.data.title,
                    style: _kTitleStyle,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _toggleSpeak(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _speaking
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_rounded,
                      key: ValueKey(_speaking),
                      size: 16,
                      color: _speaking ? _kGold : _kCopyIconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _copy,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _copied ? _kCheckIcon : _kCopyIcon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Tag(_displayTag ?? widget.data.tag),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kGold,
                        ),
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: NoScrollbarBehavior(),
                      child: SingleChildScrollView(
                        child: Text(
                          _displayContent ?? widget.data.content,
                          style: _kBodyStyle,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '展開全文',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16, color: _kGold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag 標籤 ────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: _kTagDeco,
    child: Text(label, style: _kTagStyle),
  );
}