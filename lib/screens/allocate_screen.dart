import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bed_app/Theme/app_theme.dart';
import 'package:bed_app/providers/bed_provider.dart';

class AllocateScreen extends StatefulWidget {
  @override
  State<AllocateScreen> createState() => _AllocateScreenState();
}

class _AllocateScreenState extends State<AllocateScreen> {
  String? _selectedWard;
  String? _selectedBed;
  bool _isAllocating = false;
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientConditionController = TextEditingController();

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          'Allocate Bed',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<BedProvider>(
            builder: (context, bedProvider, _) {
              final availableBeds = bedProvider.beds
                  .where((b) => b.status == 'Available' && b.facilityId == bedProvider.selectedFacility)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepCard(
                    stepNumber: 1,
                    title: 'Patient Information',
                    children: [
                      TextFormField(
                        controller: _patientNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter patient name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _patientConditionController,
                        decoration: InputDecoration(
                          hintText: 'Enter condition/notes (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    stepNumber: 2,
                    title: 'Select Ward',
                    children: [
                      _buildDropdown(
                        value: _selectedWard,
                        hint: 'Choose a ward',
                        items: bedProvider.wards
                            .map<DropdownMenuItem<String>>((w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(w.name),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedWard = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    stepNumber: 3,
                    title: 'Select Available Bed',
                    children: [
                      if (availableBeds.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No available beds at the moment',
                            style: GoogleFonts.inter(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableBeds
                              .map((bed) => _buildBedChip(
                                    bed.id,
                                    selected: _selectedBed == bed.id,
                                    onTap: () => setState(() => _selectedBed = bed.id),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_patientNameController.text.isNotEmpty && _selectedWard != null && _selectedBed != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allocation Summary',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Patient', _patientNameController.text),
                          _buildSummaryRow('Ward', bedProvider.wards.firstWhere((w) => w.id == _selectedWard).name),
                          _buildSummaryRow('Bed', _selectedBed!),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_patientNameController.text.isNotEmpty &&
                              _selectedWard != null &&
                              _selectedBed != null &&
                              !_isAllocating)
                          ? () => _handleAllocation(bedProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isAllocating
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Confirm Allocation',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint),
        underline: Container(),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBedChip(String bedId, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          bedId,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAllocation(BedProvider bedProvider) async {
    setState(() => _isAllocating = true);
    
    try {
      await bedProvider.allocateBed(
        _selectedBed!,
        _patientNameController.text,
        _selectedWard!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bed allocated successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          _isAllocating = false;
          _patientNameController.clear();
          _patientConditionController.clear();
          _selectedWard = null;
          _selectedBed = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to allocate bed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isAllocating = false);
      }
    }
  }
}
