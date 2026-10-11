import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'dart:async';
import 'footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class VideoLink {
  final String title;
  final String url;
  const VideoLink(this.title, this.url);
}

class _HomePageState extends State<HomePage> {
  final Color _gold = const Color.fromARGB(255, 246, 214, 30);
  final Color _goldDim = const Color.fromARGB(90, 246, 214, 30);

  final List<String> _carouselImages = [
    'assets/images/2453.jpg',
    'assets/images/6176_0.jpg',
    'assets/images/6175_0.jpg',
    'assets/images/6176_0.jpg',
    'assets/images/6177_0.jpg',
    'assets/images/6178_0.jpg',
    'assets/images/6179_0.jpg',
    'assets/images/6181_0.jpg',
    'assets/images/6182_0.jpg',
    'assets/images/6183_0.jpg',
    'assets/images/6184_0.jpg',
    'assets/images/6185_0.jpg',
    'assets/images/6186_0.jpg',
    'assets/images/6187_0.jpg',
    'assets/images/6188_0.jpg',
    'assets/images/6189_0.jpg',
    'assets/images/6190_0.jpg',
    'assets/images/6191_0.jpg',
    'assets/images/6192_0.jpg',
    'assets/images/6193_0.jpg',
    'assets/images/6194_0.jpg',
    'assets/images/6195_0.jpg',
    'assets/images/6196_0.jpg',
    'assets/images/6197_0.jpg',
    'assets/images/6198_0.jpg',
    'assets/images/6199_0.jpg',
    'assets/images/6200_0.jpg',
    'assets/images/6201_0.jpg',
  ];

  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;
  bool _userInteracting = false;

  // ── 影片分頁狀態 ──────────────────────────────────────────
  int _videoPage = 0;
  int _videoPage2 = 0; // 第二個「最新開示」版面的獨立分頁狀態
  static const int _videosPerPage = 16;

  static bool _iframeRegistered = false;

  // ── 直播串流網址 ──────────────────────────────────────────
  // 改用 YouTube 官方內嵌播放器（iframe embed）：觀眾點擊播放時
  // 影片會直接在網頁裡面的影片框內播放，不會跳轉到 youtube.com。
  // 換直播時只要把這裡換成新的 YouTube 網址即可，程式會自動
  // 從網址中取出影片 ID 並更新內嵌播放器。
  static const String _liveStreamUrl =
      'https://www.youtube.com/live/ew0PgNXOrQk?si=5VqK3MLawj0ivmsI';

  // static const String _announcementText =
  //     '法務處關於成立 世界佛法修證靈異協會理事會的通知：\n\n'
  //     '報名條件\n\n'
  //     '真正的出家或受菩薩戒大居士並具有以下修行境地的\n'
  //     '1. 能禪坐兩天以上，並能入定不起於座的僧人、大居士；\n'
  //     '2. 能嚴淨毗尼法，能行神變、能給大眾無時間間隔治病，並隨時演示驗證於當事人的僧人、大居士；\n'
  //     '3. 能演說經法不起於座的僧人！所謂演說經法是：將釋迦牟尼佛所說經法，現場演示給廣大眾生看，並與經中所說對應，稱為演說！\n\n'
  //     '另外，諦深和尚的資深弟子，亦可作為報名資格條件！\n\n'
  //     '須彌山佛國網、妙湛寺流亡僧侶法務處！2026.9.3';

