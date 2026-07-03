import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../providers/create_job_provider.dart';

class StepJobBasics extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const StepJobBasics({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateJobProvider>();

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomDropdownField(
              labelText: 'Job Type *',
              hintText: 'Select posting type',
              value: provider.type,
              items: const ['VACANCY_AVAILABLE', 'JOB_REQUIRED'],
              onChanged: (val) =>
                  provider.updateField(() => provider.type = val ?? 'VACANCY_AVAILABLE'),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedBriefcase02,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Role Title *',
              hintText: 'e.g., Software Engineer, Accountant',
              initialValue: provider.roleTitle,
              onChanged: (val) =>
                  provider.updateField(() => provider.roleTitle = val),
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
              hintText: 'e.g., IT, Finance, Retail',
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
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
