import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/create_job_provider.dart';

class StepJobLocation extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const StepJobLocation({super.key, required this.formKey});

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
            CustomTextField(
              labelText: 'City *',
              hintText: 'e.g., Mumbai, Bangalore',
              initialValue: provider.city,
              onChanged: (val) =>
                  provider.updateField(() => provider.city = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCity01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Salary Range (Optional)',
              hintText: 'e.g., ₹50,000 - ₹80,000 / month',
              initialValue: provider.salaryRange,
              onChanged: (val) =>
                  provider.updateField(() => provider.salaryRange = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMoney01,
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
