import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  List<SanityGlossaryTerm> _terms = [];
  List<SanityGlossaryTerm> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final terms = await SanityService.fetchGlossary();
      if (mounted) setState(() { _terms = terms; _filtered = terms; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _terms
          : _terms.where((t) => t.term.toLowerCase().contains(q) || t.definition.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group by first letter
    final Map<String, List<SanityGlossaryTerm>> grouped = {};
    for (final t in _filtered) {
      final letter = t.term.isNotEmpty ? t.term[0].toUpperCase() : '#';
      grouped.putIfAbsent(letter, () => []).add(t);
    }
    final letters = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Glossary', style: AppTextStyles.h4()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: AppDecorations.card(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textLight, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search terms...',
                        hintStyle: AppTextStyles.body(color: AppColors.textLight),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.body(color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filtered.isEmpty
                    ? Center(child: Text('No terms found', style: AppTextStyles.body()))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: letters.fold<int>(0, (sum, l) => sum + 1 + (grouped[l]?.length ?? 0)),
                        itemBuilder: (_, i) {
                          int count = 0;
                          for (final letter in letters) {
                            if (i == count) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8),
                                child: Text(letter, style: AppTextStyles.h4(color: AppColors.primary)),
                              );
                            }
                            count++;
                            final items = grouped[letter]!;
                            if (i < count + items.length) {
                              return _TermTile(term: items[i - count]);
                            }
                            count += items.length;
                          }
                          return const SizedBox();
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TermTile extends StatefulWidget {
  final SanityGlossaryTerm term;
  const _TermTile({required this.term});

  @override
  State<_TermTile> createState() => _TermTileState();
}

class _TermTileState extends State<_TermTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.term.term, style: AppTextStyles.label(color: AppColors.textDark))),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textLight),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(widget.term.definition, style: AppTextStyles.body()),
            ],
          ],
        ),
      ),
    );
  }
}
