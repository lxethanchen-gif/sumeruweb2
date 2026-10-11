import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'poems_data.dart';
import 'footer.dart';

const _gold = Color.fromARGB(255, 255, 209, 2);
const _goldLight = Color(0xFFFFFBE6);
const _goldBorder = Color(0x8CFFD102);
const _goldFaint = Color(0x4DFFD102);
const _goldDisabled = Color(0x33FFD102);
const _drawerBg = Color(0xFFFFFBE6);

const _border = Border.fromBorderSide(BorderSide(color: _goldBorder, width: 1));
const _navShadow = BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2));
const _cardShadows = [
  BoxShadow(color: Color(0x12000000), blurRadius: 20, offset: Offset(0, 4)),
  BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 1)),
];
const _cardDeco = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16)), boxShadow: _cardShadows);
const _cardDecoHighlight = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16)), border: Border.fromBorderSide(BorderSide(color: _gold, width: 2)), boxShadow: _cardShadows);
const _titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _gold, letterSpacing: 3, height: 1.2);
const _tagStyle = TextStyle(fontSize: 10, color: _goldBorder, letterSpacing: 1.5);
const _contentStyle = TextStyle(fontSize: 15, color: _gold, height: 2.1, letterSpacing: 2, fontWeight: FontWeight.w400);
const _copyLabelStyle = TextStyle(fontSize: 10, color: _gold, fontWeight: FontWeight.w600, letterSpacing: 1);
const _dividerDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0x73FFD102), Color.fromARGB(13, 255, 209, 2)]));
const _copyDecoIdle = BoxDecoration(color: _goldLight, borderRadius: BorderRadius.all(Radius.circular(20)), border: _border);
const _copyDecoCopied = BoxDecoration(color: _goldFaint, borderRadius: BorderRadius.all(Radius.circular(20)), border: _border);
const _navDeco = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), boxShadow: [_navShadow], border: _border);
const _navDecoDisabled = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), boxShadow: [_navShadow], border: Border.fromBorderSide(BorderSide(color: _goldDisabled, width: 1)));
const _searchDeco = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12)), boxShadow: [_navShadow]);
const _divider = SizedBox(height: 1, child: DecoratedBox(decoration: _dividerDeco));
const _gridPad = EdgeInsets.all(20);

class ShiZhaiPage extends StatefulWidget {
  const ShiZhaiPage({super.key});
  @override
  State<ShiZhaiPage> createState() => _ShiZhaiPageState();
}

class _ShiZhaiPageState extends State<ShiZhaiPage> {
  static const _perPage = 24;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _cardKeys = <String, GlobalKey>{};
  int _page = 0;
  String _query = '';
  String? _highlight;

  GlobalKey _keyFor(String title) => _cardKeys.putIfAbsent(title, () => GlobalKey());

  static int _cols(double w) =>
      w >= 1920 ? 8 : w >= 1700 ? 7 : w >= 1536 ? 6 : w >= 1280 ? 5 : w >= 1000 ? 4 : w >= 720 ? 3 : w >= 480 ? 2 : 1;

  List<PoemData> get _filtered {
    if (_query.isEmpty) return poems;
    final q = _query.toLowerCase();
    return poems.where((p) =>
      p.title.toLowerCase().contains(q) ||
      p.content.toLowerCase().contains(q) ||
      p.tag.toLowerCase().contains(q)
    ).toList(growable: false);
  }

  int get _totalPages => (_filtered.length / _perPage).ceil().clamp(1, double.infinity).toInt();

  List<PoemData> _pagePoemsOf(List<PoemData> f) {
    final start = (_page * _perPage).clamp(0, f.length);
    return f.sublist(start, (start + _perPage).clamp(0, f.length));
  }

  void _goTo(int p) {
    if (p != _page && p >= 0 && p < _totalPages) setState(() => _page = p);
  }

  void _onSearchChanged(String v) => setState(() { _query = v; _page = 0; });

