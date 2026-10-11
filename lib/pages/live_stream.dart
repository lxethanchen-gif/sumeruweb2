import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'footer.dart';

// ─── 道場布置圖片 ─────────────────────────────────────────────

class _ShrineImage {
  final String label;
  final String assetPath; // 放在 assets/ 資料夾下
  final String downloadUrl;

  const _ShrineImage({
    required this.label,
    required this.assetPath,
    required this.downloadUrl,
  });
}

// 請將三張圖片放入 assets/ 資料夾，並在 pubspec.yaml 中宣告
// assets:
//   - assets/shrine_altar.jpg
//   - assets/dizhen_buddha.png
//   - assets/shakyamuni_buddha.png
const List<_ShrineImage> kShrineImages = [
  _ShrineImage(
    label: '道場總覽',
    assetPath: 'assets/shrine_altar.jpg',
    downloadUrl: '', // 可替換為實際下載連結
  ),
  _ShrineImage(
    label: '諦深佛陀',
    assetPath: 'assets/dizhen_buddha.png',
    downloadUrl: '',
  ),
  _ShrineImage(
    label: '釋迦牟尼佛',
    assetPath: 'assets/shakyamuni_buddha.png',
    downloadUrl: '',
  ),
];

// ─── 常數 ────────────────────────────────────────────────────

const double kBreakpoint = 720.0;

// ─── 色彩系統（與 video_teaching.dart / yingshijuan.dart 統一）───
const Color kGold = Color(0xFFF5C518); // 主要金色：標題、圖示、強調文字
const Color kGoldDim = Color(0xFFB8960E); // 次要金色：內文、說明文字
const Color kGoldBorder = Color(0x59F5C518); // 卡片邊框／分隔線（35%）
const Color kGoldBorderSoft = Color(0x33F5C518); // 更淡的分隔線（20%）
const Color kGoldBg = Color(0x14F5C518); // 極淡金色底，用於強調區塊背景

const BoxShadow kCardShadow = BoxShadow(
  color: Color(0x14000000),
  blurRadius: 10,
  offset: Offset(0, 4),
);
const BoxDecoration kCardDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [kCardShadow],
);

const TextStyle kSectionTitleStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kGold,
  letterSpacing: 0.3,
);
const TextStyle kBadgeTextStyle = TextStyle(
  fontSize: 11.5,
  fontWeight: FontWeight.w600,
  color: kGoldDim,
  letterSpacing: 0.5,
);
const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 13,
  color: kGoldDim,
  height: 1.6,
);

// ─── 佛陀二十二戒 ─────────────────────────────────────────────

const String k22PreceptTitle = '諦深佛陀 二十二戒';
const List<String> k22Precepts = [
  '1、不殺生，不食眾生肉，不與殺生人共住！不予人眾生肉！',
  '2、不盜，不取非人予財物，不觀路之有遺！',
  '3、不淫，不與罪人，外道人乃至畜牲男共住！不沾染或被人沾染！不與父母兄弟姊妹情感沾染！',
  '4、不妄，遇事除職責中不說，當知有說即妄！若為道修，道行，道延故可證說！',
  '5、不貪，於種種官權、於財物，乃至衣物，不做少許用外多求多想！',
  '6、不嗔，不於種種逆、種種難，有不順思、不順想或不如意想！更何有報復想！',
  '7、不癡，不做道外、戒外、用外、理外，非貪著悅己外思，更況有做有行！',
  '8、不慢，於種種因、種種緣、種種果、種種報，不興有比對、比較、比量思，更況貶視有餘！',
  '9、事師尊長，對一切三寶相，親里長者遇當以事緣之，尊敬緣之！',
  '10、威儀，行駐坐臥皆應有被譽之功！並有多效仿！',
];
const String k22PreceptsNote =
    '何者我之戒：一者尊重僧，二者入寺院，三者不表說，四者多請法，五者遠惡交，六者遠邪說，'
    '七者遠狂者，八者遠爭鬥，九者遠議論，十者護僧道，十一護道場，十二不說過。';

// ─── 資料模型 ───────────────────────────────────────────────

class ScheduleItem {
  final String name;
  final List<VideoLink> links;
  final bool show22Precepts;

  const ScheduleItem({
    required this.name,
    this.links = const [],
    this.show22Precepts = false,
  });
}

class VideoLink {
  final String label;
  final String videoId;
  const VideoLink({required this.label, required this.videoId});
}

