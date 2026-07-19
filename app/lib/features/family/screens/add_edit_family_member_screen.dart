import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/widgets/custom_date_picker_field.dart';
import '../../../models/user_model.dart';
import '../../../providers/family_provider.dart';

class AddEditFamilyMemberScreen extends StatefulWidget {
  final UserModel? memberToEdit;

  const AddEditFamilyMemberScreen({super.key, this.memberToEdit});

  @override
  State<AddEditFamilyMemberScreen> createState() =>
      _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends State<AddEditFamilyMemberScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _maxSteps = 3;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  late TextEditingController _firstNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _gotraController;
  late TextEditingController _spouseNameController;
  late TextEditingController _husbandNameWithSurnameController;
  late TextEditingController _sasuralGotraController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _whatsappNumberController;
  late TextEditingController _educationController;
  late TextEditingController _gaonController;
  late TextEditingController _nativeDistrictController;
  late TextEditingController _nativeStateController;
  late TextEditingController _currentAddressController;
  late TextEditingController _currentCityController;
  late TextEditingController _currentStateController;
  late TextEditingController _pinCodeController;

  String _gender = 'MALE';
  String _maritalStatus = 'SINGLE';
  String _occupationType = 'OTHER';
  String _relationshipToHead = 'SON';
  String? _bloodGroup;
  DateTime _dateOfBirth = DateTime.now().subtract(
    const Duration(days: 365 * 20),
  );

