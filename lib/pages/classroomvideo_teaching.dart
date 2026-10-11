import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'footer.dart';
// 共用資料模型與翻譯服務，沿用「影音開示」頁面已寫好的邏輯，避免與 video_teaching.dart 重複宣告
import 'video_teaching.dart'
    show VideoData, AppLang, AppLangX, TranslationService;

// ── 視覺樣式常數 ──────────────────────────────────────────────────
const _gold = Color.fromARGB(255, 255, 209, 2);
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
);

const _searchDebounce = Duration(milliseconds: 250);

// 卡片下方標題區塊固定高度（最多兩行文字 + 上下留白），
// 用來讓每張卡片維持同樣的長寬，不會因標題長短而大小不一。
const _titleAreaHeight = 64.0;
const _gridSpacing = 16.0;

// ── 課堂版影音資料 ──────────────────────────────────────────────
// AppLang / TranslationService / VideoData 已改為從 video_teaching.dart 匯入，避免重複宣告
const _videos = <VideoData>[
  VideoData(
    'bn4mmyAiQFY',
    '諦深佛陀開示 阿彌陀經',
    'https://youtu.be/bn4mmyAiQFY',
  ),
  VideoData(
    'SHHMBs9m5zU',
    '諦深佛陀開示 動成虛空 靜成世界',
    'https://youtu.be/SHHMBs9m5zU',
  ),
  VideoData(
    'bA5tVMw6ntc',
    '諦深佛陀開示 生死、三身、虛妄、妄識、清淨心',
    'https://youtu.be/bA5tVMw6ntc',
  ),
  VideoData(
    'U1ahcaxc78o',
    '諦深佛陀開示 負物質(上)',
    'https://youtu.be/U1ahcaxc78o',
  ),
  VideoData(
    '5VvYotZILEk',
    '諦深佛陀開示 負物質(下)',
    'https://youtu.be/5VvYotZILEk',
  ),
  VideoData(
    'ANUZ8r_A5g0',
    '諦深佛陀開示 鼓勵孩子出家',
    'https://youtu.be/ANUZ8r_A5g0',
  ),
  VideoData(
    '30roqQIXBCA',
    '諦深佛陀開示 為什麼會著魔(上)',
    'https://youtu.be/30roqQIXBCA',
  ),
  VideoData(
    'dwSYHvDcXCc',
    '諦深佛陀開示 為什麼會著魔(下)',
    'https://youtu.be/dwSYHvDcXCc',
  ),
  VideoData(
    'dwSYHvDcXCc',
    '諦深佛陀開示 為什麼會著魔(下)',
    'https://youtu.be/dwSYHvDcXCc',
  ),
  VideoData(
    'Xe7EM6swynI',
    '諦深佛陀開示 如何往生極樂世界',
    'https://youtu.be/Xe7EM6swynI',
  ),
  VideoData(
    'NH5zb3kAiUk',
    '諦深佛陀開示 護法護戒不護短',
    'https://youtu.be/NH5zb3kAiUk',
  ),
  VideoData(
    '0f5S4zYm0js',
    '諦深佛陀開示 佛法大乘與小乘之間的關係',
    'https://youtu.be/0f5S4zYm0js',
  ),
  VideoData(
    'vHTK3FS7Irg',
    '諦深佛陀開示 眾生生命',
    'https://youtu.be/vHTK3FS7Irg',
  ),
  VideoData(
    'YnTurkCchkE',
    '諦深佛陀開示 眾生生命(3)',
    'https://youtu.be/YnTurkCchkE',
  ),
  VideoData(
    'KWIqCyOyuzs',
    '諦深佛陀開示 誹謗的果報(上)',
    'https://youtu.be/KWIqCyOyuzs',
  ),
  VideoData(
    'uiY5md96AqY',
    '諦深佛陀開示 誹謗的果報(下)',
    'https://youtu.be/uiY5md96AqY',
  ),
  VideoData(
    'uiY5md96AqY',
    '諦深佛陀開示 誹謗的果報(下)',
    'https://youtu.be/uiY5md96AqY',
  ),
  VideoData(
    'KNlbhAEzM1c',
    '諦深佛陀開示 人身難得把握機緣',
    'https://youtu.be/KNlbhAEzM1c',
  ),
  VideoData(
    'OypPrJcO1p4',
    '諦深佛陀開示 修行之路法',
    'https://youtu.be/OypPrJcO1p4',
  ),
  VideoData(
    'ZUfKOdgBEzM',
    '諦深佛陀開示 如何教育孩子(上)',
    'https://youtu.be/ZUfKOdgBEzM',
  ),
  VideoData(
    's9d1kGzwLIw',
    '諦深佛陀開示 如何教育孩子(下)',
    'https://youtu.be/s9d1kGzwLIw',
  ),
  VideoData(
    'atlyach8jZE',
    '諦深佛陀開示 道場',
    'https://youtu.be/atlyach8jZE',
  ),
  VideoData(
    'r1kbIf-EWDk',
    '諦深佛陀開示 做個真正的出家人',
    'https://youtu.be/r1kbIf-EWDk',
  ),
  VideoData(
    'nnY-IQZO-Pk',
    '諦深佛陀開示 济公喝酒吃狗肉的果報',
    'https://youtu.be/nnY-IQZO-Pk',
  ),
  VideoData(
    'J9OtQGJi9ME',
    '諦深佛陀開示生物緣分 生物鏈 不殺戒',
    'https://youtu.be/J9OtQGJi9ME',
  ),
  VideoData(
    'ZSfTjMXd0KU',
    '諦深佛陀開示 人的轉世過程',
    'https://youtu.be/ZSfTjMXd0KU',
  ),
  VideoData(
    '2GMPxhtopAU',
    '諦深佛陀開示 居士不能講法',
    'https://youtu.be/2GMPxhtopAU',
  ),
  VideoData(
    'GnlggUK4HUQ',
    '諦深佛陀開示 命運與命運的計算',
    'https://youtu.be/GnlggUK4HUQ',
  ),
  VideoData(
    'Gs9DI3nTH6Q',
    '諦深佛陀開示 因緣果報的真實性',
    'https://youtu.be/Gs9DI3nTH6Q',
  ),
  VideoData(
    '-cesEzS7o04',
    '諦深佛陀開示 修行道中的瞋恨(上)',
    'https://youtu.be/-cesEzS7o04',
  ),
  VideoData(
    'fHou0_FhxGM',
    '諦深佛陀開示 修行道中的瞋恨(中)',
    'https://youtu.be/fHou0_FhxGM',
  ),
  VideoData(
    'hAfHPoQs2lE',
    '諦深佛陀開示 修行道中的瞋恨(下)',
    'https://youtu.be/hAfHPoQs2lE',
  ),
  VideoData(
    'C1bHrT2uv0A',
    '諦深佛陀開示 宗教與佛法之間的關係',
    'https://youtu.be/C1bHrT2uv0A',
  ),
  VideoData(
    '8OFMIsT1PAI',
    '諦深佛陀開示 金剛經、楞嚴經、法華經、華嚴經、地藏經 是什麼?',
    'https://youtu.be/8OFMIsT1PAI',
  ),
  VideoData(
    '8OFMIsT1PAI',
    '諦深佛陀開示 出家僧人三寶 在家居士三寶',
    'https://youtu.be/cWg7u9bODHU',
  ),
  VideoData(
    'ZnSS2TJWdVI',
    '諦深佛陀開示 波羅提木叉',
    'https://youtu.be/ZnSS2TJWdVI',
  ),
  VideoData(
    'uqiCfE6-Slw',
    '諦深佛陀開示 在各大宗派如何修戒',
    'https://youtu.be/uqiCfE6-Slw',
  ),
  VideoData(
    'XV8d7WSFPNA',
    '諦深佛陀開示 止靜',
    'https://youtu.be/XV8d7WSFPNA',
  ),
  VideoData(
    'DEaaTrF41nI',
    '諦深佛陀開示 在家人怎麼修',
    'https://youtu.be/DEaaTrF41nI',
  ),
  VideoData(
    'Smp3rZoLjA0',
    '諦深佛陀開示 好壞、善惡、功德與墮落',
    'https://youtu.be/Smp3rZoLjA0',
  ),
  VideoData(
    'i2HslRXOfiE',
    '諦深佛陀開示 一門超出菩提路',
    'https://youtu.be/i2HslRXOfiE',
  ),
  VideoData(
    'GcsI0ZAePgo',
    '諦深佛陀開示 法自戒中來',
    'https://youtu.be/GcsI0ZAePgo',
  ),
  VideoData(
    'UMMTEWByUzI',
    '諦深佛陀開示 什麼是狂心',
    'https://youtu.be/UMMTEWByUzI',
  ),
  VideoData(
    'mLyhzZeXdog',
    '諦深佛陀開示怎麼不上當受騙',
    'https://youtu.be/mLyhzZeXdog',
  ),
  VideoData(
    'oBOWZqCR7Kk',
    '諦深佛陀開示 以戒為師',
    'https://youtu.be/oBOWZqCR7Kk',
  ),
  VideoData(
    'aClFvjTrX2w',
    '諦深佛陀開示 物質的存在形式',
    'https://youtu.be/aClFvjTrX2w',
  ),
  VideoData(
    'tBJeMNtZrbw',
    '諦深佛陀開示如來壽量',
    'https://youtu.be/tBJeMNtZrbw',
  ),
  VideoData(
    'c2QvRJ-iHwo',
    '諦深佛陀開示 不虛妄與隨緣',
    'https://youtu.be/c2QvRJ-iHwo',
  ),
  VideoData(
    'Ky7TGtrkUAY',
    '諦深佛陀開示 戒律數學 (第一課)',
    'https://youtu.be/Ky7TGtrkUAY',
  ),
  VideoData(
    '03fKOd1YleQ',
    '諦深佛陀開示 戒律數學 戒定慧 (第二課)',
    'https://youtu.be/03fKOd1YleQ',
  ),
  VideoData(
    'niYNIc2ohII',
    '諦深佛陀開示 心中有佛就行嗎?(禪機:鐵牛叮蚊子)',
    'https://youtu.be/niYNIc2ohII',
  ),
  VideoData(
    'WtHiA0eGBSw',
    '諦深佛陀開示 了脫生死',
    'https://youtu.be/WtHiA0eGBSw',
  ),
  VideoData(
    'g8M1lXsoLrE',
    '諦深佛陀開示 佛法中眾生之間的關係',
    'https://youtu.be/g8M1lXsoLrE',
  ),
  VideoData(
    'a3anOtQKyBE',
    '諦深佛陀開示 如何念阿彌陀佛',
    'https://youtu.be/a3anOtQKyBE',
  ),
  VideoData(
    'fHNKFaGTCbc',
    '諦深佛陀開示 法與道',
    'https://youtu.be/fHNKFaGTCbc',
  ),
  VideoData(
    '0uT3-pYAGRM',
    '諦深佛陀開示 修行之路法',
    'https://youtu.be/0uT3-pYAGRM',
  ),
  VideoData(
    'tgTK6eTYZwk',
    '諦深佛陀開示 宗教體系的構成(上)',
    'https://youtu.be/tgTK6eTYZwk',
  ),
  VideoData(
    'TocNiEUDAUc',
    '諦深佛陀開示 宗教體系的構成(下)',
    'https://youtu.be/TocNiEUDAUc',
  ),
  VideoData(
    '04PhatJpIiA',
    '諦深佛陀開示 宗教爭端',
    'https://youtu.be/04PhatJpIiA',
  ),
];

