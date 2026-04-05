import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String topicTitle;
  const PostDetailScreen({super.key, required this.post, required this.topicTitle});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final List<Map<String, dynamic>> _comments = [];
  dynamic _lastDoc;
  bool _loadingComments = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _submitting = false;

  final _commentCtrl = TextEditingController();
  late int _likes;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _likes = widget.post['likes'] ?? 0;
    _commentCount = widget.post['commentCount'] ?? 0;
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments({bool refresh = false}) async {
    if (refresh) {
      _comments.clear();
      _lastDoc = null;
      _hasMore = true;
    }

    final result = await FirestoreService.fetchCommentsPaginated(
      postId: widget.post['id'],
      lastDoc: _lastDoc,
    );

    if (!mounted) return;
    setState(() {
      _comments.addAll(result.comments);
      _lastDoc = result.lastDoc;
      _hasMore = result.lastDoc != null;
      _loadingComments = false;
      _loadingMore = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    await _loadComments();
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);

    final profile = await AuthService.fetchProfile();
    await FirestoreService.createComment(
      postId: widget.post['id'],
      nickname: profile?.nickname ?? 'Anonymous',
      content: text,
    );

    _commentCtrl.clear();
    setState(() {
      _submitting = false;
      _commentCount++;
    });
    await _loadComments(refresh: true);
  }

  Future<void> _likePost() async {
    await FirestoreService.likePost(widget.post['id']);
    setState(() => _likes++);
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.post['createdAt'] as String?;
    final date = createdAt != null ? DateTime.tryParse(createdAt) : null;
    final imageUrl = widget.post['imageUrl'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.topicTitle, style: AppTextStyles.label(color: AppColors.textMid)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Post ──
                Container(
                  decoration: AppDecorations.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox()),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primarySoft,
                                child: const Icon(Icons.person_outline, color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(widget.post['nickname'] ?? 'Anonymous', style: AppTextStyles.label(color: AppColors.textDark))),
                              if (date != null)
                                Text(DateFormat('MMM d, yyyy').format(date), style: AppTextStyles.caption()),
                            ]),
                            const SizedBox(height: 14),
                            Text(widget.post['title'] ?? '', style: AppTextStyles.h3()),
                            const SizedBox(height: 10),
                            Text(widget.post['content'] ?? '', style: AppTextStyles.bodyLarge()),
                            const SizedBox(height: 16),
                            Row(children: [
                              GestureDetector(
                                onTap: _likePost,
                                child: Row(children: [
                                  const Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.textLight),
                                  const SizedBox(width: 4),
                                  Text('$_likes', style: AppTextStyles.body()),
                                ]),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textLight),
                              const SizedBox(width: 4),
                              Text('$_commentCount ${_commentCount == 1 ? 'comment' : 'comments'}', style: AppTextStyles.body()),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Comments header ──
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Text('Comments', style: AppTextStyles.h4()),
                ),

                if (_loadingComments)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
                else if (_comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No comments yet — be the first!', style: AppTextStyles.body()),
                  )
                else ...[
                  ..._comments.map((c) => _CommentTile(
                    comment: c,
                    postId: widget.post['id'],
                    onLike: () => setState(() {}),
                  )),
                  if (_hasMore)
                    Center(
                      child: TextButton(
                        onPressed: _loadMore,
                        child: _loadingMore
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : Text('Load more comments', style: AppTextStyles.label(color: AppColors.primary)),
                      ),
                    ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Comment input ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: AppTextStyles.body(color: AppColors.textLight),
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body(color: AppColors.textDark),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _submitting ? null : _submitComment,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: _submitting
                      ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String postId;
  final VoidCallback onLike;
  const _CommentTile({required this.comment, required this.postId, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final createdAt = comment['createdAt'] as String?;
    final date = createdAt != null ? DateTime.tryParse(createdAt) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primarySoft,
              child: const Icon(Icons.person_outline, color: AppColors.primary, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(comment['nickname'] ?? 'Anonymous', style: AppTextStyles.label(color: AppColors.textDark))),
            if (date != null)
              Text(DateFormat('MMM d').format(date), style: AppTextStyles.caption()),
          ]),
          const SizedBox(height: 8),
          Text(comment['content'] ?? '', style: AppTextStyles.body(color: AppColors.textDark)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              await FirestoreService.likeComment(postId: postId, commentId: comment['id']);
              onLike();
            },
            child: Row(children: [
              const Icon(Icons.favorite_border_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text('${comment['likes'] ?? 0}', style: AppTextStyles.caption()),
            ]),
          ),
        ],
      ),
    );
  }
}
