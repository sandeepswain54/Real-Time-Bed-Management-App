// lib/screens/maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bed_provider.dart';
import '../Models/bed_model.dart';
import '../Theme/app_theme.dart';

class MaintenanceScreen extends StatefulWidget {
  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final DateFormat _dateFormat = DateFormat('MMM dd, hh:mm a');
  String _selectedTab = 'Pending';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
    final bedProvider = Provider.of<BedProvider>(context, listen: false);
    final cleaningBeds = bedProvider.getBedsByFacility('1')
        .where((b) => b.status == 'Cleaning')
        .toList();
    final maintenanceBeds = bedProvider.getBedsByFacility('1')
        .where((b) => b.status == 'Blocked')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance'),
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _selectedTab = index == 0 ? 'Pending' : 'History';
            });
          },
          tabs: [
            Tab(text: 'Pending (${cleaningBeds.length})'),
            Tab(text: 'History'),
          ],
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _selectedTab == 'Pending'
            ? _buildPendingTasks(cleaningBeds, maintenanceBeds, bedProvider)
            : _buildHistory(),
      ),
    );
  }

  Widget _buildPendingTasks(List<BedModel> cleaningBeds, List<BedModel> maintenanceBeds, BedProvider bedProvider) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (cleaningBeds.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Cleaning Required',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ...cleaningBeds.map((bed) => _buildMaintenanceCard(
            bed,
            'Cleaning',
            Icons.cleaning_services,
            AppTheme.secondaryColor,
            () {
              bedProvider.updateBedStatus(bed.id, 'Available');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bed ${bed.number} marked as clean'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )),
        ],
        if (maintenanceBeds.isNotEmpty) ...[
          if (cleaningBeds.isNotEmpty) SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Maintenance Required',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ...maintenanceBeds.map((bed) => _buildMaintenanceCard(
            bed,
            'Maintenance',
            Icons.build,
            AppTheme.warningColor,
            () {
              bedProvider.updateBedStatus(bed.id, 'Available');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bed ${bed.number} repaired'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )),
        ],
        if (cleaningBeds.isEmpty && maintenanceBeds.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'No pending maintenance tasks',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMaintenanceCard(BedModel bed, String type, IconData icon, Color color, VoidCallback onComplete) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bed ${bed.number}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  bed.ward,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (bed.lastMaintenance != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Last: ${_dateFormat.format(DateTime.parse(bed.lastMaintenance!))}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: Size(80, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    // Mock maintenance history
    final historyItems = [
      {
        'bed': 'A101',
        'task': 'Cleaning',
        'completed': '2 hours ago',
        'by': 'John Smith',
      },
      {
        'bed': 'B202',
        'task': 'Repair',
        'completed': '5 hours ago',
        'by': 'Mike Johnson',
      },
      {
        'bed': 'C301',
        'task': 'Cleaning',
        'completed': '1 day ago',
        'by': 'Sarah Wilson',
      },
      {
        'bed': 'D102',
        'task': 'Maintenance',
        'completed': '2 days ago',
        'by': 'Tom Brown',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
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
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bed ${item['bed']} - ${item['task']}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Completed by ${item['by']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item['completed']!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}