import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

// ── 視覺樣式常數 ──────────────────────────────────────────────────
// Header 底色為金黃色，文字/圖示一律使用白色以確保對比。
const _gold = Color.fromARGB(255, 255, 209, 2);
const _white = Colors.white;
const _selectedBg = Colors.white;
const _barShadow = BoxShadow(
  color: Color(0x33000000),
  blurRadius: 16,
  offset: Offset(0, 4),
);
const _barDeco = BoxDecoration(
  color: _gold,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [_barShadow],
);
const _itemLabelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

// ── 導覽項目資料模型 ──────────────────────────────────────────────
class _NavItem {
  final String label;
  final String path;
  const _NavItem(this.label, this.path);
}

// 下拉選單群組：了解佛法 / 應世卷 / 滅罪卷 / 機緣道旨 / 詩摘
// 對應 main.dart GoRouter 宣告順序中的 index 1–5。
const _dropdownItems = <_NavItem>[
  _NavItem('了解佛法', AppRoutes.dharmaRealize),
  _NavItem('應世卷', AppRoutes.yingShiJuan),
  _NavItem('滅罪卷', AppRoutes.mieZuiJuan),
  _NavItem('機緣道旨妙法入門卷', AppRoutes.jiYuanDaoZhi),
  _NavItem('詩摘', AppRoutes.shiZhai),
];
const _dropdownStartIndex = 1;

// 同排項目：影音開示 / 資源連結（暫時停用） / 佛陀介紹 / 共修直播 / 課堂版影音
// 對應 main.dart GoRouter 宣告順序中的 index 6–10。
// 「資源連結」目前有問題，先用 null 佔住 index 7 的位置再略過渲染，
// 這樣後面幾個項目的 index（8、9、10）才不會因為少一筆而全部往前遞補，
// 導致 currentIndex 對不上、header 反白/勾選跑掉。
const _rowItems = <_NavItem?>[
  _NavItem('影音直播', AppRoutes.videoTeachings), // index 6
  null, // index 7：資源連結（暫時停用，錯誤排除後再復原）
  _NavItem('諦深佛陀介紹', AppRoutes.buddhaIntro), // index 8
  _NavItem('早晚課時間', AppRoutes.liveStream), // index 9
  _NavItem('課堂版影音', AppRoutes.classroomVideoTeachings), // index 10
];
const _rowStartIndex = 6;

// 首頁：對應 main.dart GoRouter 宣告順序中的 index 0。
const _homeItem = _NavItem('首頁', AppRoutes.home);
const _homeIndex = 0;

// 手機版收合選單顯示的完整清單（依原順序：首頁 + 下拉群組 + 同排群組）。
// 型別為 _NavItem? 是為了讓 _rowItems 裡的 null（資源連結）保留原本的
// index 位置，讓每個項目在陣列中的 index 仍等於 main.dart 的路由 index。
const _allNavItems = <_NavItem?>[_homeItem, ..._dropdownItems, ..._rowItems];

// ── SumeruAppBar ──────────────────────────────────────────────────
class SumeruAppBar extends StatelessWidget {
  final int currentIndex;
  const SumeruAppBar({super.key, required this.currentIndex});

  void _navigate(BuildContext context, String path) => context.go(path);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _barDeco,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          return Row(
            children: [
              _Logo(onTap: () => _navigate(context, AppRoutes.home)),
              const SizedBox(width: 16),
              Expanded(
                child: isWide
                    ? _WideNav(
                        currentIndex: currentIndex,
                        onSelect: (path) => _navigate(context, path),
                      )
                    : const SizedBox.shrink(),
              ),
              if (!isWide)
                _CompactNavMenu(
                  currentIndex: currentIndex,
                  onSelect: (path) => _navigate(context, path),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final VoidCallback onTap;
  const _Logo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/logo_with_border.png'),
            height: 36,
            width: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   '南無燃燈台上諦深佛陀',
              //   style: TextStyle(
              //     fontSize: 15,
              //     fontWeight: FontWeight.w500,
              //     color: _white,
              //     // height: 1.1,
              //     // letterSpacing: 5,
              //   ),
              // ),
              const Text(
                '須彌山佛國網',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _white,
                  height: 1.5,
                  letterSpacing: 5,
                  
                ),
              ),
              Text(
                'Namo Dishen Buddha',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 寬螢幕：下拉選單群組 + 同排項目 ──────────────────────────────
class _WideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<String> onSelect;
  const _WideNav({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _NavButton(
          label: _homeItem.label,
          selected: currentIndex == _homeIndex,
          onTap: () => onSelect(_homeItem.path),
        ),
        _DropdownNavGroup(currentIndex: currentIndex, onSelect: onSelect),
        for (int i = 0; i < _rowItems.length; i++)
          if (_rowItems[i] != null)
            _NavButton(
              label: _rowItems[i]!.label,
              selected: _rowStartIndex + i == currentIndex,
              onTap: () => onSelect(_rowItems[i]!.path),
            ),
      ],
    );
  }
}

// 直排導覽按鈕：選中時反轉為白底金字，未選中為透明底白字。
class _NavButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? _gold : _white,
          backgroundColor: selected ? _selectedBg : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: Text(label, style: _itemLabelStyle),
      ),
    );
  }
}