  static const List<VideoLink> _videoCards = [
    VideoLink('諦深佛陀開示 2026/8/30 權力使徒 ', 'https://youtu.be/25I07fOtbUY'),
    VideoLink('諦深佛陀開示 韋馱菩薩 因地做何行 立何願而成就 ', 'https://youtu.be/3pnUaLfWNjw'),
    VideoLink('諦深佛陀開示 2026/5/1 人類滅亡的三大本質', 'https://youtu.be/AbOQCAM1yLY'),
    VideoLink(
      '諦深佛陀開示 2026/4/19 世界未來的走向、修行人如何修行',
      'https://youtu.be/IM7mE1US8-0',
    ),
    VideoLink('諦深佛陀開示 2026/4/16 消滅共產黨 建立民主國家', 'https://youtu.be/6OrrrXTL1y4'),
    VideoLink('諦深佛陀開示 2026/4/11 嚴厲批評鄭麗文拜見習近平', 'https://youtu.be/LipQH3HQMTA'),
    VideoLink(
      '諦深佛陀開示 2026/4/2 給美國、歐盟 各個國家文明陣營中的政要們最後一個慈悲開示',
      'https://youtu.be/DpVzYUMunDw',
    ),
    VideoLink(
      '諦深佛陀開示 2026/4/1 伊朗戰爭給美國給世界帶來了什麼?',
      'https://youtu.be/d-aCek8pEbc',
    ),
    VideoLink('諦深佛陀開示 2026/3/28 如何積功德', 'https://youtu.be/wj_zju3ms8Q'),
    VideoLink('諦深佛陀開示 2026/3/24 實妄、理妄、現實妄、不定報', 'https://youtu.be/7l6sop15BCM'),
    VideoLink('諦深佛陀開示 2026/3/24 共產黨的惡犬遍布全世界', 'https://youtu.be/Xp9UHcq5N7Q'),
    VideoLink('諦深佛陀開示 2026/3/21 師父為什麼關注戰爭', 'https://youtu.be/d2fx4qIFeNs'),
    VideoLink('諦深佛陀開示 2026/3/21 川普攻打伊朗會怎麼收場', 'https://youtu.be/4ls4gi_uLW0'),
    VideoLink('諦深佛陀開示 2026/3/20 願聽不聽', 'https://youtu.be/d-aCek8pEbc'),
    VideoLink('諦深佛陀開示 2026/2/6 台灣獲救 ', 'https://youtu.be/poPIFKQdEJQ'),
    VideoLink(
      '諦深佛陀開示 2026/2/2 張又俠為什麼不能造反 中國軍隊為什麼不會造反?',
      'https://youtu.be/r6PRti3gCRo',
    ),
    VideoLink('諦深佛陀開示 2026/1/30 菩薩道-信任', 'https://youtu.be/2kSmOjFkYMo'),
    VideoLink('諦深佛陀開示 2026/1/11 共產黨的報應快到', 'https://youtu.be/SHql6vKHZxk'),
    // 2026------------------------------------------------------------------------------------------
    VideoLink(
      '諦深佛陀開示 2025/12/30 修清淨法 台灣發生戰爭怎麼辦?',
      'https://youtu.be/s_YgO0zz6n8',
    ),
    VideoLink('諦深佛陀開示 2025/12/23 什麼是權力與政治', 'https://youtu.be/W-_EWKOqzho'),
    VideoLink('諦深佛陀開示 2025/12/21 在家修行能成就嗎?', 'https://youtu.be/PpY5VQ_vkK0'),
    VideoLink('諦深佛陀開示 2025/12/1 概率AI都是因果', 'https://youtu.be/PfGXXqWSAx0'),
    VideoLink('諦深佛陀開示 2025/11/1 如何往去善世界', 'https://youtu.be/N2aQqTl1d0U'),
    VideoLink('諦深佛陀開示 2025/10/30 養殖業的緣分', 'https://youtu.be/b8D2icesbfM'),
    VideoLink('諦深佛陀開示 2025/10/19 公平與和平', 'https://youtu.be/Zpqis7rMq3Y'),
    VideoLink('諦深佛陀開示 2025/10/15 聯合國為什麼認不清共產黨', 'https://youtu.be/n__oPcKZ3xQ'),
    VideoLink(
      '諦深佛陀開示 2025/10/15 聯合國為什麼認不清共產黨的邪惡本質',
      'https://youtu.be/n__oPcKZ3xQ',
    ),
    VideoLink(
      '諦深佛陀開示 2025/10/14 共產黨為什麼以殺好人為手段',
      'https://youtu.be/K3cOaNDJx6Y',
    ),
    VideoLink('諦深佛陀開示 2025/10/13 相對論', 'https://youtu.be/POdrB629ISA'),
    VideoLink('諦深佛陀開示 2025/10/13 拯救末世、拯救末世眾生', 'https://youtu.be/MjFHIl9v0uU'),
    VideoLink('諦深佛陀開示 2025/10/12 須彌山與相對論', 'https://youtu.be/IceEbJQjLRk'),
    VideoLink('諦深佛陀開示 2025/10/8 探討維基百科的真實性', 'https://youtu.be/siCUBUzAzkw'),
    VideoLink(
      '諦深佛陀開示 2025/10/4 為人民服務是共產黨奴役百姓的畫皮工具',
      'https://youtu.be/elBbwY2iSyU',
    ),
    VideoLink(
      '諦深佛陀開示 2025/10/3 認清共產黨的邪惡本質 中國人一定要覺醒',
      'https://youtu.be/17EkzQ0PrEU',
    ),
    VideoLink(
      '諦深佛陀開示 2025/9/28 達爾文進化論的科學與夢是什麼',
      'https://youtu.be/YNOJvc28Fck',
    ),
    VideoLink(
      '諦深佛陀開示 2025/9/21 共產黨邪惡的罪證--無業遊民',
      'https://youtu.be/q9rL3W_vfpY',
    ),
    VideoLink('諦深佛陀開示 2025/9/20 愚蠢是社會進步的唯一動力', 'https://youtu.be/VhwpQZJDNJ0'),
    VideoLink('諦深佛陀開示 2025/9/19 地獄的本質', 'https://youtu.be/N185Rh_g1mg'),
    VideoLink(
      '諦深佛陀開示 2025/9/18 冤冤相報何時了(台灣應該如何立足)',
      'https://youtu.be/7ZwpMvNvaZU',
    ),
    VideoLink('諦深佛陀開示 2025/9/17 面對共產黨該怎麼做', 'https://youtu.be/kiEUrtPpx5c'),
    VideoLink('諦深佛陀開示 2025/9/13 六道輪迴', 'https://youtu.be/dgHys5_6Baw'),
    VideoLink('諦深佛陀開示 2025/9/7 為什麼全世界都在屏蔽佛陀', 'https://youtu.be/n8cEM_RwQKg'),
    VideoLink(
      '諦深佛陀開示 2025/9/7 共產黨的活人器官足以供給全世界',
      'https://youtu.be/IDn64Uct7V0',
    ),
    VideoLink('諦深佛陀開示 2025/9/5 寧做一秒人 不做萬年龜', 'https://youtu.be/fNvnlwVndko'),
    VideoLink(
      '諦深佛陀開示 2025/9/5 希望全世界認清共產黨遠超納粹法西斯反人類罪的真面目',
      'https://youtu.be/Mkwnuzub5JI',
    ),
    VideoLink('諦深佛陀開示 2025/8/29 共產黨的邪惡本質', 'https://youtu.be/SptcymCE1Jg'),
    VideoLink('諦深佛陀開示 2025/8/28 靜電屏蔽帶 堅決不能使用', 'https://youtu.be/TmraX3CYIIs'),
    VideoLink(
      '諦深佛陀開示 2025/8/27 天機不可洩漏(台灣為何始終擺脫不了共產黨)',
      'https://youtu.be/XaFOsbqevs4',
    ),
    VideoLink('諦深佛陀開示 2025/8/27 佛陀為什麼不移民日本', 'https://youtu.be/bYUvecGK1y0'),
    VideoLink(
      '諦深佛陀開示 2025/8/26 中國佛教協會通告不能誹謗國主',
      'https://youtu.be/N7O_NRdzb2s',
    ),
    VideoLink('諦深佛陀開示 2025/8/19 談AI與硅基生命', 'https://youtu.be/XXz8UZbGXEQ'),
    VideoLink('諦深佛陀開示 2025/8/16 修行要關羅漢地品', 'https://youtu.be/e6ZOV4lSCGY'),
    VideoLink('諦深佛陀開示 2025/8/7 如何不看視頻', 'https://youtu.be/eZa029yv49Y'),
    VideoLink('諦深佛陀開示 2025/8/5 傳承與如何獲得傳承', 'https://youtu.be/9fms2VVgBWU'),
    VideoLink('諦深佛陀開示 2025/8/5 傳承與如何獲得傳承', 'https://youtu.be/9fms2VVgBWU'),
    VideoLink('諦深佛陀開示 2025/7/31 佛難之時不能斷滅慈悲種', 'https://youtu.be/txY3AObl34Q'),
    VideoLink('諦深佛陀開示 2025/7/30 修行一定不要落入邪途', 'https://youtu.be/ZXTUIg7xQ80'),
    VideoLink('諦深佛陀開示 2025/7/28 釋永信被抓 出家人怎麼說', 'https://youtu.be/YCE4snpAW_8'),
    VideoLink('諦深佛陀開示 2025/7/18 審判習近平', 'https://youtu.be/mXG-oEj8tG8'),
    VideoLink(
      '諦深佛陀開示 2025/7/17 文明底線 道德底線 人性底線',
      'https://youtu.be/a3G7rVsdd8Y',
    ),
    VideoLink(
      '諦深佛陀開示 2025/7/13 如何消滅獨裁組織是人類進步的關鍵',
      'https://youtu.be/A6_9E6Momh0',
    ),
    VideoLink(
      '諦深佛陀開示 2025/6/29 (5/29)佛難的因緣與未來世界的果報',
      'https://youtu.be/s9A_-aH3z6Y',
    ),
    VideoLink('諦深佛陀開示 2025/6/15 建爐(煉丹品 二)', 'https://youtu.be/Nk0y9x0AXf0'),
    VideoLink(
      '諦深佛陀開示 2025/6/9 為什麼油管以政治、宗教的理由屏蔽佛陀',
      'https://youtu.be/v9GITeBvtbY',
    ),
    VideoLink('諦深佛陀開示 2025/6/6 佛門事件 地獄成品', 'https://youtu.be/gsS8Iw3kOL4'),
    VideoLink('諦深佛陀開示 2025/6/5 台灣會怎麼滅亡', 'https://youtu.be/Zmp1xcra2Gk'),
    VideoLink('諦深佛陀開示 2025/5/29 共產黨血洗佛門', 'https://youtu.be/IlzAa-OOgeM'),
    VideoLink('諦深佛陀開示 2025/5/25 煉丹的基礎(煉丹品 二)', 'https://youtu.be/wR7dVoHC890'),
    VideoLink('諦深佛陀開示 2024/4/17 在台灣玉山為佛陀建寺院', 'https://youtu.be/DrY6G623UC0'),
    VideoLink('諦深佛陀開示 2023/11/19 殉道', 'https://youtu.be/WdixrFq6fZs'),
    VideoLink('諦深佛陀開示 去意障的良藥', 'https://youtu.be/LfvDTilMlYI'),
  ];

