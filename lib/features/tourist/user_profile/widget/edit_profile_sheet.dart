import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../cubit/update_profile_cubit.dart';
import '../cubit/update_profile_state.dart';

class EditProfileSheet extends StatefulWidget {
  final String name;
  final String? photoUrl;
  final String city;
  final String country;
  final String bio;

  const EditProfileSheet({
    super.key,
    required this.name,
    this.photoUrl,
    this.city = '',
    this.country = '',
    this.bio = '',
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _cityController = TextEditingController(
    text: widget.city,
  );
  late final TextEditingController _countryController = TextEditingController(
    text: widget.country,
  );
  late final TextEditingController _bioController = TextEditingController(
    text: widget.bio,
  );
  XFile? _pickedImage;
  bool _removePhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _showPhotoActions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF83969A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Change profile photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263C42),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await _pickImage();
                  },
                  child: const Text('Upload from gallery'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
              ),
              if (_hasPhoto)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                      _removePhoto = true;
                    });
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    'Remove current photo',
                    style: TextStyle(
                      color: Color(0xFFC33B25),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasPhoto =>
      _pickedImage != null ||
      (!_removePhoto && (widget.photoUrl?.trim().isNotEmpty ?? false));

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedImage = picked;
          _removePhoto = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the photo gallery.')),
        );
      }
    }
  }

  /// UI-only: validation, upload and Firestore writes belong to the cubit.
  Future<void> _save() async {
    await context.read<UpdateProfileCubit>().save(
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      bio: _bioController.text.trim(),
      image: _pickedImage,
      removePhoto: _removePhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<UpdateProfileCubit>().state is UpdateProfileLoading;
    final imageUrl = _removePhoto ? '' : (widget.photoUrl ?? '');
    final location = [
      _cityController.text.trim(),
      _countryController.text.trim(),
    ].where((value) => value.isNotEmpty).join(', ');

    return BlocListener<UpdateProfileCubit, UpdateProfileState>(
      listener: (context, state) {
        if (!mounted || state.message == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
        if (state is ProfileUpdateSucceeded) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: isLoading ? null : () => Navigator.pop(context),
          ),
          title: const Text(
            'Edit profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          titleSpacing: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8E9)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 21,
                            backgroundColor: const Color(0xFFE7F2F0),
                            backgroundImage: _pickedImage != null
                                ? FileImage(File(_pickedImage!.path))
                                : null,
                            child: _pickedImage == null
                                ? ClipOval(
                                    child: ProfileAvatar(
                                      imageUrl: imageUrl,
                                      size: 42,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  location.isEmpty
                                      ? 'Add your location'
                                      : location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isLoading ? null : _showPhotoActions,
                            icon: const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF0D5865),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _showPhotoActions,
                        child: const Text('Change profile photo'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Personal information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Keep your name and home location up to date.',
                      style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 16),
                    _field('Full name', _nameController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _field('City', _cityController)),
                        const SizedBox(width: 10),
                        Expanded(child: _field('Country', _countryController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'Bio (optional)',
                      _bioController,
                      maxLines: 4,
                      hint: 'Tell other travelers a little about yourself...',
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your name, photo and bio appear on your profile.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: isLoading ? null : _save,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFF9AAEB1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFF9AAEB1)),
          ),
        ),
      ),
    ],
  );
}
