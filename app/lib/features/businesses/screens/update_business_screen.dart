import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/update_business_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../models/business_model.dart';
import '../widgets/step_business_details.dart';
import '../widgets/step_business_contact.dart';

class UpdateBusinessScreen extends StatelessWidget {
  final BusinessListing currentBusiness;

  const UpdateBusinessScreen({super.key, required this.currentBusiness});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateBusinessProvider()..initFromBusiness(currentBusiness),
      child: const _UpdateBusinessView(),
    );
  }
}

class _UpdateBusinessView extends StatefulWidget {
  const _UpdateBusinessView();

  @override
  State<_UpdateBusinessView> createState() => _UpdateBusinessViewState();
}

class _UpdateBusinessViewState extends State<_UpdateBusinessView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _formKeys = [
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

    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submitUpdate();
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
      Navigator.of(context).pop(); // Go back if on first step
    }
  }

  Future<void> _submitUpdate() async {
    final provider = context.read<UpdateBusinessProvider>();
    final success = await provider.submitUpdate();

    if (success && mounted) {
      // Refresh the main user profile to get updated business data
      context.read<UserProvider>().fetchMyProfile();
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Business updated successfully!"),
          backgroundColor: Colors.green,
        ),
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
    final provider = context.watch<UpdateBusinessProvider>();

    return GradientBackground(
      child: Scaffold(
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
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.primaryPurple,
                        size: 24,
                      ),
                      onPressed: provider.isLoading ? null : _previousStep,
                    ),
                    Expanded(
                      child: Text(
                        "Update Business",
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
                  children: List.generate(2, (index) {
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
                      ? "Step 1: Business Details"
                      : "Step 2: Contact & Location",
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
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    StepBusinessDetails(formKey: _formKeys[0]),
                    StepBusinessContact(formKey: _formKeys[1]),
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
                      child: CupertinoActivityIndicator.partiallyRevealed(
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentPage == 1 ? 'Update Business' : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
