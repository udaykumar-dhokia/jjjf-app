import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/create_job_provider.dart';
import '../../../providers/job_provider.dart';
import '../widgets/step_job_basics.dart';
import '../widgets/step_job_location.dart';
import '../widgets/step_job_details.dart';

class CreateJobScreen extends StatelessWidget {
  const CreateJobScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateJobProvider(),
      child: const _CreateJobView(),
    );
  }
}

class _CreateJobView extends StatefulWidget {
  const _CreateJobView();

  @override
  State<_CreateJobView> createState() => _CreateJobViewState();
}

class _CreateJobViewState extends State<_CreateJobView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _maxSteps = 3;

  final _formKeys = [
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
    final provider = context.read<CreateJobProvider>();

    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < _maxSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submitJob(provider);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields correctly."),
          backgroundColor: Colors.red,
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

  Future<void> _submitJob(CreateJobProvider provider) async {
    final success = await provider.submitJob();
    if (success && mounted) {
      // Refresh the job feed globally so the new post appears
      context.read<JobProvider>().fetchJobs();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully created!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Go back to Jobs screen
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
    final provider = context.watch<CreateJobProvider>();

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
                    onPressed: provider.isLoading 
                      ? null 
                      : (_currentPage > 0 ? _previousStep : () => Navigator.of(context).pop()),
                  ),
                  Expanded(
                    child: Text(
                      "Create Job",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance back button
                ],
              ),
            ),

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

            // Step Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _currentPage == 0
                    ? "Step 1: Basics"
                    : _currentPage == 1
                    ? "Step 2: Location & Compensation"
                    : "Step 3: Details",
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
                  StepJobBasics(formKey: _formKeys[0]),
                  StepJobLocation(formKey: _formKeys[1]),
                  StepJobDetails(formKey: _formKeys[2]),
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
                    _currentPage == _maxSteps - 1 ? 'Submit' : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    ));
  }
}
