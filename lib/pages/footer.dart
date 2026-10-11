import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// ── 常數（與 AppBar 共用）────────────────────────────────────────────
// 不再有黃色底色區塊，改為透明背景，文字/分隔線改用深色系
const _kWhite = Color(0xFF3A2E1D); // 主要文字顏色（原本白字，現改深色）
const _kWhite70 = Color(0x993A2E1D); // 次要文字顏色（60% 深色）
const _kWhite20 = Color(0x1F000000); // 分隔線用色（淺灰）
const _kBlack38 = Color(0x61000000);
const _dur130 = Duration(milliseconds: 130);
const kPrimaryGold = Color(0xFFF5C518);

// ── RWD 斷點（與 AppBar 一致）────────────────────────────────────────
bool _isMobile(BuildContext ctx) => MediaQuery.sizeOf(ctx).width < 600;
bool _isTablet(BuildContext ctx) => MediaQuery.sizeOf(ctx).width < 1024;

// ── SumeruFooter ───────────────────────────────────────────────────
class SumeruFooter extends StatelessWidget {
  const SumeruFooter({super.key});

  /// 根據螢幕寬度計算水平內距
  /// mobile  < 600  → 16px（與外層頁面 padding 相同，內容不壓縮）
  /// tablet  < 1024 → 32px
  /// desktop ≥ 1024 → 最多讓內容區留到 960px，多餘空間自動置中
  EdgeInsets _hPad(BuildContext ctx) =>
      const EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        // 已取消黃色色塊底色，僅保留內距、無底色 / 無圓角
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 頂部分隔線 ────────────────────────────────────────
            const SizedBox(height: 1, child: ColoredBox(color: _kWhite20)),
            const SizedBox(height: 18),

            // ── 主要內容（社群按鈕 + 微信群組）──────────────────────
            mobile
                // 手機：垂直排列，居中，不限制自身高度
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [_SocialRow(), SizedBox(height: 16)],
                  )
                // 平板 / 桌機：橫向 Wrap
                : const Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 32,
                    runSpacing: 16,
                    children: [_SocialRow()],
                  ),

            const SizedBox(height: 18),
            const SizedBox(height: 1, child: ColoredBox(color: _kWhite20)),
            const SizedBox(height: 12),

            // ── 底部說明文字 ──────────────────────────────────────
            Text(
              '求皈依者 須持佛陀二十二戒 · 下載皈依表 · 遞交皈依表',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: mobile ? 15 : 16,
                color: const Color.fromARGB(255, 255, 213, 0),
                letterSpacing: 0.6,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 1, child: ColoredBox(color: Color.fromARGB(255, 255, 208, 0))),
            const SizedBox(height: 12),

            // ── 發心貢獻者標籤（最底部）──────────────────────────────
            // Wrap(
            //   alignment: WrapAlignment.center,
            //   spacing: 8,
            //   runSpacing: 6,
            //   children: const [
            //     _CreditTag(region: '台灣', name: '智定成', role: 'Web & App dev'),
            //     _CreditTag(region: '香港', name: '智道心', role: 'Data Collection'),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

// ── _CreditTag ─────────────────────────────────────────────────────
class _CreditTag extends StatelessWidget {
  final String region;
  final String name;
  final String role;
  const _CreditTag({
    required this.region,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kWhite20,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 地區小徽章
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: kPrimaryGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              region,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kWhite,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 5),
          Text(role, style: const TextStyle(fontSize: 11, color: _kWhite70)),
        ],
      ),
    );
  }
}

// ── _SocialRow ─────────────────────────────────────────────────────
// 目前顯示：3 個 YouTube 頻道連結、2 個網站連結、1 個 Line 群組、
// 1 個「皈依表」（點擊直接下載 xlsx，不再另開分頁預覽 Google 試算表）
class _SocialRow extends StatelessWidget {
  const _SocialRow();

  static const _kItems = [
    (
      icon: _SIcon.youtube,
      label: 'YouTube',
      url: 'https://youtube.com/@dishendashi?si=_6fYZX90qgiAqJro',
    ),
    (
      icon: _SIcon.youtube,
      label: 'YouTube',
      url: 'https://youtube.com/@namodishendashi?si=EuP4gkTyFxd1rdmn',
    ),
    (
      icon: _SIcon.youtube,
      label: 'YouTube',
      url: 'https://www.youtube.com/@Dishenbuddha',
    ),
    (
      icon: _SIcon.website,
      label: '須彌山佛國網(簡體版)',
      url: 'https://www.dishenbuddha.org/',
    ),
    (
      icon: _SIcon.website,
      label: '須彌山佛國網(正體版)',
      url: 'https://www.dishendashitw.org/',
    ),
    (
      icon: _SIcon.line,
      label: 'Line Group',
      url:
          'https://line.me/ti/g2/_F-C9oJmub6DPVx_KnLp8A-eWogzziD8AyDWLQ?utm_source=invitation&utm_medium=link_copy&utm_campaign=default',
    ),
    (
      icon: _SIcon.excel, label: '皈依表',
      // Google 試算表匯出成 xlsx 的直接下載連結（非開啟編輯畫面）
      url:
          'https://docs.google.com/spreadsheets/d/13Lt8RXVa6ZiDMBe_v6sw5xf_Nh4kxMTx/export?format=xlsx',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 手機：Wrap 自動換行；平板以上：單行 Row
    if (_isMobile(context)) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in _kItems)
            _SocialBtn(
              icon: item.icon,
              label: item.label,
              url: item.url,
              forceDownload: item.icon == _SIcon.excel,
            ),
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: [
        for (final item in _kItems)
          _SocialBtn(
            icon: item.icon,
            label: item.label,
            url: item.url,
            forceDownload: item.icon == _SIcon.excel,
          ),
      ],
    );
  }
}

