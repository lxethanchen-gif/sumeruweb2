import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'footer.dart';

const _gold = Color.fromARGB(255, 255, 209, 2);
const _goldLight = Color.fromARGB(255, 255, 255, 255);
const _goldBorder = Color(0x8CFFD102);
const _navShadow = BoxShadow(
  color: Color(0x0D000000),
  blurRadius: 6,
  offset: Offset(0, 2),
);
const _cardShadows = [
  BoxShadow(color: Color(0x12000000), blurRadius: 20, offset: Offset(0, 4)),
  BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 1)),
];
const _cardDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: _cardShadows,
);
const _border = Border.fromBorderSide(BorderSide(color: _goldBorder, width: 1));
const _navDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8)),
  boxShadow: [_navShadow],
  border: _border,
);
const _navDecoDisabled = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8)),
  boxShadow: [_navShadow],
  border: Border.fromBorderSide(BorderSide(color: Color(0x33FFD102), width: 1)),
);
const _searchDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [_navShadow],
);
const _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color.fromARGB(255, 246, 209, 4),
  height: 1.2,
);
// 影片卡「標題區」固定高度（以兩行標題為基準），
// 讓所有卡片不論標題長短都統一大小。
const double _titleAreaHeight = 60;

// ── 支援語言 ────────────────────────────────────────────────────
enum AppLang {
  zhTW,
  zhCN,
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
    AppLang.zhTW => '繁中',
    AppLang.zhCN => '简中',
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
    AppLang.zhTW => '繁體中文',
    AppLang.zhCN => '简体中文',
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
  // Google Translate target code; zhTW is original so pass-through
  String get targetCode => switch (this) {
    AppLang.zhTW => 'zh-TW',
    AppLang.zhCN => 'zh-CN',
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

class VideoData {
  final String id, title, url;
  const VideoData(this.id, this.title, this.url);
}

const _videos = <VideoData>[
  VideoData(
    '2z26miBEBkA',
    '2020年3月7日 49期(第1期)',
    'https://youtu.be/2z26miBEBkA',
  ),
  VideoData(
    'aYdmafP7HMY',
    '2020年3月14日 49期(第2期)',
    'https://youtu.be/aYdmafP7HMY',
  ),
  VideoData(
    '3uGgjYDmhUA',
    '2020年3月21日 49期(第3期)',
    'https://youtu.be/3uGgjYDmhUA',
  ),
  VideoData(
    'stTdG5iHhjE',
    '2020年3月28日 49期(第4期)',
    'https://youtu.be/stTdG5iHhjE',
  ),
  VideoData(
    '5C4nQcL9LQQ',
    '2020年4月4日 49期(第5期)',
    'https://youtu.be/5C4nQcL9LQQ',
  ),
  VideoData(
    'H1lleUTetsQ',
    '2020年4月11日 49期(第6期)',
    'https://youtu.be/H1lleUTetsQ',
  ),
  VideoData(
    'aBnWRe6MuMo',
    '2020年4月18日 49期(第7期)',
    'https://youtu.be/aBnWRe6MuMo',
  ),
  VideoData(
    'LJyHPuiF8UQ',
    '2020年4月25日 49期(第8期)',
    'https://youtu.be/LJyHPuiF8UQ',
  ),
  VideoData(
    'yPiOy9NjS_c',
    '2020年4月26日 49期(第9期)',
    'https://youtu.be/yPiOy9NjS_c',
  ),
  VideoData(
    '2BwBSduL4-U',
    '2020年4月30日 49期(第10期)',
    'https://youtu.be/2BwBSduL4-U',
  ),
  VideoData(
    'eqKls8wUiPY',
    '2020年5月2日 49期(第11期)',
    'https://youtu.be/eqKls8wUiPY',
  ),
  VideoData(
    'XBeCi0JORV0',
    '2020年5月9日 49期(第12期)',
    'https://youtu.be/XBeCi0JORV0',
  ),
  VideoData(
    'nj711RpHviw',
    '2020年5月16日 49期(第13期)',
    'https://youtu.be/nj711RpHviw',
  ),
  VideoData(
    'QuQSeUm7N9M',
    '2020年5月23日 49期(第14期)',
    'https://youtu.be/QuQSeUm7N9M',
  ),
  VideoData(
    'rfsX-E7Il5w',
    '2020年5月30日 49期(第15期)',
    'https://youtu.be/rfsX-E7Il5w',
  ),
  VideoData(
    'dJhRgdfS6iU',
    '2020年6月6日 49期(第16期)',
    'https://youtu.be/dJhRgdfS6iU',
  ),
  VideoData(
    '262NEBlWEqg',
    '2020年6月13日 49期(第17期)',
    'https://youtu.be/262NEBlWEqg',
  ),
  VideoData(
    'j6mM4OQ9MCk',
    '2020年6月20日 49期(第18期)',
    'https://youtu.be/j6mM4OQ9MCk',
  ),
  VideoData(
    'H3VNj1IN6cQ',
    '2020年6月27日 49期(第19期)',
    'https://youtu.be/H3VNj1IN6cQ',
  ),
  VideoData(
    'rX3999zfw00',
    '2020年7月4日 49期(第20期)',
    'https://youtu.be/rX3999zfw00',
  ),
  VideoData(
    'DnQG3YtISs8',
    '2020年7月11日 49期(第21期)',
    'https://youtu.be/DnQG3YtISs8',
  ),
  VideoData(
    'g28d1S926Rc',
    '2020年7月18日 49期(第22期)',
    'https://youtu.be/g28d1S926Rc',
  ),
  VideoData(
    'txzLgfTEPXk',
    '2020年7月25日 49期(第23期)',
    'https://youtu.be/txzLgfTEPXk',
  ),
  VideoData(
    'Xa8oQYBxK9Q',
    '2020年8月1日 49期(第24期)',
    'https://youtu.be/Xa8oQYBxK9Q',
  ),
  VideoData(
    'AOAS242oUlE',
    '2020年8月8日 49期(第25期)',
    'https://youtu.be/AOAS242oUlE',
  ),
  VideoData(
    'oDjIuDkA9tg',
    '2020年8月15日 49期(第26期)',
    'https://youtu.be/oDjIuDkA9tg',
  ),
  VideoData(
    'pIRPa9gNFqA',
    '2020年8月22日 49期(第27期)',
    'https://youtu.be/pIRPa9gNFqA',
  ),
  VideoData(
    'jIv-IhC-RHM',
    '2020年8月29日 49期(第28期)',
    'https://youtu.be/jIv-IhC-RHM',
  ),
  VideoData(
    'gIpKP3KP48c',
    '2020年9月5日 49期(第29期)',
    'https://youtu.be/gIpKP3KP48c',
  ),
  VideoData(
    'G3Ncx7iwImU',
    '2020年9月12日 49期(第30期)',
    'https://youtu.be/G3Ncx7iwImU',
  ),
  VideoData(
    'vnzcDNC4XFg',
    '2020年9月19日 49期(第31期)',
    'https://youtu.be/vnzcDNC4XFg',
  ),
  VideoData(
    'NugoxAuPvzA',
    '2020年9月26日 49期(第32期)',
    'https://youtu.be/NugoxAuPvzA',
  ),
  VideoData(
    'RRopQZdX45k',
    '2020年10月3日 49期(第33期)',
    'https://youtu.be/RRopQZdX45k',
  ),
  VideoData(
    'Kk_GO7LC8q0',
    '2020年10月10日 49期(第34期)',
    'https://youtu.be/Kk_GO7LC8q0',
  ),
  VideoData(
    'M5wu_DWiPS8',
    '2020年10月17日 49期(第35期)',
    'https://youtu.be/M5wu_DWiPS8',
  ),
  VideoData(
    'IqhBwhYHC_k',
    '2020年10月24日 49期(第36期)',
    'https://youtu.be/IqhBwhYHC_k',
  ),
  VideoData(
    'Vhm19TQjp68',
    '2020年10月31日 49期(第37期)',
    'https://youtu.be/Vhm19TQjp68',
  ),
  VideoData(
    'Y_dzD41G7ow',
    '2020年11月7日 49期(第38期)',
    'https://youtu.be/Y_dzD41G7ow',
  ),
  VideoData(
    '7Vd8-bBqEoM',
    '2020年11月14日 49期(第39期)',
    'https://youtu.be/7Vd8-bBqEoM',
  ),
  VideoData(
    '3PKymWBy4xg',
    '2020年11月21日 49期(第40期)',
    'https://youtu.be/3PKymWBy4xg',
  ),
  VideoData(
    'nday-JJ-Cww',
    '2020年11月28日 49期(第41期)',
    'https://youtu.be/nday-JJ-Cww',
  ),
  VideoData(
    'w3_FQTXuqFg',
    '2020年12月5日 49期(第42期)',
    'https://youtu.be/w3_FQTXuqFg',
  ),
  VideoData(
    'eWIi69l28dE',
    '2020年12月12日 49期(第43期)',
    'https://youtu.be/eWIi69l28dE',
  ),
  VideoData(
    'W684lpOKESQ',
    '2020年12月19日 49期(第44期)',
    'https://youtu.be/W684lpOKESQ',
  ),
  VideoData(
    'XQVCQvpi3RM',
    '2020年12月26日 49期(第45期)',
    'https://youtu.be/XQVCQvpi3RM',
  ),
  VideoData(
    'AwoN9zqdpHE',
    '2020年12月31日 49期(第46期)',
    'https://youtu.be/AwoN9zqdpHE',
  ),
  VideoData(
    'ffC1-37WU5U',
    '2021年1月2日 49期(第47期)',
    'https://youtu.be/ffC1-37WU5U',
  ),
  VideoData(
    'e-T5aXiY4Fc',
    '2021年1月9日 49期(第48期)',
    'https://youtu.be/e-T5aXiY4Fc',
  ),
  VideoData(
    'MzoUsZvr4Us',
    '2021年1月16日 49期(第49期)',
    'https://youtu.be/MzoUsZvr4Us',
  ),
  VideoData('fxG517U2nuE', '2021年2月11日', 'https://youtu.be/fxG517U2nuE'),
  VideoData(
    'sXfvyqw62bA',
    '2021年3月31日',
    'https://www.youtube.com/live/sXfvyqw62bA',
  ),
  VideoData('wDYOKDgn-Uc', '2021年5月19日', 'https://youtu.be/wDYOKDgn-Uc'),
  VideoData('Vjajl5I010M', '2021年7月28日', 'https://youtu.be/Vjajl5I010M'),
  VideoData('0B2V8lvOPKQ', ' 2021年8月14日 諦深佛陀開示 如何修止觀', 'https://youtu.be/0B2V8lvOPKQ'),
  VideoData('1pirAsAHCsM', '諦深佛陀開示 示現49期', 'https://youtu.be/1pirAsAHCsM'),
  VideoData('x_7-wZRu1gg', '諦深佛陀開示 如何發心出家', 'https://youtu.be/x_7-wZRu1gg'),
  VideoData('iT_ZDekFnMo', '2021年8月21日', 'https://www.youtube.com/live/jQD9VTGa6Og'),
  VideoData('iT_ZDekFnMo', '2021年10月24日', 'https://youtu.be/iT_ZDekFnMo'),
  VideoData('Vdt19z6GMvU', '2021年12月20日', 'https://youtu.be/Vdt19z6GMvU'),
  VideoData('OhKDjnkM48s', '2022年1月31日', 'https://youtu.be/OhKDjnkM48s'),
  VideoData('axJiTER9eSo', '2022年2月5日', 'https://youtu.be/axJiTER9eSo'),
  VideoData('fZGLvwD38wc', '2022年3月20日', 'https://youtu.be/fZGLvwD38wc'),
  VideoData('LyrR4lCv6WI', '2022年5月4日', 'https://youtu.be/LyrR4lCv6WI'),
  VideoData('zwQMbuQPv7Y', '2022年7月17日', 'https://youtu.be/zwQMbuQPv7Y'),
  VideoData('W4Z4vm3zQlQ', '2022年10月14日', 'https://youtu.be/W4Z4vm3zQlQ'),
  VideoData('V0a0hbtI49Y', '2022年12月10日', 'https://youtu.be/V0a0hbtI49Y'),
  VideoData('FnxWxHmFr4k', '2023年1月21日', 'https://youtu.be/FnxWxHmFr4k'),
  VideoData('eGO6FHpQdk8', '2023年3月10日', 'https://youtu.be/eGO6FHpQdk8'),
  VideoData('B-SzXaYtWkE', '2023年5月22日', 'https://youtu.be/B-SzXaYtWkE'),
  VideoData('B-SzXaYtWkE', '2023年8月5日', 'https://youtu.be/RZVAEkAUt1I'),
  VideoData('CYOLEGe8QhQ', '2023年11月2日', 'https://youtu.be/CYOLEGe8QhQ'),
  VideoData('CYOLEGe8QhQ', '2023年12月29日', 'https://youtu.be/LjPaoOWzJdY'),
  VideoData('UcRqfGqZvs8', '2024年2月9日', 'https://youtu.be/UcRqfGqZvs8'),
  VideoData('vIMF1DzitZI', '2024年2月14日 香港地藏法會', 'https://youtu.be/vIMF1DzitZI'),
  VideoData('8VkgSo62_5E', '2024年2月15日 香港地藏法會', 'https://youtu.be/8VkgSo62_5E'),
  VideoData('-guDN5c1hH8', '2024年2月16日 香港地藏法會', 'https://youtu.be/-guDN5c1hH8'),
  VideoData('KZaGqeR3V1Q', '2024年2月17日 香港地藏法會', 'https://youtu.be/KZaGqeR3V1Q'),
  VideoData('J7-4KHXLVbE', '2024年2月18日 香港地藏法會', 'https://youtu.be/J7-4KHXLVbE'),
  VideoData('zsNMWflqiX0', '2024年5月11日', 'https://youtu.be/zsNMWflqiX0'),
  VideoData('nTYNq1dBtnc', '2024年5月15日', 'https://youtu.be/nTYNq1dBtnc'),
  VideoData('nTYNq1dBtnc', '2024年6月4日 菩薩因地法 第一課', 'https://youtu.be/Ci4JMv4z5IQ'),
  // VideoData('nTYNq1dBtnc', '2024年6月8日 菩薩因地法 第二課', 'https://www.youtube.com/live/hXX0jGrULeo'),
  VideoData('eO3shpiiFBM', '2024年7月24日 菩薩因地法 第二課', 'https://www.youtube.com/live/sD_8hfRoHQ8'),
  VideoData('3vLj1EJtmbU', '2024年10月22日', 'https://youtu.be/3vLj1EJtmbU'),
  VideoData('8L0y7F3mvBM', '2024年12月17日', 'https://youtu.be/8L0y7F3mvBM'),
  VideoData('8L0y7F3mvBM', '2025年1月28日', 'https://youtu.be/23UtXP92emw'),
  VideoData('d_O06DVDWYs', '2025年3月18日', 'https://youtu.be/d_O06DVDWYs'),
  VideoData('ZSbmJ9u4ZeM', '2025年5月1日', 'https://youtu.be/ZSbmJ9u4ZeM'),
  VideoData('XSoXF4ha3a8', '2025年5月5日', 'https://youtu.be/XSoXF4ha3a8'),
  VideoData('xSKLKrcRZXk', '2025年7月13日', 'https://youtu.be/xSKLKrcRZXk'),
  VideoData(
    'fSBgyQo9ihg',
    '2025年11月8日',
    'https://www.youtube.com/live/fSBgyQo9ihg',
  ),
  VideoData(
    'ILG7O5jwv2A',
    '2026年1月5日',
    'https://www.youtube.com/live/ILG7O5jwv2A',
  ),
  VideoData(
    'VOEZ5b7SAJw',
    '2026年2月16日',
    'https://www.youtube.com/live/VOEZ5b7SAJw',
  ),
  VideoData(
    'Pdb2D8hg8iY',
    '2026年4月6日',
    'https://www.youtube.com/live/Pdb2D8hg8iY',
  ),
  VideoData(
    'uu2OvQm2YTg',
    '2026年5月20日',
    'https://www.youtube.com/live/uu2OvQm2YTg',
  ),
  VideoData(
    'OZm3J1-5DBA',
    '2026年5月24日',
    'https://www.youtube.com/live/OZm3J1-5DBA',
  ),
  VideoData(
    'gj4mSg0ElRA',
    '2026年5月29日',
    'https://www.youtube.com/live/gj4mSg0ElRA',
  ),
  VideoData(
    'ew0PgNXOrQk',
    '2026年8月1日',
    'https://www.youtube.com/live/ew0PgNXOrQk',
  ),
];

class VideoTeachingsPage extends StatefulWidget {
  const VideoTeachingsPage({super.key});
  @override
  State<VideoTeachingsPage> createState() => _VideoTeachingsPageState();
}

class _VideoTeachingsPageState extends State<VideoTeachingsPage> {
  static const _perPage = 25;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;
  String _query = '';
  AppLang _lang = AppLang.zhTW;

  static int _cols(double w) => w >= 1700
      ? 6
      : w >= 1280
      ? 5
      : w >= 1000
      ? 4
      : w >= 720
      ? 3
      : w >= 480
      ? 2
      : 1;

  List<VideoData> get _filtered {
    if (_query.isEmpty) return _videos;
    final q = _query.toLowerCase();
    return _videos
        .where((v) => v.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  int _totalPages(int len) =>
      (len / _perPage).ceil().clamp(1, double.infinity).toInt();

  void _goTo(int p, int total) {
    if (p != _page && p >= 0 && p < total) setState(() => _page = p);
  }

  void _onSearchChanged(String v) => setState(() {
    _query = v;
    _page = 0;
  });

  void _jumpTo(VideoData v, List<VideoData> f) {
    final idx = f.indexOf(v);
    if (idx == -1) return;
    setState(() => _page = idx ~/ _perPage);
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _onLangChanged(AppLang lang) => setState(() => _lang = lang);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final total = _totalPages(filtered.length);
    final start = (_page * _perPage).clamp(0, filtered.length);
    final list = filtered.sublist(
      start,
      (start + _perPage).clamp(0, filtered.length),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: _searchDeco,
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: _gold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: _onSearchChanged,
                          style: const TextStyle(fontSize: 14, color: _gold),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '搜尋影片標題…',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: _goldBorder,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _LangSwitcher(current: _lang, onChanged: _onLangChanged),
            ],
          ),
        ),
      ),
      drawer: _IndexDrawer(
        videos: filtered,
        lang: _lang,
        onSelect: (v) => _jumpTo(v, filtered),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Text(
                '找不到符合「$_query」的影片',
                style: const TextStyle(fontSize: 14, color: _goldBorder),
              ),
            )
          : CustomScrollView(
              cacheExtent: 1200,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverLayoutBuilder(
                    builder: (ctx, c) {
                      const spacing = 16.0;
                      final cols = _cols(c.crossAxisExtent).clamp(1, 6);
                      // 每張卡片寬度：以可用寬度平分（含欄間距）
                      final itemWidth =
                          (c.crossAxisExtent - spacing * (cols - 1)) / cols;
                      // 卡片高度 = 16:9 縮圖高度 + 固定標題區高度
                      // 讓每張卡片長寬完全一致（以最大的卡片為基準）
                      final itemHeight = itemWidth * 9 / 16 + _titleAreaHeight;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          mainAxisExtent: itemHeight,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _VideoCard(
                            key: ValueKey('${list[i].id}_${_lang.name}'),
                            video: list[i],
                            lang: _lang,
                          ),
                          childCount: list.length,
                        ),
                      );
                    },
                  ),
                ),
                if (total > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _PaginationBar(
                        page: _page,
                        total: total,
                        onTap: (p) => _goTo(p, total),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SumeruFooter()),
              ],
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
    decoration: _searchDeco,
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
                      child: Icon(Icons.check, size: 16, color: _gold),
                    )
                  else
                    const SizedBox(width: 24),
                  Text(
                    l.fullName,
                    style: TextStyle(
                      fontSize: 13,
                      color: l == current ? _gold : const Color(0xFF555555),
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
            const Icon(Icons.translate_rounded, size: 16, color: _gold),
            const SizedBox(width: 4),
            Text(
              current.label,
              style: const TextStyle(
                fontSize: 13,
                color: _gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16, color: _gold),
          ],
        ),
      ),
    ),
  );
}

