import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'news_detail_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  List<SanityNewsItem> _news = [];
  List<SanityTopic> _topics = [];
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final news = await SanityService.fetchNews(limit: 6);
      final topics = await SanityService.fetchTopics();
      final posts = await FirestoreService.fetchPosts();
      if (!mounted) return;
      setState(() {
        _news = news;
        _topics = topics;
        _posts = posts;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_loading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))),
              )
            else ...[
              SliverToBoxAdapter(child: _buildLatestNewsLabel()),
              if (_news.isNotEmpty) SliverToBoxAdapter(child: _NewsCard(item: _news[0], large: true)),
              if (_news.length > 1) SliverToBoxAdapter(child: _NewsCard(item: _news[1], large: true)),
              SliverToBoxAdapter(child: _buildTopicsSection()),
              SliverToBoxAdapter(child: _buildCommunityPosts()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPostSheet(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Social', style: AppTextStyles.h4(color: AppColors.primary)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textDark)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildLatestNewsLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text('LATEST NEWS', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.2)),
    );
  }

  Widget _buildTopicsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOPICS', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.2)),
              TextButton(onPressed: () {}, child: Text('View All', style: AppTextStyles.label(color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: 8),
          if (_topics.isEmpty)
            ..._defaultTopics.map((t) => _TopicTile(title: t.$1, description: t.$2, icon: t.$3))
          else
            ..._topics.map((t) => _TopicTile(title: t.title, description: t.description, icon: t.icon)),
        ],
      ),
    );
  }

  static const _defaultTopics = [
    ('Symptom Management', 'Strategies, tracking, and peer support for daily challenges.', 'chart'),
    ('Success Stories', 'Celebrating milestones and final tapers from our community.', 'star'),
    ('Wellness Tips', 'Nutrition, sleep, and mindfulness practices during taper.', 'fitness'),
    ('General Discussion', 'Connect with others on anything not covered elsewhere.', 'chat'),
  ];

  Widget _buildCommunityPosts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMMUNITY', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          if (_posts.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Be the first to post!', style: AppTextStyles.body())))
          else
            ..._posts.take(5).map((p) => _PostTile(post: p, onLike: () async {
              await FirestoreService.likePost(p['id']);
              _load();
            })),
        ],
      ),
    );
  }

  void _showNewPostSheet() {
    final contentCtrl = TextEditingController();
    String selectedTopic = _topics.isNotEmpty ? _topics[0].id : 'general';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share with the community', style: AppTextStyles.h3()),
            const SizedBox(height: 4),
            Text('Your post is anonymous — only your nickname is shown.', style: AppTextStyles.body()),
            const SizedBox(height: 16),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: AppTextStyles.body(color: AppColors.textDark),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final profile = await AuthService.fetchProfile();
                  await FirestoreService.createPost(
                    nickname: profile?.nickname ?? 'Anonymous',
                    topicId: selectedTopic,
                    content: contentCtrl.text.trim(),
                  );
                  Navigator.of(ctx).pop();
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Post Anonymously', style: AppTextStyles.label(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final SanityNewsItem item;
  final bool large;
  const _NewsCard({required this.item, this.large = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailScreen(item: item))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(item.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 180, color: AppColors.border)),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item.tag.toUpperCase(), style: AppTextStyles.caption(color: AppColors.primary).copyWith(letterSpacing: 0.8)),
                ),
                const SizedBox(width: 8),
                if (item.publishedAt != null)
                  Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.tryParse(item.publishedAt!) ?? DateTime.now()),
                    style: AppTextStyles.caption(),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.title, style: AppTextStyles.h4()),
            const SizedBox(height: 4),
            Text(item.excerpt, style: AppTextStyles.body(), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String title;
  final String description;
  final String? icon;
  const _TopicTile({required this.title, required this.description, this.icon});

  IconData _iconData() {
    switch (icon) {
      case 'chart': return Icons.bar_chart_rounded;
      case 'star': return Icons.star_border_rounded;
      case 'fitness': return Icons.self_improvement_rounded;
      default: return Icons.chat_bubble_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
            child: Icon(_iconData(), color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label(color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.bodySmall(), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textLight),
        ],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  const _PostTile({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final createdAt = post['createdAt'] as String?;
    final date = createdAt != null ? DateTime.tryParse(createdAt) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: AppColors.primarySoft, child: const Icon(Icons.person_outline, color: AppColors.primary, size: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(post['nickname'] ?? 'Anonymous', style: AppTextStyles.label(color: AppColors.textDark))),
              if (date != null) Text(DateFormat('MMM d').format(date), style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: 10),
          Text(post['content'] ?? '', style: AppTextStyles.body(color: AppColors.textDark)),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 16, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text('${post['likes'] ?? 0}', style: AppTextStyles.caption()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