  final List<String> _relationships = [
    'SPOUSE',
    'FATHER',
    'MOTHER',
    'SON',
    'DAUGHTER',
    'GRANDSON',
    'GRANDDAUGHTER',
    'BROTHER',
    'SISTER',
    'UNCLE',
    'AUNT',
    'NEPHEW',
    'NIECE',
    'COUSIN',
    'FATHER_IN_LAW',
    'MOTHER_IN_LAW',
    'SON_IN_LAW',
    'DAUGHTER_IN_LAW',
    'BROTHER_IN_LAW',
    'SISTER_IN_LAW',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.memberToEdit;
    _firstNameController = TextEditingController(text: m?.firstName ?? '');
    _fatherNameController = TextEditingController(text: m?.fatherName ?? '');
    _motherNameController = TextEditingController(text: m?.motherName ?? '');
    _gotraController = TextEditingController(text: m?.gotra ?? '');
    _spouseNameController = TextEditingController(text: m?.spouseName ?? '');
    _husbandNameWithSurnameController = TextEditingController(
      text: m?.husbandNameWithSurname ?? '',
    );
    _sasuralGotraController = TextEditingController(
      text: m?.sasuralGotra ?? '',
    );
    _emailController = TextEditingController(text: m?.email ?? '');
    _phoneNumberController = TextEditingController(text: m?.phoneNumber ?? '');
    _whatsappNumberController = TextEditingController(
      text: m?.whatsappNumber ?? '',
    );
    _educationController = TextEditingController(text: m?.education ?? '');
    _gaonController = TextEditingController(text: m?.gaon ?? '');
    _nativeDistrictController = TextEditingController(
      text: m?.nativeDistrict ?? '',
    );
    _nativeStateController = TextEditingController(text: m?.nativeState ?? '');
    _currentAddressController = TextEditingController(
      text: m?.currentAddress ?? '',
    );
    _currentCityController = TextEditingController(text: m?.currentCity ?? '');
    _currentStateController = TextEditingController(
      text: m?.currentState ?? '',
    );
    _pinCodeController = TextEditingController(text: m?.pinCode ?? '');

    if (m != null) {
      _gender = m.gender;
      _maritalStatus = m.maritalStatus;
      _occupationType = m.occupationType;
      _relationshipToHead = m.relationshipToHead ?? 'OTHER';
      _bloodGroup = m.bloodGroup;
      _dateOfBirth = m.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _gotraController.dispose();
    _spouseNameController.dispose();
    _husbandNameWithSurnameController.dispose();
    _sasuralGotraController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _whatsappNumberController.dispose();
    _educationController.dispose();
    _gaonController.dispose();
    _nativeDistrictController.dispose();
    _nativeStateController.dispose();
    _currentAddressController.dispose();
    _currentCityController.dispose();
    _currentStateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    final isLoading = context.read<FamilyProvider>().isLoading;
    if (isLoading) return;

    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < _maxSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submit();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields correctly."),
        ),
      );
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    final data = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'fatherName': _fatherNameController.text.trim(),
      'gotra': _gotraController.text.trim(),
      'gaon': _gaonController.text.trim(),
      'nativeDistrict': _nativeDistrictController.text.trim(),
      'nativeState': _nativeStateController.text.trim(),
      'currentCity': _currentCityController.text.trim(),
      'currentState': _currentStateController.text.trim(),
      'gender': _gender,
      'maritalStatus': _maritalStatus,
      'occupationType': _occupationType,
      'relationshipToHead': _relationshipToHead,
      'dateOfBirth': _dateOfBirth.toUtc().toIso8601String(),
    };

    if (_motherNameController.text.trim().isNotEmpty)
      data['motherName'] = _motherNameController.text.trim();
    if (_spouseNameController.text.trim().isNotEmpty)
      data['spouseName'] = _spouseNameController.text.trim();
    if (_husbandNameWithSurnameController.text.trim().isNotEmpty)
      data['husbandNameWithSurname'] = _husbandNameWithSurnameController.text
          .trim();
    if (_sasuralGotraController.text.trim().isNotEmpty)
      data['sasuralGotra'] = _sasuralGotraController.text.trim();
    if (_emailController.text.trim().isNotEmpty)
      data['email'] = _emailController.text.trim();
    if (_phoneNumberController.text.trim().isNotEmpty)
      data['phoneNumber'] = _phoneNumberController.text.trim();
    if (_whatsappNumberController.text.trim().isNotEmpty)
      data['whatsappNumber'] = _whatsappNumberController.text.trim();
    if (_educationController.text.trim().isNotEmpty)
      data['education'] = _educationController.text.trim();
    if (_currentAddressController.text.trim().isNotEmpty)
      data['currentAddress'] = _currentAddressController.text.trim();
    if (_pinCodeController.text.trim().isNotEmpty)
      data['pinCode'] = _pinCodeController.text.trim();
    if (_bloodGroup != null) data['bloodGroup'] = _bloodGroup!;

    final provider = context.read<FamilyProvider>();
    bool success;
    if (widget.memberToEdit == null) {
      success = await provider.addFamilyMember(data);
    } else {
      success = await provider.updateFamilyMember(
        widget.memberToEdit!.id,
        data,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "An error occurred."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          children: [
            CustomDropdownField(
              labelText: 'Relationship to Head *',
              hintText: 'Select relationship',
              value: _relationshipToHead,
              items: _relationships,
              onChanged: (val) => setState(() => _relationshipToHead = val!),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _firstNameController,
              labelText: 'First Name *',
              hintText: 'Enter first name',
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
              controller: _fatherNameController,
              labelText: 'Father\'s Name *',
              hintText: 'Enter father\'s name',
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
              controller: _motherNameController,
              labelText: 'Mother\'s Name',
              hintText: 'Enter mother\'s name',
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _gotraController,
              labelText: 'Gotra *',
              hintText: 'Enter Gotra',
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark02,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdownField(
              labelText: 'Gender *',
              hintText: 'Select gender',
              value: _gender,
              items: const ['MALE', 'FEMALE', 'OTHER'],
              onChanged: (val) => setState(() => _gender = val!),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomDatePickerField(
              labelText: 'Date of Birth *',
              hintText: 'Select birth date',
              selectedDate: _dateOfBirth,
              onDateSelected: (date) => setState(() => _dateOfBirth = date),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdownField(
              labelText: 'Blood Group',
              hintText: 'Select blood group',
              value: _bloodGroup,
              items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
              onChanged: (val) => setState(() => _bloodGroup = val!),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedDroplet,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdownField(
              labelText: 'Marital Status *',
              hintText: 'Select marital status',
              value: _maritalStatus,
              items: const ['SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'],
              onChanged: (val) => setState(() => _maritalStatus = val!),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFavourite,
                size: 18,
                color: Colors.black54,
              ),
            ),
            if (_maritalStatus == 'MARRIED') ...[
              const SizedBox(height: 8),
              CustomTextField(
                controller: _spouseNameController,
                labelText: 'Spouse Name',
                hintText: 'Enter spouse name',
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUserLove01,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              if (_gender == 'FEMALE') ...[
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _husbandNameWithSurnameController,
                  labelText: 'Husband Name with Surname',
                  hintText: 'e.g. Rahul Bafna',
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _sasuralGotraController,
                  labelText: 'Sasural Gotra',
                  hintText: 'Enter sasural gotra',
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedHome01,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email Address *',
              hintText: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMail01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _phoneNumberController,
              labelText: 'Phone Number *',
              hintText: 'Enter 10-digit number',
              keyboardType: TextInputType.phone,
              maxLength: 10,
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
              controller: _whatsappNumberController,
              labelText: 'WhatsApp Number',
              hintText: 'Enter 10-digit number',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedWhatsapp,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _gaonController,
              labelText: 'Native Village (Gaon) *',
              hintText: 'Enter Gaon',
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
              controller: _nativeDistrictController,
              labelText: 'Native District *',
              hintText: 'Enter district',
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nativeStateController,
              labelText: 'Native State *',
              hintText: 'Enter state',
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMapPin,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _currentCityController,
              labelText: 'Current City *',
              hintText: 'Where do they live now?',
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
              controller: _currentStateController,
              labelText: 'Current State *',
              hintText: 'Current state',
              validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMapPin,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _currentAddressController,
              labelText: 'Current Address',
              hintText: 'Full address',
              maxLines: 2,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _pinCodeController,
              labelText: 'Pin Code',
              hintText: 'Postal code',
              keyboardType: TextInputType.number,
              maxLength: 6,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMailbox,
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

  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _educationController,
              labelText: 'Education',
              hintText: 'Highest qualification',
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedBook02,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdownField(
              labelText: 'Occupation *',
              hintText: 'Select occupation type',
              value: _occupationType,
              items: const ['BUSINESS_OWNER', 'JOB_PROFESSIONAL', 'OTHER'],
              onChanged: (val) => setState(() => _occupationType = val!),
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedBriefcase02,
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

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FamilyProvider>().isLoading;
    final isEditing = widget.memberToEdit != null;
    final title = isEditing ? 'Edit Member' : 'Add Member';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.primaryPurple,
                        size: 24,
                      ),
                      onPressed: isLoading ? null : _previousStep,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: List.generate(_maxSteps, (index) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 6,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? AppTheme.primaryPurple
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _currentPage == 0
                      ? "Step 1: Personal Details"
                      : _currentPage == 1
                      ? "Step 2: Contact & Location"
                      : "Step 3: Education & Occupation",
                  style: const TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Swiping Page View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentPage == _maxSteps - 1
                        ? (isEditing ? 'Update Member' : 'Add Member')
                        : 'Next',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