// 全域翻譯快取：以「語言|影片ID」為 key，避免切換語言來回重複呼叫翻譯 API。
final Map<String, String> _translationCache = {};

Future<String> _translateCached(VideoData v, AppLang lang) async {
  if (lang == AppLang.zhTW) return v.title;
  final key = '${lang.name}|${v.id}';
  final cached = _translationCache[key];
  if (cached != null) return cached;
  final translated = await TranslationService.translate(v.title, lang);
  _translationCache[key] = translated;
  return translated;
}

int _colsForWidth(double w) {
  if (w >= 1700) return 6;
  if (w >= 1280) return 5;
  if (w >= 1000) return 4;
  if (w >= 720) return 3;
  if (w >= 480) return 2;
  return 1;
}

class ClassroomVideoTeachingsPage extends StatefulWidget {
  const ClassroomVideoTeachingsPage({super.key});

  @override
  State<ClassroomVideoTeachingsPage> createState() =>
      _ClassroomVideoTeachingsPageState();
}

class _ClassroomVideoTeachingsPageState
    extends State<ClassroomVideoTeachingsPage> {
  static const _perPage = 25;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _searchDebounceTimer;

  int _page = 0;
  String _query = '';
  AppLang _lang = AppLang.zhTW;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  List<VideoData> get _filtered {
    if (_query.isEmpty) return _videos;
    final q = _query.toLowerCase();
    return _videos
        .where((v) => v.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  int _totalPages(int len) => (len / _perPage).ceil().clamp(1, 1 << 30);

  void _goTo(int page, int total) {
    if (page == _page || page < 0 || page >= total) return;
    setState(() => _page = page);
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      if (!mounted) return;
      setState(() {
        _query = value;
        _page = 0;
      });
    });
  }

  void _jumpTo(VideoData video, List<VideoData> filtered) {
    final idx = filtered.indexOf(video);
    if (idx == -1) return;
    setState(() => _page = idx ~/ _perPage);
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _onLangChanged(AppLang lang) {
    if (lang == _lang) return;
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final total = _totalPages(filtered.length);
    final start = (_page * _perPage).clamp(0, filtered.length);
    final end = (start + _perPage).clamp(0, filtered.length);
    final pageItems = filtered.sublist(start, end);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      drawer: _IndexDrawer(
        videos: filtered,
        lang: _lang,
        onSelect: (v) => _jumpTo(v, filtered),
      ),
      body: filtered.isEmpty
          ? _EmptyState(query: _query)
          : _VideoGrid(
              videos: pageItems,
              lang: _lang,
              page: _page,
              totalPages: total,
              onPageChanged: (p) => _goTo(p, total),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    iconTheme: const IconThemeData(color: _gold),
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _SearchField(onChanged: _onSearchChanged)),
          const SizedBox(width: 10),
          _LangSwitcher(current: _lang, onChanged: _onLangChanged),
        ],
      ),
    ),
  );
}

