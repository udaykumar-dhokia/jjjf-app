import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/matrimony_provider.dart';

class MatrimonyFilterSheet extends StatefulWidget {
  const MatrimonyFilterSheet({super.key});

  @override
  State<MatrimonyFilterSheet> createState() => _MatrimonyFilterSheetState();
}

class _MatrimonyFilterSheetState extends State<MatrimonyFilterSheet> {
  late MatrimonyFilter _currentFilter;

  List<String> _availableGotras = [];
  List<String> _availableEducation = [];
  List<String> _availableHeights = [];
  List<String> _availableCities = [];

  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<MatrimonyProvider>();
    _currentFilter = provider.activeFilter.copyWith();

    _availableGotras = provider.availableGotras;
    _availableEducation = provider.availableEducation;
    _availableHeights = provider.availableHeights;
    _availableCities = provider.availableCities;

    if (_currentFilter.minAge != null) {
      _minAgeController.text = _currentFilter.minAge.toString();
    }
    if (_currentFilter.maxAge != null) {
      _maxAgeController.text = _currentFilter.maxAge.toString();
    }
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  // Removed _toggleSetSelection, using callbacks instead
  Widget _buildAgeRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Age Range',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Min Age',
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  _currentFilter = _currentFilter.copyWith(
                    minAge: int.tryParse(val),
                    clearMinAge: val.isEmpty,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Max Age',
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  _currentFilter = _currentFilter.copyWith(
                    maxAge: int.tryParse(val),
                    clearMaxAge: val.isEmpty,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Gender',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          children: ['MALE', 'FEMALE', 'Any'].map((g) {
            final isSelected =
                (g == 'Any' && _currentFilter.gender == null) ||
                (_currentFilter.gender == g);
            return ChoiceChip(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              label: Text(
                g == 'Any' ? 'Any' : (g == 'MALE' ? 'Male' : 'Female'),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      gender: g == 'Any' ? null : g,
                      clearGender: g == 'Any',
                    );
                  });
                }
              },
              selectedColor: AppTheme.primaryPurple.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownFilterGroup(
    String title,
    List<String> options,
    Set<String> selectedOptions,
    void Function(String) onToggle,
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
              onToggle(value);
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
                onDeleted: () => onToggle(option),
                deleteIconColor: AppTheme.primaryPurple,
                backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
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
                    'Filter Profiles',
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
                    _buildGenderSelector(),
                    _buildAgeRange(),
                    _buildDropdownFilterGroup(
                      'Location / City',
                      _availableCities,
                      _currentFilter.cities,
                      (val) {
                        final newSet = Set<String>.from(_currentFilter.cities);
                        newSet.contains(val)
                            ? newSet.remove(val)
                            : newSet.add(val);
                        setState(
                          () => _currentFilter = _currentFilter.copyWith(
                            cities: newSet,
                          ),
                        );
                      },
                    ),
                    _buildDropdownFilterGroup(
                      'Education',
                      _availableEducation,
                      _currentFilter.education,
                      (val) {
                        final newSet = Set<String>.from(
                          _currentFilter.education,
                        );
                        newSet.contains(val)
                            ? newSet.remove(val)
                            : newSet.add(val);
                        setState(
                          () => _currentFilter = _currentFilter.copyWith(
                            education: newSet,
                          ),
                        );
                      },
                    ),
                    _buildDropdownFilterGroup(
                      'Height',
                      _availableHeights,
                      _currentFilter.heights,
                      (val) {
                        final newSet = Set<String>.from(_currentFilter.heights);
                        newSet.contains(val)
                            ? newSet.remove(val)
                            : newSet.add(val);
                        setState(
                          () => _currentFilter = _currentFilter.copyWith(
                            heights: newSet,
                          ),
                        );
                      },
                    ),
                    _buildDropdownFilterGroup(
                      'Gotra / Subcaste',
                      _availableGotras,
                      _currentFilter.gotras,
                      (val) {
                        final newSet = Set<String>.from(_currentFilter.gotras);
                        newSet.contains(val)
                            ? newSet.remove(val)
                            : newSet.add(val);
                        setState(
                          () => _currentFilter = _currentFilter.copyWith(
                            gotras: newSet,
                          ),
                        );
                        _buildDropdownFilterGroup(
                          'Exclude Gotra',
                          _availableGotras,
                          _currentFilter.excludeGotras,
                          (val) {
                            final newSet = Set<String>.from(
                              _currentFilter.excludeGotras,
                            );
                            newSet.contains(val)
                                ? newSet.remove(val)
                                : newSet.add(val);
                            setState(
                              () => _currentFilter = _currentFilter.copyWith(
                                excludeGotras: newSet,
                              ),
                            );
                          },
                        );
                      },
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
                        context.read<MatrimonyProvider>().clearFilter();
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
                        context.read<MatrimonyProvider>().setFilter(
                          _currentFilter,
                        );
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