// ── _SocialBtn ─────────────────────────────────────────────────────
// 樣式：金黃色外框、無底色填滿，icon 與文字皆為金黃色。
// hover 時僅將外框稍微加粗做互動回饋，仍保持透明底色。
class _SocialBtn extends StatefulWidget {
  final _SIcon icon;
  final String label;
  final String url;

  /// true 時代表此連結應直接觸發檔案下載，而非在瀏覽器分頁中開啟。
  final bool forceDownload;
  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.url,
    this.forceDownload = false,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hov = false;

  Future<void> _launch() async {
    final uri = Uri.parse(widget.url);
    if (widget.forceDownload) {
      // 使用外部應用程式模式開啟，讓瀏覽器依照 Google 匯出端點回傳的
      // Content-Disposition: attachment 標頭直接下載檔案，而不是導向
      // 新分頁去「打開」試算表編輯畫面。
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, webOnlyWindowName: '_self');
      }
      return;
    }
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: _launch,
        child: AnimatedContainer(
          duration: _dur130,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // 無底色填滿，僅金黃色外框；hover 時外框加粗作為互動回饋
            color: Colors.transparent,
            border: Border.all(color: kPrimaryGold, width: _hov ? 1.6 : 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SIconWidget(icon: widget.icon),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _WechatGroup ──────────────────────────────────────────────────
class _WechatGroup extends StatelessWidget {
  const _WechatGroup();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _dur130,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kWhite20,
        borderRadius: BorderRadius.circular(14),
      ),
      // child: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     Container(
      //       width: 34,
      //       height: 34,
      //       decoration: BoxDecoration(
      //         color: const Color(0xFF07C160),
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //       child: const Icon(Icons.chat_bubble_rounded, color: _kWhite, size: 18),
      //     ),
      //     const SizedBox(width: 10),
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       mainAxisSize: MainAxisSize.min,
      //       children: const [
      //         _WechatId(name: '如少水魚', id: '13589807963'),
      //         SizedBox(height: 4),
      //         _WechatId(name: '如救頭燃', id: '15966583597'),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}

// ── _WechatId ─────────────────────────────────────────────────────

// ── _SIcon enum & widget ──────────────────────────────────────────
enum _SIcon { line, youtube, excel, website }

class _SIconWidget extends StatelessWidget {
  final _SIcon icon;
  const _SIconWidget({required this.icon});

  @override
  Widget build(BuildContext context) {
    // icon 固定使用金黃色
    const color = kPrimaryGold;
    switch (icon) {
      case _SIcon.line:
        return _LineSvg(color: color);
      case _SIcon.youtube:
        return Icon(Icons.play_circle_fill_rounded, color: color, size: 20);
      case _SIcon.excel:
        return _ExcelSvg(color: color);
      case _SIcon.website:
        return Icon(Icons.language_rounded, color: color, size: 20);
    }
  }
}

// ── Line SVG ───────────────────────────────────────────────────────
class _LineSvg extends StatelessWidget {
  final Color color;
  const _LineSvg({required this.color});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _LinePainter(color));
}

class _LinePainter extends CustomPainter {
  final Color color;
  const _LinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final s = size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s * 0.85),
        Radius.circular(s * 0.22),
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.28, s * 0.85)
        ..lineTo(s * 0.18, s)
        ..lineTo(s * 0.48, s * 0.85)
        ..close(),
      paint,
    );
    final dot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (final cx in [s * 0.28, s * 0.50, s * 0.72]) {
      canvas.drawCircle(Offset(cx, s * 0.40), s * 0.07, dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.color != color;
}

// ── Excel SVG ──────────────────────────────────────────────────────
class _ExcelSvg extends StatelessWidget {
  final Color color;
  const _ExcelSvg({required this.color});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _ExcelPainter(color));
}

class _ExcelPainter extends CustomPainter {
  final Color color;
  const _ExcelPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.08, s * 0.08, s * 0.84, s * 0.84),
        Radius.circular(s * 0.1),
      ),
      stroke,
    );
    canvas.drawLine(
      Offset(s * 0.50, s * 0.08),
      Offset(s * 0.50, s * 0.92),
      stroke,
    );
    canvas.drawLine(
      Offset(s * 0.08, s * 0.50),
      Offset(s * 0.92, s * 0.50),
      stroke,
    );
    canvas.drawLine(
      Offset(s * 0.17, s * 0.17),
      Offset(s * 0.40, s * 0.40),
      stroke,
    );
    canvas.drawLine(
      Offset(s * 0.40, s * 0.17),
      Offset(s * 0.17, s * 0.40),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_ExcelPainter old) => old.color != color;
}