class ScheduleSection {
  final String time;
  final String title;
  final IconData icon;
  final List<ScheduleItem> items;
  final String? dividerLabel;
  final bool showMorningBook;

  const ScheduleSection({
    required this.time,
    required this.title,
    required this.icon,
    required this.items,
    this.dividerLabel,
    this.showMorningBook = false,
  });
}

// ─── 時程資料 ────────────────────────────────────────────────

const List<ScheduleSection> kSchedule = [
  ScheduleSection(
    time: '03:30 – 04:00',
    title: '上殿',
    icon: Icons.notifications_outlined,
    items: [ScheduleItem(name: '集眾上殿，準備早課')],
  ),
  ScheduleSection(
    time: '04:00 – 05:00',
    title: '早課',
    icon: Icons.wb_sunny_outlined,
    dividerLabel: '燃香拜佛',
    showMorningBook: true,
    items: [
      ScheduleItem(name: '三拜 → 燃香 → 上香 → 三拜'),
      ScheduleItem(name: '南無清淨法身毗盧遮那佛　三拜'),
      ScheduleItem(name: '南無圓滿報身盧舍那佛　三拜'),
      ScheduleItem(name: '南無千百億化身釋迦牟尼佛　三拜'),
      ScheduleItem(name: '南無燃燈台上諦深佛　三拜'),
      ScheduleItem(name: '誦佛陀二十二戒（二十二戒表）', show22Precepts: true),
      ScheduleItem(
        name: '誦楞嚴咒 ＋ 大悲咒 ＋ 十小咒',
        links: [
          VideoLink(label: '妙湛寺早課', videoId: 'UD96W58-OBk'),
          VideoLink(label: '地藏法會早課', videoId: 'u4_B2CkGu2Y'),
          VideoLink(label: '繁體版早課', videoId: 'V7DizEefNYk'),
        ],
      ),
    ],
  ),
  ScheduleSection(
    time: '05:00 – 05:30',
    title: '繞佛・念佛送歸音',
    icon: Icons.loop_outlined,
    items: [
      ScheduleItem(
        name: '繞佛念佛，誦歸音',
        links: [VideoLink(label: '念佛送歸音', videoId: '9Oq0Cu41J-s')],
      ),
    ],
  ),
  ScheduleSection(
    time: '早齋',
    title: '四遍金剛經',
    icon: Icons.menu_book_outlined,
    items: [
      ScheduleItem(
        name: '爐香讚 ＋ 四遍金剛經',
        links: [
          VideoLink(label: '爐香讚', videoId: 'ebGTCDYE-Ro'),
          VideoLink(label: '四遍金剛經', videoId: 'u3w4w8y8XFc'),
        ],
      ),
    ],
  ),
  ScheduleSection(
    time: '11:00',
    title: '午齋（大齋）',
    icon: Icons.lunch_dining_outlined,
    items: [
      ScheduleItem(
        name: '五觀齋',
        links: [VideoLink(label: '五觀齋', videoId: 'Vwg_aaernvo')],
      ),
    ],
  ),
  ScheduleSection(
    time: '15:30',
    title: '晚課',
    icon: Icons.nightlight_outlined,
    items: [
      ScheduleItem(
        name: '彌陀經 ＋ 八十八佛 ＋ 拜願',
        links: [
          VideoLink(label: '妙湛寺晚課', videoId: 'w75UmXmoUEQ'),
          VideoLink(label: '繁體版晚課', videoId: 'Z4p2Q4y0MMo'),
          VideoLink(label: '拜願', videoId: '6hwD781YjK4'),
        ],
      ),
    ],
  ),
  ScheduleSection(
    time: '18:00',
    title: '入禪堂・打薩',
    icon: Icons.door_front_door_outlined,
    items: [ScheduleItem(name: '入禪堂，開始打薩')],
  ),
  ScheduleSection(
    time: '19:00 – 21:00',
    title: '坐香',
    icon: Icons.self_improvement_outlined,
    items: [
      ScheduleItem(
        name: '靜坐禪修（止法）',
        links: [VideoLink(label: '止法', videoId: 'M-i_BWiU_nE')],
      ),
    ],
  ),
];

const List<VideoLink> kOtherVideos = [
  VideoLink(label: '寶鼎讚', videoId: '4lPwMTBp-VI'),
  VideoLink(label: '叩鐘偈', videoId: 'cxOc-Lsr35o'),
];

