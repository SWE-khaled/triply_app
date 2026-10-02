import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widget/location_row.dart';
import '../widget/media_picker_box.dart';
import '../widget/post_text_field.dart';
import '../widget/selected_image_preview.dart';
import '../widget/selected_images_grid.dart';
import '../widget/share_segment_tabs.dart';
import 'location_picker_view.dart';

/// Result handed back to CommunityScreen when the user taps Share.
class ComposerResult {
  final bool isStory;
  final XFile? image;
  final List<XFile> images;
  final String? text;
  final String? location;

  const ComposerResult({
    required this.isStory,
    required this.image,
    this.images = const [],
    this.text,
    this.location,
  });
}

/// Figma "New Post" screen. Same composer layout as New Story,
/// opened with the Post tab selected.
class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShareComposerScreen(initialIsStory: false);
  }
}

/// Figma "New Story" composer screen (empty state with media picker box).
class NewStoryScreen extends StatelessWidget {
  const NewStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShareComposerScreen(initialIsStory: true);
  }
}

class ShareComposerScreen extends StatefulWidget {
  final bool initialIsStory;

  const ShareComposerScreen({super.key, required this.initialIsStory});

  @override
  State<ShareComposerScreen> createState() => _ShareComposerScreenState();
}

class _ShareComposerScreenState extends State<ShareComposerScreen> {
  late bool isStory;
  late final TextEditingController textController;
  final ImagePicker _picker = ImagePicker();

  // Kept SEPARATE on purpose: switching the Story/Post segment must never
  // mix the two selections. Story takes exactly one photo; Post takes
  // multiple photos.
  XFile? storyImage;
  final List<XFile> postImages = [];

  // Location is only relevant for Post.
  String? location;

  @override
  void initState() {
    super.initState();
    isStory = widget.initialIsStory;
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _onMediaTap() async {
    try {
      if (isStory) {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (picked == null) return;
        setState(() => storyImage = picked);
      } else {
        final List<XFile> picked = await _picker.pickMultiImage(
          imageQuality: 85,
        );
        if (picked.isEmpty) return;
        setState(() => postImages.addAll(picked));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Center(child: Text('Unable to open gallery: $e'))));
    }
  }

  void _removeImage() {
    setState(() => storyImage = null);
  }

  void _removePostImage(int index) {
    setState(() => postImages.removeAt(index));
  }

  Future<void> _onLocationTap() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) =>  LocationPickerScreen()),
    );
    if (result != null) {
      setState(() => location = result);
    }
  }

  void _onSharePressed() {
    final trimmedText = textController.text.trim();

    // Basic guard: Story needs a photo; Post needs photo(s) or text.
    final hasContent = isStory
        ? storyImage != null
        : postImages.isNotEmpty || trimmedText.isNotEmpty;
    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Select at least one image.')),backgroundColor: AppColors.primaryTeal,),
      );
      return;
    }

    Navigator.of(context).pop(
      ComposerResult(
        isStory: isStory,
        image: isStory ? storyImage : null,
        images: isStory ? const [] : List<XFile>.from(postImages),
        text: isStory ? null : (trimmedText.isEmpty ? null : trimmedText),
        location: isStory ? null : location,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isStory ? 'New Story' : 'New Post';
    final shareLabel = isStory ? 'Share Story' : 'Share Post';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
            AppHeader(
              title: title,
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            ShareSegmentTabs(
              isStory: isStory,
              onSelect: (story) => setState(() => isStory = story),
            ),
            const SizedBox(height: 16),

            // Media section: Story takes one photo, Post takes many.
            if (isStory)
              if (storyImage == null)
                MediaPickerBox(onTap: _onMediaTap)
              else
                // Single photo preview, with a remove ("x") and tap-to-replace.
                SelectedImagePreview(
                  image: storyImage!,
                  onRemove: _removeImage,
                  onReplace: _onMediaTap,
                )
            else if (postImages.isEmpty)
              MediaPickerBox(onTap: _onMediaTap)
            else
              // Multi-photo preview grid: remove per photo, "+" adds more.
              SelectedImagesGrid(
                images: postImages,
                onRemove: _removePostImage,
                onAddMore: _onMediaTap,
              ),

            // Text + location are only shown for Post.
            if (!isStory) ...[
              const SizedBox(height: 16),
              PostTextField(controller: textController),
              const SizedBox(height: 16),
              LocationRow(location: location, onTap: _onLocationTap),
            ],

            const SizedBox(height: 16),
            PrimaryButton(label: shareLabel, onPressed: _onSharePressed),
          ],
        ),
      ),
    );
  }
}

