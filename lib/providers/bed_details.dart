// lib/screens/bed_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bed_provider.dart';
import '../providers/auth.dart';
import '../Models/bed_model.dart';
import '../Models/user_model.dart';
import '../Theme/app_theme.dart';

class BedDetailScreen extends StatefulWidget {
  @override
  _BedDetailScreenState createState() => _BedDetailScreenState();
}

class _BedDetailScreenState extends State<BedDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
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
    final bedId = ModalRoute.of(context)!.settings.arguments as String;
    final bedProvider = Provider.of<BedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final bed = bedProvider.getBedById(bedId);

    if (bed == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Bed not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bed ${bed.number}'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Edit bed details (Demo)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Status Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bed.statusColor, bed.statusColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: bed.statusColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bed.statusText,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: bed.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusChip('Available', 'Available', bed, authProvider.currentUser!),
                        _buildStatusChip('Occupied', 'Occupied', bed, authProvider.currentUser!),
                        _buildStatusChip('Reserved', 'Reserved', bed, authProvider.currentUser!),
                        _buildStatusChip('Cleaning', 'Cleaning', bed, authProvider.currentUser!),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Bed Details
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bed Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Bed Number', bed.number),
                    _buildDetailRow('Floor', bed.floor),
                    _buildDetailRow('Ward', bed.ward),
                    _buildDetailRow('Facility', bed.facility),
                    _buildDetailRow('Price/Night', '\$${bed.pricePerNight.toStringAsFixed(2)}'),
                    if (bed.lastMaintenance != null)
                      _buildDetailRow('Last Maintenance', _dateFormat.format(DateTime.parse(bed.lastMaintenance!))),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Current Patient (if occupied)
              if (bed.currentPatient != null)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Patient',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(Icons.person, color: AppTheme.primaryColor),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bed.currentPatient!,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (bed.checkInTime != null)
                                  Text(
                                    'Check-in: ${_dateFormat.format(bed.checkInTime!)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                if (bed.expectedCheckOut != null)
                                  Text(
                                    'Expected Check-out: ${_dateFormat.format(bed.expectedCheckOut!)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),

              // Amenities
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: bed.amenities.map((amenity) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenity,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Action Buttons
              if (authProvider.currentUser?.role != 'Maintenance')
                Row(
                  children: [
                    if (bed.status == 'Available' || bed.status == 'Reserved')
                      Expanded(
                        child: _buildActionButton(
                          'Allocate',
                          Icons.add_circle,
                          AppTheme.successColor,
                          () {
                            Navigator.pushNamed(
                              context,
                              '/allocation',
                              arguments: bed.id,
                            );
                          },
                        ),
                      ),
                    if (bed.status == 'Occupied')
                      Expanded(
                        child: _buildActionButton(
                          'Release',
                          Icons.exit_to_app,
                          AppTheme.errorColor,
                          () {
                            _showConfirmationDialog(
                              context,
                              'Release Bed',
                              'Are you sure you want to release this bed?',
                              () {
                                bedProvider.releaseBed(bed.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bed released successfully'),
                                    backgroundColor: AppTheme.successColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    if (bed.status == 'Occupied')
                      SizedBox(width: 12),
                    if (bed.status == 'Occupied')
                      Expanded(
                        child: _buildActionButton(
                          'Transfer',
                          Icons.swap_horiz,
                          AppTheme.warningColor,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Transfer bed (Demo feature)'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              
              if (authProvider.currentUser?.role == 'Maintenance' && bed.status != 'Cleaning')
                SizedBox(height: 12),
              
              if (authProvider.currentUser?.role == 'Maintenance' && bed.status != 'Cleaning')
                _buildActionButton(
                  'Mark for Cleaning',
                  Icons.cleaning_services,
                  AppTheme.secondaryColor,
                  () {
                    bedProvider.updateBedStatus(bed.id, 'Cleaning');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bed marked for cleaning'),
                        backgroundColor: AppTheme.successColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status, BedModel bed, User user) {
    final isActive = bed.status == status;
    final canChange = user.role == 'Admin' || user.role == 'Operator';
    
    return GestureDetector(
      onTap: canChange ? () {
        Provider.of<BedProvider>(context, listen: false).updateBedStatus(bed.id, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bed status updated to $label'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } : null,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive 
                  ? bed.statusColor 
                  : (canChange ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: isActive 
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}