// ─── 經書連結 ────────────────────────────────────────────────

class SutraLink {
  final String label;
  final String url;
  final String thumbnailUrl;

  const SutraLink({
    required this.label,
    required this.url,
    required this.thumbnailUrl,
  });
}

// 圖示直接取自 Google Drive 檔案的縮圖（依 file id 產生）
const List<SutraLink> kSutraLinks = [
  SutraLink(
    label: '早晚課 課誦本',
    url:
        'https://drive.google.com/file/d/1imuOwJApX2BaZlz3Y9z8ivV5aeVhyihX/view?usp=sharing',
    thumbnailUrl:
        'https://drive.google.com/thumbnail?id=1imuOwJApX2BaZlz3Y9z8ivV5aeVhyihX&sz=w400',
  ),
  SutraLink(
    label: '地藏菩薩本願經',
    url:
        'https://drive.google.com/file/d/1BPq5MsFlpIfHb3xYYykcITt7t8awJwyZ/view?usp=sharing',
    thumbnailUrl:
        'https://drive.google.com/thumbnail?id=1BPq5MsFlpIfHb3xYYykcITt7t8awJwyZ&sz=w400',
  ),
];

const String kTopVideoId = 'xjdmGS6S7fs';
const String kBottomVideoId = 'GibAHSiCJPI';
const String kDownloadUrl =
    'https://drive.google.com/uc?export=download&id=1QcuIl8dYK2odBnLf3drbcH06BRDElqr8';

