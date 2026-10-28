import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/constants/app_colors.dart';
import 'package:triply/core/constants/egypt_cities.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../common/AuthTourguide/data/tour_guide_auth_service.dart';
import '../../../common/AuthTourist/cubit/auth_cubit.dart';
import 'package:dropdown_search/dropdown_search.dart';

class EditProfileSheet extends StatefulWidget {
  final String name;
  final String displayAvatar;
  final String about;
  final String location;
  final String phone;

  /// The guide's hourly rate in EGP — 0 when they have not set one.
  final double pricePerHour;

  const EditProfileSheet({
    super.key,
    required this.name,
    required this.displayAvatar,
    this.about = '',
    this.location = '',
    this.phone = '',
    this.pricePerHour = 0,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _phoneController;
  late final TextEditingController _priceController;
  String? _selectedLocation;
  File? _pickedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _aboutController = TextEditingController(text: widget.about);
    _phoneController = TextEditingController(text: widget.phone);
    _selectedLocation = EgyptCities.profileEgyptLocations.contains(widget.location)
        ? widget.location
        : null;
    _priceController = TextEditingController(
      text: widget.pricePerHour > 0
          ? widget.pricePerHour.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String> _uploadImage(File file) async {
    const cloudName = 'yl49wcys';
    const preset = 'djowcnxm';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Upload failed: $body');
    }
    return jsonDecode(body)['secure_url'] as String;
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name can\'t be empty')));
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = context.read<AuthCubit>();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please sign in first'),
              action: SnackBarAction(
                label: 'Sign in',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRoutes.signIn);
                },
              ),
            ),
          );
        }
        return;
      }
      String? newPhotoUrl;

      if (_pickedImage != null) {
        newPhotoUrl = await _uploadImage(_pickedImage!);
      }

      await user.updateDisplayName(newName);
      if (newPhotoUrl != null) await user.updatePhotoURL(newPhotoUrl);
      await TourGuideAuthService().updateProfileFields(
        name: newName,
        about: _aboutController.text.trim(),
        location: _selectedLocation ?? '',
        phone: _phoneController.text.trim(),
        photoUrl: newPhotoUrl,
        pricePerHour: double.tryParse(_priceController.text.trim()) ?? 0,
      );
      await auth.refreshUser();

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final picked = _pickedImage;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loading ? null : _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE6ECEF),
                    child: picked != null
                        ? ClipOval(
                            child: Image.file(
                              picked,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: ProfileAvatar(
                              imageUrl: widget.displayAvatar,
                              width: 100,
                              height: 100,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aboutController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'About',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownSearch<String>(
              items: (filter, infiniteScrollProps) => EgyptCities.profileEgyptLocations,
              selectedItem: _selectedLocation,
              enabled: !_loading,
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                fit: FlexFit.loose,
                constraints: BoxConstraints(maxHeight: 300),
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (value) => setState(() => _selectedLocation = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price per hour (EGP)',
                hintText: 'e.g. 75',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
