import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/widgets/custom_date_picker_field.dart';
import '../../../providers/complete_profile_provider.dart';

class StepPersonalDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const StepPersonalDetails({super.key, required this.formKey});

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
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'First Name *',
              hintText: 'Enter your first name',
              initialValue: provider.firstName,
              onChanged: (val) =>
                  provider.updateField(() => provider.firstName = val),
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
              labelText: 'Father Name *',
              hintText: 'Enter your father\'s name',
              initialValue: provider.fatherName,
              onChanged: (val) =>
                  provider.updateField(() => provider.fatherName = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Mother Name',
              hintText: 'Enter your mother\'s name',
              initialValue: provider.motherName,
              onChanged: (val) =>
                  provider.updateField(() => provider.motherName = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: 'Gotra *',
              hintText: 'Enter your Gotra',
              initialValue: provider.gotra,
              onChanged: (val) =>
                  provider.updateField(() => provider.gotra = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark02,
                size: 18,
                color: Colors.black54,
              ),
            ),

            // Gender
            CustomDropdownField(
              labelText: 'Gender *',
              hintText: 'Select your gender',
              value: provider.gender,
              items: const ['MALE', 'FEMALE', 'OTHER'],
              onChanged: (val) =>
                  provider.updateField(() => provider.gender = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                size: 18,
                color: Colors.black54,
              ),
            ),

            // DOB
            CustomDatePickerField(
              labelText: 'Date of Birth *',
              hintText: 'Select your birth date',
              selectedDate: provider.dateOfBirth,
              onDateSelected: (date) =>
                  provider.updateField(() => provider.dateOfBirth = date),
              validator: (val) =>
                  provider.dateOfBirth == null ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar01,
                size: 18,
                color: Colors.black54,
              ),
            ),

            // Blood Group
            CustomDropdownField(
              labelText: 'Blood Group',
              hintText: 'Select blood group',
              value: provider.bloodGroup,
              items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
              onChanged: (val) =>
                  provider.updateField(() => provider.bloodGroup = val),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedDroplet,
                size: 18,
                color: Colors.black54,
              ),
            ),

            // Marital Status
            CustomDropdownField(
              labelText: 'Marital Status *',
              hintText: 'Select marital status',
              value: provider.maritalStatus,
              items: const ['SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'],
              onChanged: (val) =>
                  provider.updateField(() => provider.maritalStatus = val),
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFavourite,
                size: 18,
                color: Colors.black54,
              ),
            ),

            if (provider.maritalStatus == 'MARRIED') ...[
              CustomTextField(
                labelText: 'Spouse Name',
                hintText: 'Enter your spouse\'s name',
                initialValue: provider.spouseName,
                onChanged: (val) =>
                    provider.updateField(() => provider.spouseName = val),
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUserLove01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              if (provider.gender == 'FEMALE') ...[
                CustomTextField(
                  labelText: 'Husband Name with Surname',
                  hintText: 'e.g. Rahul Bafna',
                  initialValue: provider.husbandNameWithSurname,
                  onChanged: (val) => provider.updateField(
                    () => provider.husbandNameWithSurname = val,
                  ),
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  labelText: 'Sasural Gotra',
                  hintText: 'Enter sasural gotra',
                  initialValue: provider.sasuralGotra,
                  onChanged: (val) =>
                      provider.updateField(() => provider.sasuralGotra = val),
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedHome01,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