// ─── 主頁面 ──────────────────────────────────────────────────

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  YoutubePlayerController? _activeController;
  String? _activeVideoId;

  void _playVideo(String videoId) {
    if (_activeVideoId == videoId) {
      _activeController?.close();
      setState(() {
        _activeController = null;
        _activeVideoId = null;
      });
      return;
    }
    _activeController?.close();
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
    setState(() {
      _activeController = controller;
      _activeVideoId = videoId;
    });
  }

  @override
  void dispose() {
    _activeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const ui.Color.fromARGB(255, 255, 255, 255),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kBreakpoint;
          final contentWidth = isWide
              ? constraints.maxWidth * 2 / 3
              : constraints.maxWidth;
          final hPadding = isWide
              ? (constraints.maxWidth - contentWidth) / 2
              : 12.0;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Column(
                  children: [
                    // ── 頂部提示列
                    const SizedBox(height: 10),

                    // ── 早晚課持續時間影片
                    _OuterCard(
                      child: Column(
                        children: [
                          _SectionHeader(
                            time: '參考影片',
                            title: '早晚課持續時間',
                            // icon: Icons.play_circle_outline,
                            isFirst: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: _ThumbnailPlayer(videoId: kTopVideoId),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── 道場布置卡
                    const _ShrineCard(),
                    const SizedBox(height: 10),

                    // ── 共修時程大卡
                    _OuterCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: kGoldBorderSoft,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: kGoldBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: kGoldBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 17,
                                    color: kGold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '共修時程表',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: kGold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '每日作息，依序共修',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: kGoldDim,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ...kSchedule.asMap().entries.map((entry) {
                            return _ScheduleSectionBlock(
                              section: entry.value,
                              activeVideoId: _activeVideoId,
                              activeController: _activeController,
                              onPlay: _playVideo,
                              isFirst: entry.key == 0,
                              isLast: entry.key == kSchedule.length - 1,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── 其他資源卡
                    _OuterCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            time: '其他資源',
                            title: '寶鼎讚・叩鐘偈',
                            // icon: Icons.music_note_outlined,
                            isFirst: true,
                          ),
                          ...kOtherVideos.map((v) {
                            final isActive = _activeVideoId == v.videoId;
                            return _ScheduleItemRow(
                              name: v.label,
                              links: [v],
                              activeVideoId: _activeVideoId,
                              activeController: _activeController,
                              onPlay: _playVideo,
                              show22Precepts: false,
                              showDivider: true,
                            );
                          }),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── 法會影片
                    _OuterCard(
                      child: Column(
                        children: [
                          _SectionHeader(
                            time: '法會影片',
                            title: '地藏菩薩本願經',
                            // icon: Icons.import_contacts_outlined,
                            isFirst: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: _ThumbnailPlayer(videoId: kBottomVideoId),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 經書下載小圖示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: kSutraLinks
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: _SutraDownloadIcon(sutra: s),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SumeruFooter(),
            ],
          );
        },
      ),
    );
  }
}

// ─── 道場布置卡片 ─────────────────────────────────────────────

class _ShrineCard extends StatelessWidget {
  const _ShrineCard();

  static const List<Map<String, String>> _items = [
    {'text': '諦深佛陀、釋迦牟尼佛 相片 各一張'},
    {'text': '器具（香爐、油燈碗、花供、果盤、水器、金色布）'},
    {'text': '香油燈用油（純芝麻香油）、沉檀香'},
  ];

  @override
  Widget build(BuildContext context) {
    return _OuterCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            time: '道場布置',
            title: '道場布置器具',
            // icon: Icons.home_outlined,
            isFirst: true,
          ),

          // ── 三張圖片橫排
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                _ShrineImageTile(
                  assetPath: 'assets/images/6301.jpg',
                  label: '道場總覽',
                ),
                const SizedBox(width: 8),
                _ShrineImageTile(
                  assetPath: 'assets/images/dishen_buddha.jpg',
                  label: '諦深佛陀',
                ),
                const SizedBox(width: 8),
                _ShrineImageTile(
                  assetPath: 'assets/images/shakyamuni_buddha.jpg',
                  label: '釋迦牟尼佛',
                ),
              ],
            ),
          ),

          // ── 布置說明清單
          Divider(height: 1, thickness: 1, color: kGoldBorderSoft),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _items.asMap().entries.map((e) {
                final isLast = e.key == _items.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6, right: 10),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: kGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value['text']!, style: kBodyTextStyle),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 道場圖片磁磚（含下載按鈕）────────────────────────────────

class _ShrineImageTile extends StatelessWidget {
  final String assetPath;
  final String label;

  const _ShrineImageTile({required this.assetPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // 圖片區
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(assetPath, fit: BoxFit.cover),
                  // 下載按鈕（右上角）
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          // 圖片標籤
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kGoldDim,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── 經書下載小圖示（圖示取自 Google Drive 縮圖） ───────────────

class _SutraDownloadIcon extends StatelessWidget {
  final SutraLink sutra;
  const _SutraDownloadIcon({required this.sutra});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(sutra.url),
        mode: LaunchMode.externalApplication,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  color: kGoldBg,
                  child: Image.network(
                    sutra.thumbnailUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kGold,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 26,
                        color: kGold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: kGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.download_outlined,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              sutra.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kGoldDim,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 外層白卡 ─────────────────────────────────────────────────

class _OuterCard extends StatelessWidget {
  final Widget child;
  const _OuterCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDeco,
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

// ─── Section 標題 ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String time;
  final String title;
  // final IconData icon;
  final bool isFirst;

  const _SectionHeader({
    required this.time,
    required this.title,
    // required this.icon,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: kGoldBorderSoft, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 時間膠囊徽章
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGoldBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGoldBorder, width: 1),
            ),
            child: Text(time, style: kBadgeTextStyle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: kSectionTitleStyle),
          ),
        ],
      ),
    );
  }
}

// ─── 時程區塊（時間軸排版） ──────────────────────────────────

class _ScheduleSectionBlock extends StatelessWidget {
  final ScheduleSection section;
  final String? activeVideoId;
  final YoutubePlayerController? activeController;
  final void Function(String) onPlay;
  final bool isFirst;
  final bool isLast;

  const _ScheduleSectionBlock({
    required this.section,
    required this.activeVideoId,
    required this.activeController,
    required this.onPlay,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, isFirst ? 16 : 0, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 時間欄
            SizedBox(
              width: 60,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  section.time,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: kGoldDim,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── 時間軸節點與連接線
            Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kGoldBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: kGoldBorder, width: 1),
                  ),
                  child: Icon(section.icon, size: 15, color: kGold),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: kGoldBorderSoft,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── 內容欄
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 16 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(section.title, style: kSectionTitleStyle),
                    ),

                    if (section.dividerLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          section.dividerLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kGold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                    if (section.items.isNotEmpty) const SizedBox(height: 10),

                    ...section.items.asMap().entries.map((e) {
                      final isLastItem = e.key == section.items.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: isLastItem ? 0 : 12,
                        ),
                        child: _TimelineItem(
                          item: e.value,
                          activeVideoId: activeVideoId,
                          activeController: activeController,
                          onPlay: onPlay,
                        ),
                      );
                    }),

                    // 早晚課共修本下載列
                    if (section.showMorningBook) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: kGoldBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kGoldBorder, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              color: kGold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                '早晚課共修本',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kGold,
                                ),
                              ),
                            ),
                            _GoldChip(
                              label: '下載',
                              icon: Icons.download_outlined,
                              onTap: () => launchUrl(
                                Uri.parse(kDownloadUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 時間軸內容項目（名稱、影片 Chip、下方全寬播放器） ────────

class _TimelineItem extends StatelessWidget {
  final ScheduleItem item;
  final String? activeVideoId;
  final YoutubePlayerController? activeController;
  final void Function(String) onPlay;

  const _TimelineItem({
    required this.item,
    required this.activeVideoId,
    required this.activeController,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final activeLink = item.links
        .where((v) => v.videoId == activeVideoId)
        .firstOrNull;
    final isActive = activeLink != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: kBodyTextStyle),
        if (item.links.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.links
                .map(
                  (v) => _GoldChip(
                    label: v.label,
                    icon: activeVideoId == v.videoId
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    onTap: () => onPlay(v.videoId),
                    active: activeVideoId == v.videoId,
                  ),
                )
                .toList(),
          ),
        ],
        if (isActive && activeController != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: activeController!),
            ),
          ),
        ],
        if (item.show22Precepts) ...[
          const SizedBox(height: 10),
          const _PreceptsCard(),
        ],
      ],
    );
  }
}

