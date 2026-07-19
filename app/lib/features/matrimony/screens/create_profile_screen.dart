import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../providers/matrimony_provider.dart';
import '../../main/screens/main_screen.dart';

class CreateMatrimonyProfileScreen extends StatefulWidget {
  final bool isEditing;
  const CreateMatrimonyProfileScreen({super.key, this.isEditing = false});

  @override
  State<CreateMatrimonyProfileScreen> createState() =>
      _CreateMatrimonyProfileScreenState();
}

class _CreateMatrimonyProfileScreenState
    extends State<CreateMatrimonyProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _maxSteps = 4;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final _heightCtrl = TextEditingController();
  final _subCasteCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  File? _selectedPdfFile;
  String? _existingBiodataUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingProfile();
      });
    }
  }

  void _loadExistingProfile() {
    final profile = context.read<MatrimonyProvider>().myProfile;
    if (profile != null) {
      _heightCtrl.text = profile.height ?? '';
      _subCasteCtrl.text = profile.subCaste;
      _educationCtrl.text = profile.educationDetails;
      _incomeCtrl.text = profile.monthlyIncome ?? '';
      _aboutCtrl.text = profile.aboutMe ?? '';
      _existingBiodataUrl = profile.biodataPdfUrl;
      if (profile.photoGallery.isNotEmpty) {
        setState(() {
          _existingImageUrl = profile.photoGallery.first;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heightCtrl.dispose();
    _subCasteCtrl.dispose();
    _educationCtrl.dispose();
    _incomeCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    // Validate current step
    if (_formKeys[_currentPage].currentState?.validate() ?? true) {
      // If photo step and no photo selected/existing, we should warn, but let's make it optional or required.
      // We will make it optional for now, or just proceed.

      if (_currentPage < _maxSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submitProfile();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdfFile = File(result.files.single.path!);
        _existingBiodataUrl = null;
      });
    }
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);

    final provider = context.read<MatrimonyProvider>();

    // Validate Biodata PDF is present
    if (_selectedPdfFile == null && _existingBiodataUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your biodata PDF.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    String? imageUrl = _existingImageUrl;
    String? biodataUrl = _existingBiodataUrl;

    if (_selectedImage != null) {
      imageUrl = await provider.uploadImage(_selectedImage!);
      if (imageUrl == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'Failed to upload image. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_selectedPdfFile != null) {
      biodataUrl = await provider.uploadFile(_selectedPdfFile!);
      if (biodataUrl == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'Failed to upload PDF. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final data = {
      'height': _heightCtrl.text,
      'subCaste': _subCasteCtrl.text,
      'educationDetails': _educationCtrl.text,
      'monthlyIncome': _incomeCtrl.text,
      'aboutMe': _aboutCtrl.text,
      'biodataPdfUrl': biodataUrl,
      'photoGallery': imageUrl != null ? [imageUrl] : [],
    };

    bool success;
    if (widget.isEditing && provider.myProfile != null) {
      success = await provider.updateProfile(data);
    } else {
      success = await provider.createProfile(data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Profile Updated successfully'
                : 'Profile Created & Pending Approval',
          ),
        ),
      );
      if (!widget.isEditing) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.isEditing ? "Edit Matrimony" : "Create Matrimony",
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryPurple,
            size: 24,
          ),
          onPressed: _isLoading ? null : _previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicators
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
                    ? "Step 2: Education & Career"
                    : _currentPage == 2
                    ? "Step 3: About Me"
                    : "Step 4: Photo",
                style: const TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStepPersonal(),
                  _buildStepEducation(),
                  _buildStepAboutMe(),
                  _buildStepPhoto(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentPage == _maxSteps - 1 ? 'Submit' : 'Next',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepPersonal() {
    return Form(
      key: _formKeys[0],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CustomTextField(
            controller: _subCasteCtrl,
            labelText: 'Gotra / Sub-Caste *',
            hintText: 'Enter Gotra / Sub-Caste',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedUserGroup,
              size: 18,
              color: Colors.black54,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Gotra is required' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _heightCtrl,
            labelText: 'Height (e.g., 5\'8") *',
            hintText: 'Enter your height',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowUp01,
              size: 18,
              color: Colors.black54,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Height is required' : null,
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload Biodata (PDF) *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickPdf,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedFile01,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPdfFile != null
                          ? _selectedPdfFile!.path
                                .split(Platform.pathSeparator)
                                .last
                          : (_existingBiodataUrl != null
                                ? 'Existing PDF uploaded. Tap to change.'
                                : 'Select PDF File'),
                      style: TextStyle(
                        color:
                            _selectedPdfFile != null ||
                                _existingBiodataUrl != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepEducation() {
    return Form(
      key: _formKeys[1],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CustomTextField(
            controller: _educationCtrl,
            labelText: 'Education Details *',
            hintText: 'e.g. B.Tech, MBA',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedBookOpen01,
              size: 18,
              color: Colors.black54,
            ),
            validator: (val) => val == null || val.isEmpty
                ? 'Education details are required'
                : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _incomeCtrl,
            labelText: 'Monthly Income *',
            hintText: 'e.g. 50,000',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMoney04,
              size: 18,
              color: Colors.black54,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Income is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepAboutMe() {
    return Form(
      key: _formKeys[2],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CustomTextField(
            controller: _aboutCtrl,
            labelText: 'About Me *',
            hintText: 'Tell us about yourself...',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              size: 18,
              color: Colors.black54,
            ),
            maxLines: 4,
            validator: (val) =>
                val == null || val.isEmpty ? 'About Me is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepPhoto() {
    return Form(
      key: _formKeys[3],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Upload a clear photo to increase your chances of finding a match.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryPurple, width: 2),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : (_existingImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_existingImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: (_selectedImage == null && _existingImageUrl == null)
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: AppTheme.primaryPurple,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add',
                            style: TextStyle(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
