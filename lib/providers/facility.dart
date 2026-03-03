// lib/screens/facility_selector_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bed_provider.dart';
import '../theme/app_theme.dart';

class FacilitySelectorScreen extends StatelessWidget {
  final List<Map<String, dynamic>> facilities = [
    {
      'name': 'Main Hospital',
      'location': 'Downtown',
      'beds': 45,
      'occupancy': 78,
      'image': '🏥',
      'color': Color(0xFF0052CC),
    },
    {
      'name': 'City Clinic',
      'location': 'Uptown',
      'beds': 28,
      'occupancy': 65,
      'image': '🏨',
      'color': Color(0xFF00B8D9),
    },
    {
      'name': 'North Wing',
      'location': 'Northside',
      'beds': 32,
      'occupancy': 82,
      'image': '🏛️',
      'color': Color(0xFF36B37E),
    },
    {
      'name': 'South Campus',
      'location': 'Southside',
      'beds': 38,
      'occupancy': 71,
      'image': '🏬',
      'color': Color(0xFFFF5630),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bedProvider = Provider.of<BedProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Facility'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final facility = facilities[index];
          final isSelected = bedProvider.selectedFacility == facility['name'];
          
          return GestureDetector(
            onTap: () {
              bedProvider.setFacility(facility['name']);
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? facility['color'] : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: (facility['color'] as Color).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (facility['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        facility['image'],
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              facility['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (isSelected) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: facility['color'],
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          facility['location'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${facility['beds']} Beds',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${facility['occupancy']}% Occupied',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}