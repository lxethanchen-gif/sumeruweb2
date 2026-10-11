import 'dart:async';
import 'package:flutter/material.dart';
import 'footer.dart';

// ── 風格常數（與 yingshijuan.dart 一致）────────────────────────
const _kGold    = Color(0xFFF5C518);
const _kGoldDim = Color(0xFFB8960E);

class BuddhaIntroPage extends StatelessWidget {
  const BuddhaIntroPage({super.key});

  static const _intro = '''諦深大師俗姓呂，淨土獲證，禪宗傳承。上乘清淨願力為諦，下令眾生世界業障破滅稱深。諦深法號為佛光普照神僧呼喚所得。落髮戒名釋迦妙生，祖籍山東即墨。佛曆2506年11月18日（農曆壬寅年11月18日）生於遼寧省瓦房店，生後至3歲不會說話，會講話後秉性甚憨，家人以為有疾！後因文革風暴，隨父母回遷祖籍。

1、26歲與當地寺院結緣，時寺內無出家人住。

2、初入寺廟助僧賣票，因離家太遠，夜於院外會計室獨自休息，忽見牆體虛盡，佛光普照，有神僧獅子吼音三稱諦深，因此得名。

3、入寺前未見過經書亦未入過其它寺院，不懂佛門諸事。其後，多與佛門道人來往，並獲結緣《金剛經》，於居士處獲《華嚴經》、於寺得《法華經》、於居士處獲《楞嚴經》。

4、與一出家道僧緣分甚大，並為其所動獨自發心出家，於山底被一拉比丘尼車送之寶寺，當夜見韋陀菩薩顯聖，翌日下山。

5、首訪大乘寺，未入山門即聞鐘鼓齊鳴，天人誦經，禁不住讚曰：「好聽，好聽，好聽！」時大乘寺只一道僧與其弟子兩人止住！於次日夜韋陀菩薩贈無字真經。

6、於租住屋內見一草履蟲附於牆體，便薰香送之，草履蟲忽然落於地上行將斃命，此時，手不能動，香條被彎曲，急念佛號並於床下拜佛。

7、於深夜，猛然金紅光地藏菩薩顯聖，居然並不認得，問出家人並見其形象與地藏殿地藏菩薩一樣，只是呈紅金瑞相，方知是大願地藏菩薩示現。

8、於住處研《楞嚴經》，一日居士來訪，正碰小雨，有術士不用火源，雨中以手指點燃浸濕報紙，見後忽明《楞嚴經》中「性火真空，性空真火，周遍法界、遍虛空界，隨眾生心應所知量」，大喜，時撐傘圍觀者數十。

9、於住處閱《楞嚴經》，世界虛盡放大光明。

10、2001年應戒，於夢中見一高大琉璃廟宇轟然倒塌，於伽藍殿跪香一夜，不久，駐山並行腳四方。''';

  static const _images = [
    'assets/images/buddha_1.jpg',
    'assets/images/buddha_2.png',
    'assets/images/buddha_3.png',
    'assets/images/buddha_4.png',
    'assets/images/2453.jpg',
    'assets/images/6175.jpg',
    'assets/images/6176.jpg',
    'assets/images/6177.jpg',
    'assets/images/6178.jpg',
    'assets/images/6179.jpg',
    'assets/images/6180.jpg',
    'assets/images/6181.jpg',
    'assets/images/6182.jpg',
    'assets/images/6183.jpg',
    'assets/images/6184.jpg',
    'assets/images/6185.jpg',
    'assets/images/6186.jpg',
    'assets/images/6187.jpg',
    'assets/images/6188.jpg',
    'assets/images/6189.jpg',
    'assets/images/6190.jpg',
    'assets/images/6191.jpg',
    'assets/images/6192.jpg',
    'assets/images/6193.jpg',
    'assets/images/6194.jpg',
    'assets/images/6195.jpg',
    'assets/images/6196.jpg',
    'assets/images/6197.jpg',
    'assets/images/6198.jpg',
    'assets/images/6199.jpg',
    'assets/images/6200.jpg',
    'assets/images/6201.jpg',
    'assets/images/6301.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isDesktop = w >= 1024;
            final isTablet = w >= 600 && w < 1024;
            // Desktop: 兩欄（左圖右文）；Tablet/Mobile: 單欄（上圖下文）
            return isDesktop
                ? _DesktopLayout(images: _images, intro: _intro)
                : isTablet
                    ? _TabletLayout(images: _images, intro: _intro)
                    : _MobileLayout(images: _images, intro: _intro);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 共用常數
// ─────────────────────────────────────────
const _bgNav = Color(0xFFFDF8EE);

// ─────────────────────────────────────────
// 共用元件
// ─────────────────────────────────────────
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.titleSize, required this.subtitleSize});
  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '諦深大師簡介',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: _kGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '淨土獲證・禪宗傳承',
            style: TextStyle(
              fontSize: subtitleSize,
              color: _kGoldDim,
              letterSpacing: 1.5,
            ),
          ),
        ],
      );
}

