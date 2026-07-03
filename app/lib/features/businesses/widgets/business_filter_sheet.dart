import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/business_provider.dart';

class BusinessFilterSheet extends StatefulWidget {
  const BusinessFilterSheet({super.key});

  @override
  State<BusinessFilterSheet> createState() => _BusinessFilterSheetState();
}

class _BusinessFilterSheetState extends State<BusinessFilterSheet> {
  String? _selectedCategory;
  List<String> _selectedCities = [];
  List<String> _selectedOwnerGaons = [];
  List<String> _selectedOwnerNativeDistricts = [];
  List<String> _selectedOwnerNativeStates = [];
  List<String> _selectedOwnerGotras = [];

  @override
  void initState() {
    super.initState();
    final filter = context.read<BusinessProvider>().filter;
    _selectedCategory = filter.category;
    _selectedCities = List.from(filter.cities);
    _selectedOwnerGaons = List.from(filter.ownerGaons);
    _selectedOwnerNativeDistricts = List.from(filter.ownerNativeDistricts);
    _selectedOwnerNativeStates = List.from(filter.ownerNativeStates);
    _selectedOwnerGotras = List.from(filter.ownerGotras);
  }

  void _applyFilter() {
    context.read<BusinessProvider>().updateFilter(
      cities: _selectedCities,
      category: _selectedCategory,
      ownerGaons: _selectedOwnerGaons,
      ownerNativeDistricts: _selectedOwnerNativeDistricts,
      ownerNativeStates: _selectedOwnerNativeStates,
      ownerGotras: _selectedOwnerGotras,
    );
    Navigator.pop(context);
  }

  void _resetFilter() {
    context.read<BusinessProvider>().clearFilter();
    Navigator.pop(context);
  }

  Widget _buildDropdownFilterGroup({
    required String title,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
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
          value: options.contains(value) ? value : null,
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMultiSelectChips({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<List<String>> onChanged,
  }) {
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSelectedValues = List<String>.from(selectedValues);
                if (selected) {
                  newSelectedValues.add(option);
                } else {
                  newSelectedValues.remove(option);
                }
                onChanged(newSelectedValues);
              },
              selectedColor: AppTheme.primaryPurple,
              checkmarkColor: Colors.white,
              backgroundColor: AppTheme.backgroundLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryPurple : Colors.black12,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.75,
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
                    'Filter Directory',
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
                    _buildMultiSelectChips(
                      title: 'Business Cities',
                      options: provider.availableCities,
                      selectedValues: _selectedCities,
                      onChanged: (values) =>
                          setState(() => _selectedCities = values),
                    ),
                    _buildDropdownFilterGroup(
                      title: 'Category',
                      value: _selectedCategory,
                      options: provider.availableCategories,
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 24),
                    Text(
                      'Owner Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelectChips(
                      title: 'Native Village (Gaon)',
                      options: provider.availableGaons,
                      selectedValues: _selectedOwnerGaons,
                      onChanged: (values) =>
                          setState(() => _selectedOwnerGaons = values),
                    ),
                    _buildMultiSelectChips(
                      title: 'Native District',
                      options: provider.availableNativeDistricts,
                      selectedValues: _selectedOwnerNativeDistricts,
                      onChanged: (values) => setState(
                        () => _selectedOwnerNativeDistricts = values,
                      ),
                    ),
                    _buildMultiSelectChips(
                      title: 'Native State',
                      options: provider.availableNativeStates,
                      selectedValues: _selectedOwnerNativeStates,
                      onChanged: (values) =>
                          setState(() => _selectedOwnerNativeStates = values),
                    ),
                    _buildMultiSelectChips(
                      title: 'Gotra',
                      options: provider.availableGotras,
                      selectedValues: _selectedOwnerGotras,
                      onChanged: (values) =>
                          setState(() => _selectedOwnerGotras = values),
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
                      onPressed: _resetFilter,
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
                      onPressed: _applyFilter,
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
