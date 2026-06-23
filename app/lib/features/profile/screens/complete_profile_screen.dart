import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/complete_profile_provider.dart';
import '../widgets/step_personal_details.dart';
import '../widgets/step_contact_address.dart';
import '../widgets/step_occupation.dart';
import '../widgets/step_password.dart';
import '../../main/screens/main_screen.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompleteProfileProvider(),
      child: const _CompleteProfileView(),
    );
  }
}

class _CompleteProfileView extends StatefulWidget {
  const _CompleteProfileView();

  @override
  State<_CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<_CompleteProfileView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    final provider = context.read<CompleteProfileProvider>();
    final int maxSteps = provider.isUpdateMode ? 3 : 4;

    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < maxSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submitProfile();
      }
    } else {
      // Show generic error snackbar
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
    }
  }

  Future<void> _submitProfile() async {
    final provider = context.read<CompleteProfileProvider>();
    final success = await provider.submitProfile();

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "An error occurred."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompleteProfileProvider>();
    final int maxSteps = provider.isUpdateMode ? 3 : 4;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.primaryPurple,
                        size: 24,
                      ),
                      onPressed: provider.isLoading ? null : _previousStep,
                    )
                  else
                    const SizedBox(width: 48),

                  Expanded(
                    child: Text(
                      provider.isUpdateMode ? "Update Profile" : "Complete Profile",
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
                children: List.generate(maxSteps, (index) {
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
                    ? "Step 2: Contact & Address"
                    : _currentPage == 2
                    ? "Step 3: Occupation"
                    : "Step 4: Set Password",
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
                children: [
                  StepPersonalDetails(formKey: _formKeys[0]),
                  StepContactAddress(formKey: _formKeys[1]),
                  StepOccupation(formKey: _formKeys[2]),
                  if (!provider.isUpdateMode) StepPassword(formKey: _formKeys[3]),
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
            onPressed: provider.isLoading ? null : _nextStep,
            child: provider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentPage == maxSteps - 1 ? 'Submit Profile' : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
