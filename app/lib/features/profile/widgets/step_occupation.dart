import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../providers/complete_profile_provider.dart';

class StepOccupation extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const StepOccupation({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompleteProfileProvider>();

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomDropdownField(
              labelText: 'Occupation Type *',
              hintText: 'Select occupation type',
              value: provider.occupationType,
              items: const ['BUSINESS_OWNER', 'JOB_PROFESSIONAL', 'OTHER'],
              onChanged: (val) =>
                  provider.updateField(() => provider.occupationType = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedBriefcase02,
                size: 18,
                color: Colors.black54,
              ),
            ),

            if (provider.occupationType == 'BUSINESS_OWNER') ...[
              CustomTextField(
                labelText: 'Business Name *',
                hintText: 'Enter shop/business name',
                initialValue: provider.businessName,
                onChanged: (val) =>
                    provider.updateField(() => provider.businessName = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedStore01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                labelText: 'Business Category *',
                hintText: 'e.g., Textiles, Electronics',
                initialValue: provider.businessCategory,
                onChanged: (val) =>
                    provider.updateField(() => provider.businessCategory = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedTag01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                labelText: 'Business Contact *',
                hintText: 'Mobile number for business',
                keyboardType: TextInputType.phone,
                initialValue: provider.businessContact,
                onChanged: (val) =>
                    provider.updateField(() => provider.businessContact = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCall,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                labelText: 'Business Address *',
                hintText: 'Full business address',
                initialValue: provider.businessAddress,
                maxLines: 2,
                onChanged: (val) =>
                    provider.updateField(() => provider.businessAddress = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (provider.occupationType == 'JOB_PROFESSIONAL') ...[
              CustomTextField(
                labelText: 'Company Name *',
                hintText: 'Where do you work?',
                initialValue: provider.companyName,
                onChanged: (val) =>
                    provider.updateField(() => provider.companyName = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedBuilding03,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                labelText: 'Designation *',
                hintText: 'e.g., Software Engineer',
                initialValue: provider.designation,
                onChanged: (val) =>
                    provider.updateField(() => provider.designation = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUserStar01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                labelText: 'Industry *',
                hintText: 'e.g., IT, Finance, Manufacturing',
                initialValue: provider.industry,
                onChanged: (val) =>
                    provider.updateField(() => provider.industry = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedFactory01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                labelText: 'Job City *',
                hintText: 'Where is your office located?',
                initialValue: provider.jobCity,
                onChanged: (val) =>
                    provider.updateField(() => provider.jobCity = val),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCity01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (provider.occupationType == 'OTHER') ...[
              CustomTextField(
                labelText: 'Description *',
                hintText: 'e.g., Student, Retired, Homemaker',
                initialValue: provider.occupationDescription,
                onChanged: (val) => provider.updateField(
                  () => provider.occupationDescription = val,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
