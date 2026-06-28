import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/update_business_provider.dart';
import '../../../core/widgets/custom_text_field.dart';

class StepBusinessContact extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const StepBusinessContact({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpdateBusinessProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: 100.0,
      ),
      child: Form(
        key: formKey,
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
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Contact Number',
                initialValue: provider.contactNumber,
                onChanged: (v) => provider.updateField('contactNumber', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCall02,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contact number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Website (Optional)',
                initialValue: provider.website,
                onChanged: (v) => provider.updateField('website', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedGlobal,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              const Text(
                'Location Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Full Address',
                initialValue: provider.address,
                onChanged: (v) => provider.updateField('address', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation04,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'City',
                initialValue: provider.city,
                onChanged: (v) => provider.updateField('city', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCity01,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'State',
                initialValue: provider.state,
                onChanged: (v) => provider.updateField('state', v),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedMapsLocation01,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'State is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
