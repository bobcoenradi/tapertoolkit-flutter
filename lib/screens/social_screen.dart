import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';
import 'forum_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  List<SanityTopic> _topics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final topics = await SanityService.fetchTopics();
      if (!mounted) return;
      setState(() { _topics = topics; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_loading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))),
              )
            else ...[
              SliverToBoxAdapter(child: _buildSectionLabel('FORUMS')),
              SliverToBoxAdapter(child: _buildTopics()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text('Social', style: AppTextStyles.h3()),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(label, style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.2)),
    );
  }

  Widget _buildTopics() {
    final list = _topics.isNotEmpty
        ? _topics
        : _defaultTopics.map((t) => SanityTopic(id: t.$1, title: t.$2, description: t.$3, icon: t.$4)).toList();
    return Column(
      children: list.map((t) => _TopicTile(
        topic: t,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForumScreen(topic: t))),
      )).toList(),
    );
  }

  static const _defaultTopics = [
    ('news-announcements',  'News & Announcements', 'Updates, research, and community news from the team.', 'news'),
    ('symptom-management',  'Symptom Management',   'Strategies, tracking, and peer support for daily challenges.', 'chart'),
    ('success-stories',     'Success Stories',      'Celebrating milestones and final tapers from our community.', 'star'),
    ('wellness-tips',       'Wellness Tips',         'Nutrition, sleep, and mindfulness practices during taper.', 'fitness'),
    ('general-discussion',  'General Discussion',    'Connect with others on anything not covered elsewhere.', 'chat'),
  ];
}

class _TopicTile extends StatelessWidget {
  final SanityTopic topic;
  final VoidCallback onTap;
  const _TopicTile({required this.topic, required this.onTap});

  IconData _iconData() {
    switch (topic.icon) {
      case 'news':    return Icons.campaign_outlined;
      case 'chart':   return Icons.bar_chart_rounded;
      case 'star':    return Icons.star_border_rounded;
      case 'fitness': return Icons.self_improvement_rounded;
      default:        return Icons.chat_bubble_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(_iconData(), color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(topic.title, style: AppTextStyles.label(color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(topic.description, style: AppTextStyles.bodySmall(), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textLight),
        ]),
      ),
    );
  }
}
