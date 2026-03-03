import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bed_app/Theme/app_theme.dart';
import 'package:bed_app/providers/bed_provider.dart';
import 'package:bed_app/providers/auth.dart';

class BedsScreen extends StatefulWidget {
  @override
  State<BedsScreen> createState() => _BedsScreenState();
}

class _BedsScreenState extends State<BedsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedWard = '';
  String _viewMode = 'grid'; // 'grid' or 'list'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Beds',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == 'grid' ? Icons.list : Icons.grid_view,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => setState(() {
              _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
            }),
          ),
        ],
      ),
      body: Consumer2<BedProvider, AuthProvider>(
        builder: (context, bedProvider, authProvider, _) {
          final beds = bedProvider.filteredBeds;
          final isAdmin = authProvider.currentUser?.role == 'Admin';

          if (bedProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (bedProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                  SizedBox(height: 16),
                  Text(
                    'Error loading beds',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    bedProvider.error!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => bedProvider.loadData(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ward selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter by Ward',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildWardChip('All', '', bedProvider),
                              ...bedProvider.wards.map(
                                (ward) => _buildWardChip(
                                  ward.name,
                                  ward.id,
                                  bedProvider,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status summary badges
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusSummary('Available', beds.where((b) => b.status == 'Available').length, AppTheme.successColor),
                          _buildStatusSummary('Occupied', beds.where((b) => b.status == 'Occupied').length, const Color(0xFFFF5630)),
                          _buildStatusSummary('Reserved', beds.where((b) => b.status == 'Reserved').length, const Color(0xFFFFAB00)),
                          _buildStatusSummary('Cleaning', beds.where((b) => b.status == 'Cleaning').length, AppTheme.secondaryColor),
                          _buildStatusSummary('Blocked', beds.where((b) => b.status == 'Blocked').length, const Color(0xFF6B778C)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: beds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hotel,
                              size: 64,
                              color: AppTheme.textSecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No beds found',
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _viewMode == 'grid'
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: beds.length,
                            itemBuilder: (context, index) => _buildBedCard(
                              beds[index],
                              bedProvider,
                              isAdmin,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: beds.length,
                            itemBuilder: (context, index) => _buildBedListItem(
                              beds[index],
                              bedProvider,
                              isAdmin,
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWardChip(String label, String ward, BedProvider bedProvider) {
    final isSelected = _selectedWard == ward;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedWard = ward);
          bedProvider.selectWard(ward);
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusSummary(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$status ($count)',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedCard(dynamic bed, BedProvider bedProvider, bool isAdmin) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/bed-detail', arguments: bed.id);
      },
      onLongPress: isAdmin
          ? () => _showStatusChangeMenu(context, bed, bedProvider)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background color accent
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: bed.statusColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(40),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bed ID and Room
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bed.number,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bed.ward,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bed.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: bed.statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: bed.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bed.status,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: bed.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Patient info
                  if (bed.currentPatient != null)
                    Text(
                      bed.currentPatient ?? 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  // Admin hint
                  if (isAdmin)
                    Text(
                      'Long press to change status',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: AppTheme.primaryColor,
                        fontStyle: FontStyle.italic,
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

  Widget _buildBedListItem(dynamic bed, BedProvider bedProvider, bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/bed-detail', arguments: bed.id);
        },
        onLongPress: isAdmin
            ? () => _showStatusChangeMenu(context, bed, bedProvider)
            : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bed.statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: bed.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bed info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bed.number,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          bed.ward,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: bed.statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bed.status,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: bed.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (bed.currentPatient != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Patient: ${bed.currentPatient}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // Admin controls or arrow
              if (isAdmin)
                IconButton(
                  icon: Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                  onPressed: () => _showStatusChangeMenu(context, bed, bedProvider),
                )
              else
                Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusChangeMenu(BuildContext context, dynamic bed, BedProvider bedProvider) {
    final statuses = ['Available', 'Occupied', 'Reserved', 'Cleaning', 'Blocked'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Bed Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Bed ${bed.number} - ${bed.ward}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ...statuses.map((status) {
              final isCurrentStatus = bed.status == status;
              final Color statusColor = _getStatusColor(status);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  child: InkWell(
                    onTap: isCurrentStatus
                        ? null
                        : () {
                            Navigator.pop(context);
                            _showConfirmationDialog(
                              context,
                              bed,
                              status,
                              bedProvider,
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentStatus
                            ? statusColor.withValues(alpha: 0.2)
                            : Colors.grey.shade100,
                        border: Border.all(
                          color: isCurrentStatus
                              ? statusColor
                              : Colors.grey.shade300,
                          width: isCurrentStatus ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            status,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isCurrentStatus
                                  ? statusColor
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (isCurrentStatus)
                            Icon(
                              Icons.check_circle,
                              color: statusColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    dynamic bed,
    String newStatus,
    BedProvider bedProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Status Change',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to change the status of Bed ${bed.number}?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bed.status,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_forward,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Status',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        newStatus,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(newStatus),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              bedProvider.updateBedStatus(bed.id, newStatus);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Bed ${bed.number} status changed to $newStatus',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: _getStatusColor(newStatus),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return AppTheme.successColor;
      case 'Occupied':
        return const Color(0xFFFF5630);
      case 'Reserved':
        return const Color(0xFFFFAB00);
      case 'Cleaning':
        return AppTheme.secondaryColor;
      case 'Blocked':
        return const Color(0xFF6B778C);
      default:
        return Colors.grey;
    }
  }
}