class _IntroText extends StatelessWidget {
  const _IntroText({required this.intro, required this.fontSize});
  final String intro;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text(
        intro,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: _kGold,
          height: 1.7,
        ),
      );
}

// ─────────────────────────────────────────
// 自動輪播圖：一次顯示 3 張，定時自動滑動、無限循環
// ─────────────────────────────────────────
class _AutoCarousel extends StatefulWidget {
  const _AutoCarousel({
    required this.images,
    required this.height,
    this.spacing = 12,
    this.aspectRatio = 0.85,
    this.interval = const Duration(seconds: 3),
  });

  final List<String> images;
  final double height;
  final double spacing;
  final double aspectRatio;
  final Duration interval;

  @override
  State<_AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<_AutoCarousel> {
  // 用一個很大的頁數讓 PageView 看起來像無限循環
  static const _kLoopMultiplier = 100000;
  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _kLoopMultiplier ~/ 2);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.images.length <= 1) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    final n = widget.images.length;
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: _kLoopMultiplier,
        itemBuilder: (context, page) => Row(
          children: List.generate(3, (i) {
            final imgIndex = (page + i) % n;
            final isLast = i == 2;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isLast ? 0 : widget.spacing,
                ),
                child: _CarouselImage(
                  path: widget.images[imgIndex],
                  aspectRatio: widget.aspectRatio,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CarouselImage extends StatelessWidget {
  const _CarouselImage({required this.path, required this.aspectRatio});
  final String path;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                color: _bgNav,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kGold),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: _kGold, size: 32),
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────
// Desktop：上方輪播圖 + 下方文字
// ─────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.images, required this.intro});
  final List<String> images;
  final String intro;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AutoCarousel(
                    images: images,
                    height: 280,
                    spacing: 16,
                    aspectRatio: 0.82,
                  ),
                  const SizedBox(height: 36),
                  const _TitleBlock(titleSize: 28, subtitleSize: 14),
                  const SizedBox(height: 24),
                  _IntroText(intro: intro, fontSize: 15),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SumeruFooter(),
          ],
        ),
      );
}

// ─────────────────────────────────────────
// Tablet：上方輪播圖 + 下方文字
// ─────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.images, required this.intro});
  final List<String> images;
  final String intro;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.only(top: 36, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AutoCarousel(
                    images: images,
                    height: 220,
                    spacing: 12,
                    aspectRatio: 0.95,
                  ),
                  const SizedBox(height: 32),
                  const _TitleBlock(titleSize: 24, subtitleSize: 13),
                  const SizedBox(height: 20),
                  _IntroText(intro: intro, fontSize: 15),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SumeruFooter(),
          ],
        ),
      );
}

// ─────────────────────────────────────────
// Mobile：上方輪播圖 + 下方文字（緊湊）
// ─────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.images, required this.intro});
  final List<String> images;
  final String intro;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AutoCarousel(
                    images: images,
                    height: 130,
                    spacing: 8,
                    aspectRatio: 0.85,
                  ),
                  const SizedBox(height: 24),
                  const _TitleBlock(titleSize: 22, subtitleSize: 13),
                  const SizedBox(height: 16),
                  _IntroText(intro: intro, fontSize: 14),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SumeruFooter(),
          ],
        ),
      );
}