// ─── 單一項目列 ───────────────────────────────────────────────

class _ScheduleItemRow extends StatelessWidget {
  final String name;
  final List<VideoLink> links;
  final String? activeVideoId;
  final YoutubePlayerController? activeController;
  final void Function(String) onPlay;
  final bool show22Precepts;
  final bool showDivider;

  const _ScheduleItemRow({
    required this.name,
    required this.links,
    required this.activeVideoId,
    required this.activeController,
    required this.onPlay,
    required this.show22Precepts,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final activeLink = links
        .where((v) => v.videoId == activeVideoId)
        .firstOrNull;
    final isActive = activeLink != null;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) Divider(height: 1, thickness: 1, color: kGoldBorderSoft),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 金色小圓點
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: kBodyTextStyle),
                    if (links.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: links
                            .map(
                              (v) => _GoldChip(
                                label: v.label,
                                icon: activeVideoId == v.videoId
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                onTap: () => onPlay(v.videoId),
                                active: activeVideoId == v.videoId,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // 播放器（右側）
              if (isActive && activeController != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 200,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: YoutubePlayer(controller: activeController!),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (show22Precepts)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: const _PreceptsCard(),
          ),
      ],
    );

    return content;
  }
}

// ─── 金色 Chip ────────────────────────────────────────────────

class _GoldChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _GoldChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? kGoldBg : Colors.white,
          border: Border.all(color: kGoldBorder, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: kGold),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: kGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 縮圖播放器（固定在卡片內，點擊開啟 YouTube） ───────────────

class _ThumbnailPlayer extends StatelessWidget {
  final String videoId;
  const _ThumbnailPlayer({required this.videoId});

  @override
  Widget build(BuildContext context) {
    final thumbUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    return Column(
      children: [
        GestureDetector(
          onTap: () => launchUrl(
            Uri.parse('https://www.youtube.com/watch?v=$videoId'),
            mode: LaunchMode.externalApplication,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    thumbUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: kGoldBg,
                      child: const Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: kGold,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '點擊前往 YouTube 觀看',
          style: TextStyle(fontSize: 11, color: kGoldDim),
        ),
      ],
    );
  }
}

// ─── 佛陀二十二戒卡片 ────────────────────────────────────────

class _PreceptsCard extends StatelessWidget {
  const _PreceptsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: kGoldBg,
        border: Border.all(color: kGoldBorder, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              k22PreceptTitle,
              style: TextStyle(
                color: kGold,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...k22Precepts.asMap().entries.map((e) {
            final isLast = e.key == k22Precepts.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(e.value, style: kBodyTextStyle),
                ),
                if (!isLast)
                  Divider(height: 1, thickness: 1, color: kGoldBorderSoft),
              ],
            );
          }),
          const SizedBox(height: 8),
          Text(
            k22PreceptsNote,
            style: const TextStyle(
              color: kGoldDim,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}