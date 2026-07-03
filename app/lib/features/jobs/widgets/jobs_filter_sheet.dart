import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/job_provider.dart';

class JobsFilterSheet extends StatefulWidget {
  const JobsFilterSheet({super.key});

  @override
  State<JobsFilterSheet> createState() => _JobsFilterSheetState();
}

class _JobsFilterSheetState extends State<JobsFilterSheet> {
  late JobFilter _currentFilter;

  // Dynamic Fields from Backend Metadata
  List<String> _availableCities = [];
  List<String> _availableIndustries = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<JobProvider>();
    _currentFilter = JobFilter(
      cities: Set.from(provider.activeFilter.cities),
      industries: Set.from(provider.activeFilter.industries),
      search: provider.activeFilter.search,
    );

    _availableCities = provider.availableCities;
    _availableIndustries = provider.availableIndustries;
  }

  void _toggleSetSelection(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  Widget _buildDropdownFilterGroup(
    String title,
    List<String> options,
    Set<String> selectedOptions,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          dropdownColor: AppTheme.backgroundLight,
          decoration: InputDecoration(
            fillColor: AppTheme.backgroundLight,
            hintText: 'Select $title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: AppTheme.primaryPurple),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.primaryPurple,
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null && !selectedOptions.contains(value)) {
              _toggleSetSelection(selectedOptions, value);
            }
          },
          value: null,
        ),
        const SizedBox(height: 8),
        if (selectedOptions.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedOptions.map((option) {
              return InputChip(
                label: Text(option),
                onDeleted: () => _toggleSetSelection(selectedOptions, option),
                deleteIconColor: AppTheme.primaryPurple,
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: const BorderSide(color: Colors.transparent),
                ),
                labelStyle: GoogleFonts.inter(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Jobs',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_availableCities.isEmpty &&
                        _availableIndustries.isEmpty)
                      const Center(
                        child: Text(
                          "No filters available yet.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    _buildDropdownFilterGroup(
                      'City',
                      _availableCities,
                      _currentFilter.cities,
                    ),
                    _buildDropdownFilterGroup(
                      'Industry',
                      _availableIndustries,
                      _currentFilter.industries,
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<JobProvider>().clearFilter();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        side: const BorderSide(color: AppTheme.textLight),
                      ),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<JobProvider>().setFilter(_currentFilter);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
