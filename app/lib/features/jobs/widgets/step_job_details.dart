import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/create_job_provider.dart';

class StepJobDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const StepJobDetails({super.key, required this.formKey});

  @override
  State<StepJobDetails> createState() => _StepJobDetailsState();
}

class _StepJobDetailsState extends State<StepJobDetails> {
  final TextEditingController _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateJobProvider>();

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Contact Name *',
              hintText: 'e.g., Ramesh Jain',
              initialValue: provider.contactName,
              onChanged: (val) =>
                  provider.updateField(() => provider.contactName = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Contact Phone Number',
              hintText: 'e.g., 9876543210',
              initialValue: provider.contactPhone,
              keyboardType: TextInputType.phone,
              onChanged: (val) =>
                  provider.updateField(() => provider.contactPhone = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCall02,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'WhatsApp Number',
              hintText: 'e.g., 9876543210',
              initialValue: provider.whatsappNumber,
              keyboardType: TextInputType.phone,
              onChanged: (val) =>
                  provider.updateField(() => provider.whatsappNumber = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedWhatsapp,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Contact Email',
              hintText: 'e.g., info@company.com',
              initialValue: provider.contactEmail,
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) =>
                  provider.updateField(() => provider.contactEmail = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMail01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Links (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (provider.links.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: provider.links.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String link = entry.value;
                  return Chip(
                    label: Text(
                      link.length > 25 ? '${link.substring(0, 25)}...' : link,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () => provider.removeLink(idx),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _linkController,
                    labelText: 'Add Link',
                    hintText: 'https://...',
                    keyboardType: TextInputType.url,
                    prefixIcon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedLink01,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                    size: 32,
                  ),
                  onPressed: () {
                    final val = _linkController.text.trim();
                    if (val.isNotEmpty) {
                      final uri = Uri.tryParse(val);
                      if (uri != null &&
                          uri.hasScheme &&
                          (uri.scheme == 'http' || uri.scheme == 'https')) {
                        provider.addLink(val);
                        _linkController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid URL starting with http:// or https://',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Description *',
              hintText: 'Full job description, requirements, etc.',
              initialValue: provider.description,
              maxLines: 5,
              onChanged: (val) =>
                  provider.updateField(() => provider.description = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFile02,
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
