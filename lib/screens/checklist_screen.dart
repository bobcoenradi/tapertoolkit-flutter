import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<SanityChecklistItem> _items = [];
  Set<String> _checked = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await SanityService.fetchChecklist();
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('checklist_checked') ?? [];
      if (mounted) setState(() {
        _items = items;
        _checked = saved.toSet();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String id) async {
    setState(() {
      if (_checked.contains(id)) {
        _checked.remove(id);
      } else {
        _checked.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('checklist_checked', _checked.toList());
  }

  @override
  Widget build(BuildContext context) {
    final completed = _checked.length;
    final total = _items.length;

    final Map<String, List<SanityChecklistItem>> grouped = {};
    for (final item in _items) {
      final cat = item.category ?? 'General';
      grouped.putIfAbsent(cat, () => []).add(item);
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
        title: Text('Checklist', style: AppTextStyles.h4()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          if (total > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(color: AppColors.primarySoft),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pre-taper readiness', style: AppTextStyles.label()),
                        Text('$completed / $total', style: AppTextStyles.label(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _items.isEmpty
                    ? Center(child: Text('No checklist items yet', style: AppTextStyles.body()))
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: grouped.entries.map((entry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, top: 8),
                              child: Text(entry.key, style: AppTextStyles.h4()),
                            ),
                            ...entry.value.map((item) => _CheckItem(
                              item: item,
                              checked: _checked.contains(item.id),
                              onToggle: () => _toggle(item.id),
                            )),
                            const SizedBox(height: 8),
                          ],
                        )).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final SanityChecklistItem item;
  final bool checked;
  final VoidCallback onToggle;
  const _CheckItem({required this.item, required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(color: checked ? AppColors.primarySoft : Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                color: checked ? AppColors.primary : Colors.transparent,
                border: Border.all(color: checked ? AppColors.primary : AppColors.textLight, width: 1.5),
              ),
              child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.label(color: checked ? AppColors.primary : AppColors.textDark),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(item.description!, style: AppTextStyles.body()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
