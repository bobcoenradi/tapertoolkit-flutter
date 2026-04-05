import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<SanityFaq> _faqs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final faqs = await SanityService.fetchFaqs();
      if (mounted) setState(() { _faqs = faqs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group by category
    final Map<String, List<SanityFaq>> grouped = {};
    for (final f in _faqs) {
      final cat = f.category ?? 'General';
      grouped.putIfAbsent(cat, () => []).add(f);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('FAQs', style: AppTextStyles.h4()),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _faqs.isEmpty
              ? Center(child: Text('No FAQs yet', style: AppTextStyles.body()))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: grouped.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(entry.key, style: AppTextStyles.h4()),
                      ),
                      ...entry.value.map((f) => _FaqTile(faq: f)),
                      const SizedBox(height: 8),
                    ],
                  )).toList(),
                ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final SanityFaq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: AppDecorations.card(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(widget.faq.question, style: AppTextStyles.label(color: AppColors.textDark)),
                  ),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.remove : Icons.add, color: AppColors.primary, size: 20),
                ],
              ),
            ),
            if (_expanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(widget.faq.answer, style: AppTextStyles.body()),
              ),
          ],
        ),
      ),
    );
  }
}
