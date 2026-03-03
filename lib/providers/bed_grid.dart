// lib/screens/bed_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bed_provider.dart';
import '../Models/bed_model.dart';
import '../Theme/app_theme.dart';

class BedGridScreen extends StatefulWidget {
  @override
  _BedGridScreenState createState() => _BedGridScreenState();
}

class _BedGridScreenState extends State<BedGridScreen> with SingleTickerProviderStateMixin {
  String? _selectedWard;
  late AnimationController _animationController;
  List<String> _wards = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bedProvider = Provider.of<BedProvider>(context);
    final beds = bedProvider.getBedsByFacility(bedProvider.selectedFacility);
    
    // Get unique wards
    _wards = beds.map((b) => b.ward).toSet().toList();
    
    // Filter by selected ward
    final filteredBeds = _selectedWard == null 
        ? beds 
        : beds.where((b) => b.ward == _selectedWard).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bed Grid'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            height: 50,
            margin: EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', null, _selectedWard == null),
                ..._wards.map((ward) => _buildFilterChip(ward, ward, _selectedWard == ward)),
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredBeds.length,
          itemBuilder: (context, index) {
            final bed = filteredBeds[index];
            return _buildBedCard(bed);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWard = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBedCard(BedModel bed) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/bed-detail',
          arguments: bed.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: bed.statusColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: bed.statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bed.statusColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bed.number,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bed.ward,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (bed.currentPatient != null)
                        Text(
                          bed.currentPatient!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bed.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bed.statusText,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: bed.statusColor,
                          ),
                        ),
                      ),
                      if (bed.pricePerNight > 0)
                        Text(
                          '\$${bed.pricePerNight.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                    ],
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