// ── 目錄側欄（支援翻譯） ────────────────────────────────────────
class _IndexDrawer extends StatefulWidget {
  final List<VideoData> videos;
  final AppLang lang;
  final ValueChanged<VideoData> onSelect;
  const _IndexDrawer({
    required this.videos,
    required this.lang,
    required this.onSelect,
  });

  @override
  State<_IndexDrawer> createState() => _IndexDrawerState();
}

class _IndexDrawerState extends State<_IndexDrawer> {
  // cache: videoId -> translated title
  final Map<String, String> _titles = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  @override
  void didUpdateWidget(_IndexDrawer old) {
    super.didUpdateWidget(old);
    if (old.lang != widget.lang || old.videos != widget.videos) {
      _loadTitles();
    }
  }

  Future<void> _loadTitles() async {
    if (widget.lang == AppLang.zhTW) {
      setState(() {
        _titles.clear();
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = <String, String>{};
    for (final v in widget.videos) {
      if (!mounted) return;
      results[v.id] = await TranslationService.translate(v.title, widget.lang);
    }
    if (!mounted) return;
    setState(() {
      _titles.addAll(results);
      _loading = false;
    });
  }

  String _titleFor(VideoData v) =>
      widget.lang == AppLang.zhTW ? v.title : (_titles[v.id] ?? v.title);

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: Colors.white,
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 18, color: _gold),
                const SizedBox(width: 8),
                Text(
                  '目錄（${widget.videos.length}）',
                  style: const TextStyle(fontSize: 14, color: _gold),
                ),
                if (_loading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: _goldBorder, height: 1, thickness: 1),
          Expanded(
            child: widget.videos.isEmpty
                ? const Center(
                    child: Text(
                      '無符合項目',
                      style: TextStyle(fontSize: 13, color: _goldBorder),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.videos.length,
                    itemBuilder: (ctx, i) {
                      final v = widget.videos[i];
                      return ListTile(
                        dense: true,
                        title: Text(
                          _titleFor(v),
                          style: const TextStyle(fontSize: 14, color: _gold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => widget.onSelect(v),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

// ── 分頁導覽列 ────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int page, total;
  final ValueChanged<int> onTap;
  const _PaginationBar({
    required this.page,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _NavButton(
          icon: Icons.chevron_left,
          enabled: page > 0,
          onTap: () => onTap(page - 1),
        ),
        for (int i = 0; i < total; i++)
          _PageBtn(i: i, selected: i == page, onTap: () => onTap(i)),
        _NavButton(
          icon: Icons.chevron_right,
          enabled: page < total - 1,
          onTap: () => onTap(page + 1),
        ),
      ],
    ),
  );
}

class _PageBtn extends StatelessWidget {
  final int i;
  final bool selected;
  final VoidCallback onTap;
  const _PageBtn({
    required this.i,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _gold : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: _border,
        boxShadow: const [_navShadow],
      ),
      child: Text(
        '${i + 1}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : _gold,
        ),
      ),
    ),
  );
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: enabled ? _navDeco : _navDecoDisabled,
      child: Icon(
        icon,
        size: 18,
        color: enabled ? _gold : const Color(0x33FFD102),
      ),
    ),
  );
}

// ── 影片卡片（支援翻譯） ──────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final VideoData video;
  final AppLang lang;
  const _VideoCard({super.key, required this.video, required this.lang});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  String? _displayTitle;
  bool _loadingTranslation = false;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.video.title;
    _loadTranslation();
  }

  @override
  void didUpdateWidget(_VideoCard old) {
    super.didUpdateWidget(old);
    if (old.lang != widget.lang || old.video != widget.video) {
      _loadTranslation();
    }
  }

  Future<void> _loadTranslation() async {
    if (widget.lang == AppLang.zhTW) {
      setState(() {
        _displayTitle = widget.video.title;
        _loadingTranslation = false;
      });
      return;
    }
    setState(() => _loadingTranslation = true);
    final title = await TranslationService.translate(
      widget.video.title,
      widget.lang,
    );
    if (!mounted) return;
    setState(() {
      _displayTitle = title;
      _loadingTranslation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _displayTitle ?? widget.video.title;

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(widget.video.url);
        if (await canLaunchUrl(uri))
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        decoration: _cardDeco,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://img.youtube.com/vi/${widget.video.id}/hqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _titleAreaHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: _loadingTranslation
                    ? const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _gold,
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          title,
                          style: _titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