// ── 搜尋欄 ─────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: _searchDeco,
    child: Row(
      children: [
        const Icon(Icons.search, size: 18, color: _gold),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: _gold),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: '搜尋影片標題…',
              hintStyle: TextStyle(fontSize: 13, color: _goldBorder),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── 找不到結果 ────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      '找不到符合「$query」的影片',
      style: const TextStyle(fontSize: 14, color: _goldBorder),
    ),
  );
}

// ── 影片格狀列表 + 分頁 + Footer ───────────────────────────────
class _VideoGrid extends StatelessWidget {
  final List<VideoData> videos;
  final AppLang lang;
  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _VideoGrid({
    required this.videos,
    required this.lang,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    cacheExtent: 1200,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverLayoutBuilder(
          builder: (ctx, constraints) {
            final cols = _colsForWidth(constraints.crossAxisExtent).clamp(1, 6);
            // 依欄數反推每張卡片的實際寬度，再加上縮圖(16:9) + 固定標題區高度，
            // 算出 childAspectRatio，讓 SliverGrid 產生的每一格長寬完全一致。
            final totalSpacing = _gridSpacing * (cols - 1);
            final itemWidth =
                (constraints.crossAxisExtent - totalSpacing) / cols;
            final itemHeight = itemWidth * 9 / 16 + _titleAreaHeight;
            final aspectRatio = itemWidth / itemHeight;

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: _gridSpacing,
                crossAxisSpacing: _gridSpacing,
                childAspectRatio: aspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _VideoCard(
                  key: ValueKey('${videos[i].id}_${lang.name}'),
                  video: videos[i],
                  lang: lang,
                ),
                childCount: videos.length,
              ),
            );
          },
        ),
      ),
      if (totalPages > 1)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _PaginationBar(
              page: page,
              total: totalPages,
              onTap: onPageChanged,
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SumeruFooter()),
    ],
  );
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
      itemBuilder: (ctx) => [
        for (final l in AppLang.values)
          PopupMenuItem(
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
      ],
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
    // 只翻譯尚未取得的項目，減少重複的 API 呼叫。
    final missing = widget.videos.where((v) => !_titles.containsKey(v.id));
    if (missing.isEmpty) return;

    setState(() => _loading = true);
    final results = <String, String>{};
    for (final v in missing) {
      if (!mounted) return;
      results[v.id] = await _translateCached(v, widget.lang);
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
  final int page;
  final int total;
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
    final title = await _translateCached(widget.video, widget.lang);
    if (!mounted) return;
    setState(() {
      _displayTitle = title;
      _loadingTranslation = false;
    });
  }

  Future<void> _openVideo() async {
    final uri = Uri.parse(widget.video.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _displayTitle ?? widget.video.title;

    return GestureDetector(
      onTap: _openVideo,
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
            Expanded(
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
                        alignment: Alignment.centerLeft,
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