  void _jumpToPoem(PoemData poem, List<PoemData> f) {
    final idx = f.indexOf(poem);
    if (idx == -1) return;
    setState(() { _page = idx ~/ _perPage; _highlight = poem.title; });
    _scaffoldKey.currentState?.closeDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keyFor(poem.title).currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.1, curve: Curves.easeOut);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlight = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final list = _pagePoemsOf(filtered);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        titleSpacing: 0,
        title: LayoutBuilder(builder: (ctx, c) {
          final w = (c.maxWidth - 40).clamp(0.0, c.maxWidth);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: w,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _searchDeco,
                child: Row(children: [
                  const Icon(Icons.search, size: 18, color: _gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14, color: _gold),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '搜尋標題或內容…',
                        hintStyle: TextStyle(fontSize: 13, color: _goldBorder),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        }),
      ),
      drawer: _TitleIndexDrawer(poems: filtered, onSelect: (p) => _jumpToPoem(p, filtered)),
      body: filtered.isEmpty
          ? Center(child: Text('找不到符合「$_query」的詩', style: const TextStyle(fontSize: 14, color: _goldBorder)))
          : CustomScrollView(
              cacheExtent: 1200,
              slivers: [
                SliverPadding(
                  padding: _gridPad,
                  sliver: SliverLayoutBuilder(builder: (ctx, c) {
                    final cols = _cols(c.crossAxisExtent).clamp(1, 8);
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _PoemCard(
                          key: _keyFor(list[i].title),
                          p: list[i],
                          highlighted: list[i].title == _highlight,
                        ),
                        childCount: list.length,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.78,
                      ),
                    );
                  }),
                ),
                if (_totalPages > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _PaginationBar(page: _page, total: _totalPages, onTap: _goTo),
                    ),
                  ),
                const SliverToBoxAdapter(child: SumeruFooter()),
              ],
            ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int page, total;
  final ValueChanged<int> onTap;
  const _PaginationBar({required this.page, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
      _NavButton(icon: Icons.chevron_left, enabled: page > 0, onTap: () => onTap(page - 1)),
      for (int i = 0; i < total; i++) _PageBtn(i: i, selected: i == page, onTap: () => onTap(i)),
      _NavButton(icon: Icons.chevron_right, enabled: page < total - 1, onTap: () => onTap(page + 1)),
    ]),
  );
}

class _PageBtn extends StatelessWidget {
  final int i;
  final bool selected;
  final VoidCallback onTap;
  const _PageBtn({required this.i, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36, alignment: Alignment.center,
      decoration: BoxDecoration(color: selected ? _gold : Colors.white, borderRadius: const BorderRadius.all(Radius.circular(8)), border: _border, boxShadow: const [_navShadow]),
      child: Text('${i + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : _gold)),
    ),
  );
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 36, height: 36, alignment: Alignment.center,
      decoration: enabled ? _navDeco : _navDecoDisabled,
      child: Icon(icon, size: 18, color: enabled ? _gold : _goldDisabled),
    ),
  );
}

class _TitleIndexDrawer extends StatelessWidget {
  final List<PoemData> poems;
  final ValueChanged<PoemData> onSelect;
  const _TitleIndexDrawer({required this.poems, required this.onSelect});

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    child: SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            const Icon(Icons.menu_book_rounded, size: 18, color: _gold),
            const SizedBox(width: 8),
            Text('目錄（${poems.length}）', style: const TextStyle(fontSize: 14, color: _gold)),
          ]),
        ),
        _divider,
        Expanded(
          child: poems.isEmpty
              ? const Center(child: Text('無符合項目', style: TextStyle(fontSize: 13, color: _goldBorder)))
              : ListView.builder(
                  itemCount: poems.length,
                  itemBuilder: (ctx, i) => ListTile(
                    dense: true,
                    title: Text(poems[i].title, style: const TextStyle(fontSize: 14, color: _gold)),
                    subtitle: Text(poems[i].tag, style: const TextStyle(fontSize: 10, color: _goldBorder)),
                    onTap: () => onSelect(poems[i]),
                  ),
                ),
        ),
      ]),
    ),
  );
}

class _PoemCard extends StatefulWidget {
  final PoemData p;
  final bool highlighted;
  const _PoemCard({super.key, required this.p, this.highlighted = false});
  @override
  State<_PoemCard> createState() => _PoemCardState();
}

class _PoemCardState extends State<_PoemCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: '${widget.p.title}\n${widget.p.tag}\n\n${widget.p.content}'));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copied = false); });
  }

  void _showFull() {
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
                Expanded(child: Text(widget.p.title, style: _titleStyle)),
                IconButton(icon: const Icon(Icons.close, color: _gold, size: 20), onPressed: () => Navigator.of(ctx).pop()),
              ]),
              const SizedBox(height: 4),
              Text(widget.p.tag, style: _tagStyle),
              const SizedBox(height: 12),
              _divider,
              const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(child: Text(widget.p.content, style: _contentStyle))),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: widget.highlighted ? _cardDecoHighlight : _cardDeco,
    padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: Text(widget.p.title, style: _titleStyle, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _copy,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: _copied ? _copyDecoCopied : _copyDecoIdle,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_copied ? Icons.check : Icons.copy_rounded, size: 12, color: _gold),
              const SizedBox(width: 3),
              Text(_copied ? '已複製' : '複製', style: _copyLabelStyle),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 4),
      Text(widget.p.tag, style: _tagStyle),
      const SizedBox(height: 12),
      _divider,
      const SizedBox(height: 14),
      Expanded(
        child: ClipRect(
          child: Text(widget.p.content, style: _contentStyle, overflow: TextOverflow.fade, softWrap: true),
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _showFull,
          child: const Icon(Icons.unfold_more_rounded, size: 18, color: _goldBorder),
        ),
      ),
    ]),
  );
}