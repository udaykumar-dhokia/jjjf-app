import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/complete_profile_provider.dart';

class StepContactAddress extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const StepContactAddress({super.key, required this.formKey});

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
            CustomTextField(
              labelText: 'Phone Number *',
              maxLength: 10,
              hintText: 'Enter 10-digit number',
              initialValue: provider.phoneNumber,
              keyboardType: TextInputType.phone,
              onChanged: (val) =>
                  provider.updateField(() => provider.phoneNumber = val),
              validator: (val) {
                if (val == null || val.isEmpty) return "Required";
                if (val.length != 10) return "Must be 10 digits";
                return null;
              },
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCall,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'WhatsApp Number',
              maxLength: 10,
              hintText: 'Leave blank if same as phone',
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
              labelText: 'Native Village (Gaon) *',
              hintText: 'Enter your Gaon',
              initialValue: provider.gaon,
              onChanged: (val) =>
                  provider.updateField(() => provider.gaon = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedHome05,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Native District *',
              hintText: 'Enter district',
              initialValue: provider.nativeDistrict,
              onChanged: (val) =>
                  provider.updateField(() => provider.nativeDistrict = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Native State *',
              hintText: 'Enter state',
              initialValue: provider.nativeState,
              onChanged: (val) =>
                  provider.updateField(() => provider.nativeState = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedMapPin,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Current City *',
              hintText: 'Where do you live now?',
              initialValue: provider.currentCity,
              onChanged: (val) =>
                  provider.updateField(() => provider.currentCity = val),
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
              labelText: 'Current State *',
              hintText: 'Current state',
              initialValue: provider.currentState,
              onChanged: (val) =>
                  provider.updateField(() => provider.currentState = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedMapPin,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Current Address',
              hintText: 'Full address',
              initialValue: provider.currentAddress,
              maxLines: 2,
              onChanged: (val) =>
                  provider.updateField(() => provider.currentAddress = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Pin Code',
              hintText: 'Postal code',
              maxLength: 6,
              initialValue: provider.pinCode,
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  provider.updateField(() => provider.pinCode = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMailbox,
                size: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
    );
  }
}
