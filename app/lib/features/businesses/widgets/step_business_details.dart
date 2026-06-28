import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/update_business_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../core/widgets/custom_text_field.dart';

class StepBusinessDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const StepBusinessDetails({super.key, required this.formKey});

  @override
  State<StepBusinessDetails> createState() => _StepBusinessDetailsState();
}

class _StepBusinessDetailsState extends State<StepBusinessDetails> {
  final ImagePicker _picker = ImagePicker();

  void _showImagePickerOptions(
    BuildContext context,
    UpdateBusinessProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCamera01,
                  color: AppTheme.primaryPurple,
                ),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, provider);
                },
              ),
              ListTile(
                leading: const HugeIcon(
                  icon: HugeIcons.strokeRoundedImage01,
                  color: AppTheme.primaryPurple,
                ),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    UpdateBusinessProvider provider,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        final success = await provider.uploadLogo(File(image.path));
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error selecting image')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpdateBusinessProvider>();
    final businessProvider = context.read<BusinessProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: 100.0,
      ),
      child: Form(
        key: widget.formKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: provider.isLoading
                      ? null
                      : () => _showImagePickerOptions(context, provider),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: provider.logoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(provider.logoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: provider.logoUrl == null
                            ? const HugeIcon(
                                icon: HugeIcons.strokeRoundedStore01,
                                color: Colors.grey,
                                size: 40,
                              )
                            : null,
                      ),
                      if (provider.isLoading)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedCamera01,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Business Logo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                labelText: 'Business Name',
                initialValue: provider.businessName,
                onChanged: (v) => provider.updateField('businessName', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedStore01,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value:
                    (provider.category != null && provider.category!.isNotEmpty)
                    ? provider.category
                    : null,
                items: businessProvider.availableCategories.map((String cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) => provider.updateField('category', value),
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: const UnconstrainedBox(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedTag01,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Description (Optional)',
                initialValue: provider.description,
                onChanged: (v) => provider.updateField('description', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedText,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