  // ── 「座下弟子實修實證」影片清單 ───────────────────────────
  // 在下面依同樣格式新增 VideoLink('標題', '網址') 即可加入更多影片
  static const List<VideoLink> _discipleVideoCards = [
    VideoLink('座下弟子智心 實修實證', 'https://youtu.be/Wi0iu41-d-4'),
    VideoLink('座下弟子智禪境 實修實證', 'https://youtu.be/IIjqBOApcDk'),
    VideoLink('座下弟子智印連 實修實證', 'https://youtu.be/wZM4MgDzJ3g'),
    VideoLink('座下弟子智禪妙 實修實證', 'https://youtu.be/xKEAh3-NTrY'),
    VideoLink('座下弟子從萍 實修實證', 'https://youtu.be/8xHCwBh9r10'),
    VideoLink('座下弟子智確 實修實證', 'https://youtu.be/OaibjOrscB8'),
    VideoLink('座下弟子智確 實修實證', 'https://youtu.be/LvFaj60MyKU'),
    VideoLink('座下弟子智法常 實修實證', 'https://youtu.be/qQK6KMk4LfY'),
    VideoLink('座下弟子智明常 實修實證', 'https://youtu.be/GAMdxgtD2l0'),
    VideoLink('座下弟子智恩 實修實證', 'https://youtu.be/TXP5cudivYc'),
    VideoLink('座下弟子智道宜 實修實證', 'https://youtu.be/AHot-enbJgE'),
    VideoLink('座下弟子智法哲 實修實證', 'https://youtu.be/vxnVx8JMjsU'),
    VideoLink('座下弟子智本田 實修實證', 'https://youtu.be/bnt6-kcyagw'),
    VideoLink('座下弟子智禪妙 實修實證', 'https://youtu.be/sHroZ-en-wo'),
    VideoLink('座下弟子智法敏 實修實證', 'https://youtu.be/QduiRIMRkIg'),
    VideoLink('座下弟子智田 實修實證', 'https://youtu.be/o-BLudxH-NM'),
    VideoLink('座下弟子智田 實修實證', 'https://youtu.be/o-BLudxH-NM'),
    VideoLink('座下弟子智印蓮 實修實證', 'https://youtu.be/fFjblXrZUYA'),
    VideoLink('座下弟子智宜 實修實證', 'https://youtu.be/YlxVslOAJUk'),
    VideoLink('座下弟子智宜 實修實證', 'https://youtu.be/YlxVslOAJUk'),
    VideoLink('座下弟子智法覺 實修實證', 'https://youtu.be/tTCncy0h4TE'),
    VideoLink('座下弟子智法明 實修實證', 'https://youtu.be/ZJL-137s7Cs'),
    VideoLink('座下弟子智禪覺 實修實證', 'https://youtu.be/_-r8AFhx8rw'),
    VideoLink('座下弟子智道剛 實修實證', 'https://youtu.be/_mZjHeGKSVY'),
    VideoLink('座下弟子智道剛 實修實證', 'https://youtu.be/_mZjHeGKSVY'),
    VideoLink('座下弟子智安 實修實證', 'https://youtu.be/94OlFzwVnv0'),
    VideoLink('座下弟子智蓉 實修實證', 'https://youtu.be/nuZMWcc3__4'),
    VideoLink('座下弟子智禪律 實修實證', 'https://youtu.be/m8smoi97uf0'),
    VideoLink('座下弟子智禪元 實修實證', 'https://youtu.be/OsJF7SGhhmQ'),
    VideoLink('座下弟子智定圓 實修實證', 'https://youtu.be/19thohxXxzs'),
    VideoLink('座下弟子智演樂 實修實證', 'https://youtu.be/8jbR437HqP8'),
    VideoLink('座下弟子智檀實 實修實證', 'https://youtu.be/27G0QHHA6i4'),
    VideoLink('座下弟子智道曉 實修實證', 'https://youtu.be/RuFqOr3lMeM'),
    VideoLink('座下弟子智屬 實修實證', 'https://youtu.be/HPfAvfY-5UA'),
    VideoLink('座下弟子智道是 實修實證', 'https://youtu.be/mnxiPjEjvDU'),
    VideoLink('座下弟子智道真 實修實證', 'https://youtu.be/LSLnqQG2xQE'),
    VideoLink('座下弟子智然 實修實證', 'https://youtu.be/r_bcg3t_-3w'),
    VideoLink('生命可以再來一次', 'https://youtu.be/C-wW-Q2P_7s'),
    VideoLink('座下弟子智道觀 實修實證', 'https://youtu.be/3CQV7DwfSik'),
    VideoLink('座下弟子智瀾 實修實證', 'https://youtu.be/1zxbudPTAo0'),
    VideoLink('座下弟子智法照 實修實證', 'https://youtu.be/1zxbudPTAo0'),
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    // 輪播圖已從畫面移除，不需要啟動自動輪播計時器
    // _startCarouselTimer();
    _registerIframe();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _userInteracting) return;
      if (!_carouselController.hasClients) return;
      final next = (_currentCarouselIndex + 1) % _carouselImages.length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _registerIframe() {
    if (_iframeRegistered) return;
    _iframeRegistered = true;
    final liveVideoId = _extractYoutubeId(_liveStreamUrl) ?? '';
    ui.platformViewRegistry.registerViewFactory(
      'youtube-player',
      (int viewId) => html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$liveVideoId?autoplay=0'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute(
          'allow',
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
        )
        ..allowFullscreen = true,
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  // ── 輪播圖 ────────────────────────────────────────────────
  Widget _buildCarousel(double contentWidth) {
    // RWD：寬螢幕 16:9，窄螢幕(<480) 4:3
    final isNarrow = contentWidth < 480;
    final aspectRatio = isNarrow ? (4 / 3) : (16 / 9);
    final carouselHeight = contentWidth * (1 / aspectRatio);

    return Column(
      children: [
        GestureDetector(
          onPanDown: (_) {
            _userInteracting = true;
            _carouselTimer?.cancel();
          },
          onPanEnd: (_) {
            _userInteracting = false;
            _startCarouselTimer();
          },
          onPanCancel: () {
            _userInteracting = false;
            _startCarouselTimer();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: contentWidth,
              height: carouselHeight,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _carouselController,
                    onPageChanged: (i) =>
                        setState(() => _currentCarouselIndex = i),
                    itemCount: _carouselImages.length,
                    itemBuilder: (_, i) => Image.asset(
                      _carouselImages[i],
                      fit: BoxFit.cover,
                      width: contentWidth,
                      height: carouselHeight,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black26,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: _gold,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 左右箭頭（只在寬螢幕顯示）
                  if (!isNarrow) ...[
                    _arrowButton(
                      icon: Icons.chevron_left,
                      alignment: Alignment.centerLeft,
                      onTap: () {
                        final prev =
                            (_currentCarouselIndex -
                                1 +
                                _carouselImages.length) %
                            _carouselImages.length;
                        _carouselController.animateToPage(
                          prev,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    _arrowButton(
                      icon: Icons.chevron_right,
                      alignment: Alignment.centerRight,
                      onTap: () {
                        final next =
                            (_currentCarouselIndex + 1) %
                            _carouselImages.length;
                        _carouselController.animateToPage(
                          next,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                  // 左下角頁碼
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentCarouselIndex + 1} / ${_carouselImages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Dot indicators（超過 15 張改用 line indicator 避免爆版）
        _carouselImages.length <= 15 ? _dotIndicators() : _lineIndicator(),
      ],
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required Alignment alignment,
    required VoidCallback onTap,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _dotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _carouselImages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentCarouselIndex == i ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentCarouselIndex == i ? _gold : _goldDim,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _lineIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 4,
        child: LinearProgressIndicator(
          value: (_currentCarouselIndex + 1) / _carouselImages.length,
          backgroundColor: _goldDim,
          valueColor: AlwaysStoppedAnimation<Color>(_gold),
        ),
      ),
    );
  }

  // ── 內容區塊（最新公告，純文字布告欄）──────────────────────
  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _goldDim, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題列
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _goldDim)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: _gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: _gold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // 公告內容（純文字）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              content,
              style: TextStyle(
                color: _gold,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── 從 YouTube 連結取得影片 ID ─────────────────────────────
  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    // 支援 https://www.youtube.com/live/VIDEOID 及 /embed/VIDEOID 這類網址
    final segments = uri.pathSegments;
    final markerIndex = segments.indexWhere((s) => s == 'live' || s == 'embed');
    if (markerIndex != -1 && markerIndex + 1 < segments.length) {
      return segments[markerIndex + 1];
    }
    return null;
  }

  // ── 響應式欄數：依內容寬度決定每列顯示幾張卡片 ───────────────
  int _videoCrossAxisCount(double contentWidth) {
    if (contentWidth < 480) return 2; // 手機
    if (contentWidth < 800) return 3; // 平板
    return 4; // 桌機
  }

  void _goToVideoPage(
    int page,
    int pageCount,
    int currentPage,
    ValueChanged<int> onPageChanged,
  ) {
    if (page < 0 || page >= pageCount || page == currentPage) return;
    onPageChanged(page);
  }

  // ── 影片卡片區塊（RWD 欄數 + 每頁 24 部分頁）───────────────
  // page / onPageChanged 讓同一個版面可以被重複使用、各自維護獨立的分頁狀態
  Widget _buildVideoIconCards(
    double contentWidth,
    List<VideoLink> videos, {
    String title = '最新開示',
    required int page,
    required ValueChanged<int> onPageChanged,
  }) {
    final crossAxisCount = _videoCrossAxisCount(contentWidth);
    const spacing = 16.0;
    final cardWidth =
        (contentWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

    final pageCount = (videos.length / _videosPerPage).ceil().clamp(1, 1 << 30);
    final safePage = page.clamp(0, pageCount - 1);
    final start = safePage * _videosPerPage;
    final end = (start + _videosPerPage).clamp(0, videos.length);
    final pageVideos = videos.sublist(start, end);

    final hasPrev = safePage > 0;
    final hasNext = safePage < pageCount - 1;

    // 窄螢幕時箭頭改放在網格外側上方，避免蓋住卡片
    final isNarrow = contentWidth < 480;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_outline, color: _gold, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: _gold,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            if (pageCount > 1)
              Text(
                '${safePage + 1} / $pageCount',
                style: TextStyle(
                  color: _gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isNarrow && pageCount > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _videoPageButton(
                  icon: Icons.chevron_left,
                  enabled: hasPrev,
                  onTap: () => _goToVideoPage(
                    safePage - 1,
                    pageCount,
                    safePage,
                    onPageChanged,
                  ),
                ),
                const SizedBox(width: 16),
                _videoPageButton(
                  icon: Icons.chevron_right,
                  enabled: hasNext,
                  onTap: () => _goToVideoPage(
                    safePage + 1,
                    pageCount,
                    safePage,
                    onPageChanged,
                  ),
                ),
              ],
            ),
          ),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final v in pageVideos)
                  SizedBox(width: cardWidth, child: _videoIconCard(v)),
              ],
            ),
            // 寬螢幕：箭頭疊在網格左右兩側
            if (!isNarrow && pageCount > 1) ...[
              Positioned(
                left: -20,
                child: _videoPageButton(
                  icon: Icons.chevron_left,
                  enabled: hasPrev,
                  onTap: () => _goToVideoPage(
                    safePage - 1,
                    pageCount,
                    safePage,
                    onPageChanged,
                  ),
                ),
              ),
              Positioned(
                right: -20,
                child: _videoPageButton(
                  icon: Icons.chevron_right,
                  enabled: hasNext,
                  onTap: () => _goToVideoPage(
                    safePage + 1,
                    pageCount,
                    safePage,
                    onPageChanged,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _videoPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? Colors.black45 : Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white38,
          size: 26,
        ),
      ),
    );
  }

  Widget _videoIconCard(VideoLink video) {
    final videoId = _extractYoutubeId(video.url);
    return GestureDetector(
      onTap: () => _launchURL(video.url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: videoId == null
                  ? Container(
                      color: const Color(0xFFF0F0F0),
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : Image.network(
                      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                video.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _gold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    double contentWidth = w > 1100 ? 1000 : w * 0.95;
    // 寬螢幕時，最新開示的換頁箭頭會疊在卡片區塊外側（左右各凸出 20px 的按鈕半徑），
    // 因此需要較大的外側留白讓箭頭完整顯示，不被邊界擋住；窄螢幕箭頭改放在網格上方，維持原本留白即可。
    final double hPadding = contentWidth < 480 ? 24 : 44;
    // 校正：contentWidth 不能超過扣除左右留白後的實際可用寬度，
    // 否則手機版卡片寬度算法（cardWidth／crossAxisCount）會用到比實際容器還寬的數值，
    // 導致每列只塞得下 1 張卡片、右側出現大片空白。
    contentWidth = contentWidth.clamp(0.0, w - hPadding * 2).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 標題 ────────────────────────────────────────
                  Text(
                    '諦深佛陀 2026年8月1日 現場直播開示',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: w > 600 ? 30 : 22,
                      fontWeight: FontWeight.bold,
                      color: _gold,
                      letterSpacing: 1.2,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 現場直播（YouTube 內嵌播放器）─────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: contentWidth,
                      height: contentWidth * 9 / 16,
                      child: const HtmlElementView(viewType: 'youtube-player'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── 最新公告 ──────────────────────────────────────
                  // SizedBox(
                  //   width: contentWidth,
                  //   child: _buildSection(
                  //     title: '最新公告',
                  //     content: _announcementText,
                  //     icon: Icons.campaign_outlined,
                  //   ),
                  // ),
                  const SizedBox(height: 24),

                  // ── 影片小卡片（RWD 欄數 + 分頁）────────────────
                  SizedBox(
                    width: contentWidth,
                    child: _buildVideoIconCards(
                      contentWidth,
                      _videoCards,
                      page: _videoPage,
                      onPageChanged: (p) => setState(() => _videoPage = p),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── 影片小卡片（第二版面：座下弟子實修實證）─────
                  SizedBox(
                    width: contentWidth,
                    child: _buildVideoIconCards(
                      contentWidth,
                      _discipleVideoCards,
                      title: '座下弟子實修實證',
                      page: _videoPage2,
                      onPageChanged: (p) => setState(() => _videoPage2 = p),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          const SumeruFooter(),
        ],
      ),
    );
  }
}
