import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/campus_locations.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/loading_button.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportFormScreen()),
    );
  }

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  IncidentCategory _category = IncidentCategory.facilities;
  String? _location;
  File? _image;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (picked != null && mounted) {
        setState(() => _image = File(picked.path));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access that photo source.')),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_image != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  setState(() => _image = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final incidents = context.read<IncidentProvider>();
    final storage = context.read<StorageService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    String? imageUrl;
    var photoFailed = false;
    if (_image != null) {
      try {
        imageUrl = await storage.uploadIncidentImage(
          file: _image!,
          userId: user.uid,
        );
      } catch (_) {
        photoFailed = true;
      }
    }

    try {
      await incidents.submit(
        reporter: user,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        location: _location!,
        imageUrl: imageUrl,
      );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            photoFailed
                ? 'Report submitted, but the photo could not be uploaded.'
                : 'Report submitted successfully.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not submit the report.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Select a category'),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 20) / 3;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: IncidentCategory.values
                          .map(
                            (category) => SizedBox(
                              width: width,
                              child: _CategoryTile(
                                category: category,
                                selected: _category == category,
                                onTap: () =>
                                    setState(() => _category = category),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _label('Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: 80,
                  validator: (v) => Validators.minLength(v, 'Title', 5),
                  decoration: const InputDecoration(
                    hintText: 'Briefly describe the issue...',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                _label('Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 5,
                  maxLength: 500,
                  validator: (v) => Validators.minLength(v, 'Description', 15),
                  decoration: const InputDecoration(
                    hintText:
                        'Provide more details about the issue, e.g. what happened, when, impact, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                _label('Location'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _location,
                  isExpanded: true,
                  hint: const Text('Select a location'),
                  validator: (v) => v == null ? 'Location is required' : null,
                  items: campusLocations
                      .map(
                        (place) => DropdownMenuItem(
                          value: place,
                          child: Text(place),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _location = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _label('Add a photo'),
                    const SizedBox(width: 6),
                    const Text(
                      '(optional)',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _PhotoPicker(
                  image: _image,
                  onTap: _showPhotoOptions,
                  onRemove: () => setState(() => _image = null),
                ),
                const SizedBox(height: 28),
                LoadingButton(
                  label: 'Submit Report',
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xFFEDE9FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              category.icon,
              size: 22,
              color: selected ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              image!,
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xB3000000),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E2F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.image_outlined, color: AppTheme.primary, size: 28),
            SizedBox(height: 8),
            Text(
              'Tap to add photo',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}