// ── 下拉選單群組（觸發文字：文字開示） ───────────────────────────
// 內容：了解佛法 / 應世卷 / 滅罪卷 / 機緣道旨 / 詩摘
// 滑鼠移到觸發按鈕上，或點擊觸發按鈕，都會展開金黃色底的選單。
class _DropdownNavGroup extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<String> onSelect;
  const _DropdownNavGroup({required this.currentIndex, required this.onSelect});

  @override
  State<_DropdownNavGroup> createState() => _DropdownNavGroupState();
}

class _DropdownNavGroupState extends State<_DropdownNavGroup> {
  static const _triggerLabel = '文字開示';
  static const _closeDelay = Duration(milliseconds: 150);
  // 選單與觸發按鈕（即 Header）之間的視覺間距。
  static const _menuGap = 8.0;

  final _link = LayerLink();
  OverlayEntry? _entry;
  Timer? _closeTimer;

  bool get _isActive {
    final offset = widget.currentIndex - _dropdownStartIndex;
    return offset >= 0 && offset < _dropdownItems.length;
  }

  void _cancelClose() => _closeTimer?.cancel();

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeDelay, _closeMenu);
  }

  void _closeMenu() {
    _entry?.remove();
    _entry = null;
  }

  void _toggleMenu() {
    if (_entry == null) {
      _openMenu();
    } else {
      _closeMenu();
    }
  }

  void _openMenu() {
    if (_entry != null) return;
    // 動態取得觸發按鈕（文字開示）的實際高度，讓選單位移量永遠貼合
    // Header 高度變化，不會因為寫死的數字而與 Header 重疊或間距跑掉。
    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerHeight = renderBox?.size.height ?? 44.0;
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: 220,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, triggerHeight),
          // MouseRegion 包住「間距 + 選單本體」，讓滑鼠從觸發按鈕移到選單
          // 之間，即使中間留白也仍視為懸浮中，不會提前觸發關閉。
          child: MouseRegion(
            onEnter: (_) => _cancelClose(),
            onExit: (_) => _scheduleClose(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 選單與 Header／觸發按鈕之間的間距。
                const SizedBox(height: _menuGap),
                Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [_barShadow],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < _dropdownItems.length; i++)
                          _DropdownMenuRow(
                            label: _dropdownItems[i].label,
                            selected:
                                _dropdownStartIndex + i == widget.currentIndex,
                            onTap: () {
                              widget.onSelect(_dropdownItems[i].path);
                              _closeMenu();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) {
          _cancelClose();
          _openMenu();
        },
        onExit: (_) => _scheduleClose(),
        child: GestureDetector(
          onTap: _toggleMenu,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isActive ? _selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _triggerLabel,
                    style: _itemLabelStyle.copyWith(
                      color: _isActive ? _gold : _white,
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: 18,
                    color: _isActive ? _gold : _white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 金黃色下拉選單中的單一選項列，滑過時稍微加深底色。
class _DropdownMenuRow extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DropdownMenuRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_DropdownMenuRow> createState() => _DropdownMenuRowState();
}

class _DropdownMenuRowState extends State<_DropdownMenuRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _hovering
              ? Colors.white.withOpacity(0.18)
              : Colors.transparent,
          child: Row(
            children: [
              if (widget.selected)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.check, size: 16, color: _white),
                )
              else
                const SizedBox(width: 24),
              Expanded(
                child: Text(
                  widget.label,
                  softWrap: true,
                  style: _itemLabelStyle.copyWith(color: _white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 窄螢幕：漢堡選單（依序列出下拉群組 + 同排群組） ─────────────────
class _CompactNavMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<String> onSelect;
  const _CompactNavMenu({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '導覽選單',
      icon: const Icon(Icons.menu, color: _white),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      onSelected: onSelect,
      itemBuilder: (ctx) => [
        for (int i = 0; i < _allNavItems.length; i++) ...[
          // 首頁之後、同排群組之前各加一條分隔線，維持與桌面版一致的分組。
          if (i == 1 || i == 1 + _dropdownItems.length)
            const PopupMenuDivider(),
          // 資源連結目前為 null（暫時停用），略過不顯示，但不影響其他
          // 項目的 index，currentIndex 比對才會正確。
          if (_allNavItems[i] != null)
            PopupMenuItem<String>(
              value: _allNavItems[i]!.path,
              child: Row(
                children: [
                  if (i == currentIndex)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.check, size: 16, color: _gold),
                    )
                  else
                    const SizedBox(width: 24),
                  Text(_allNavItems[i]!.label),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
