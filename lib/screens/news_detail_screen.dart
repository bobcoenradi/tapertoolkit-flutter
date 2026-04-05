import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';

class NewsDetailScreen extends StatelessWidget {
  final SanityNewsItem item;
  const NewsDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final date = item.publishedAt != null ? DateTime.tryParse(item.publishedAt!) : null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: item.imageUrl != null ? 220 : 0,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: item.imageUrl != null
                ? FlexibleSpaceBar(background: Image.network(item.imageUrl!, fit: BoxFit.cover))
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(4)),
                        child: Text(item.tag.toUpperCase(), style: AppTextStyles.caption(color: AppColors.primary).copyWith(letterSpacing: 0.8)),
                      ),
                      const SizedBox(width: 8),
                      if (date != null) Text(DateFormat('MMM dd, yyyy').format(date), style: AppTextStyles.caption()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.title, style: AppTextStyles.h2()),
                  const SizedBox(height: 8),
                  Text(item.excerpt, style: AppTextStyles.bodyLarge(color: AppColors.textMid)),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),
                  Text(_extractText(item.body) ?? item.excerpt, style: AppTextStyles.bodyLarge()),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _extractText(dynamic body) {
    if (body is! List) return null;
    final buffer = StringBuffer();
    for (final block in body) {
      if (block is Map && block['_type'] == 'block') {
        final children = block['children'] as List? ?? [];
        for (final child in children) {
          if (child is Map) buffer.write(child['text'] ?? '');
        }
        buffer.write('\n\n');
      }
    }
    final result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }
}
