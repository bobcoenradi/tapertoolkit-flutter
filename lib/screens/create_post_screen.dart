import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme/app_theme.dart';
import '../services/sanity_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CreatePostScreen extends StatefulWidget {
  final SanityTopic topic;
  const CreatePostScreen({super.key, required this.topic});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  XFile? _image;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _image = picked);
  }

  Future<String?> _uploadImage(XFile file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');
    final task = await ref.putFile(File(file.path));
    return await task.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() => _error = 'Please fill in both title and content.');
      return;
    }

    setState(() { _submitting = true; _error = null; });

    try {
      final profile = await AuthService.fetchProfile();
      String? imageUrl;
      if (_image != null) imageUrl = await _uploadImage(_image!);

      await FirestoreService.createPost(
        nickname: profile?.nickname ?? 'Anonymous',
        topicId: widget.topic.id,
        title: title,
        content: content,
        imageUrl: imageUrl,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _submitting = false; _error = 'Failed to post. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('New Post', style: AppTextStyles.h4()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : Text('Post', style: AppTextStyles.label(color: AppColors.primary)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.forum_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(widget.topic.title, style: AppTextStyles.caption(color: AppColors.primary)),
              ]),
            ),
            const SizedBox(height: 20),

            // Title
            Container(
              decoration: AppDecorations.card(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Post title',
                  hintStyle: AppTextStyles.h4(color: AppColors.textLight),
                  border: InputBorder.none,
                ),
                style: AppTextStyles.h4(color: AppColors.textDark),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Container(
              decoration: AppDecorations.card(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _contentCtrl,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts, questions, or experience...',
                  hintStyle: AppTextStyles.body(color: AppColors.textLight),
                  border: InputBorder.none,
                ),
                style: AppTextStyles.body(color: AppColors.textDark),
                textCapitalization: TextCapitalization.sentences,
                minLines: 6,
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),

            // Image picker
            if (_image != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(_image!.path), height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _image = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textLight, size: 22),
                    const SizedBox(width: 8),
                    Text('Add an image (optional)', style: AppTextStyles.body(color: AppColors.textLight)),
                  ]),
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: AppTextStyles.body(color: Colors.red.shade600)),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
