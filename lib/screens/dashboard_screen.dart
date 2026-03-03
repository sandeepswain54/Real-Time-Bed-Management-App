import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bed_app/Theme/app_theme.dart';
import 'package:bed_app/providers/bed_provider.dart';
import 'package:bed_app/providers/auth.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _simulationCounter = 0;

  @override
  void initState() {
    super.initState();
    _startRealtimeSimulation();
  }

  void _startRealtimeSimulation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final bedProvider = Provider.of<BedProvider>(context, listen: false);
        final beds = bedProvider.beds;
        if (beds.isNotEmpty) {
          _simulationCounter = (_simulationCounter + 1) % beds.length;
          final randomBed = beds[_simulationCounter];

          // Simulate status changes
          if (randomBed.status != 'Occupied' && randomBed.status != 'Blocked') {
            final statuses = ['Available', 'Available', 'Reserved', 'Cleaning'];
            final newStatus = statuses[_simulationCounter % statuses.length];
            bedProvider.updateBedStatus(randomBed.id, newStatus);
          }
        }
        _startRealtimeSimulation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer2<BedProvider, AuthProvider>(
            builder: (context, bedProvider, authProvider, _) {
              final facility =
                  bedProvider.selectedFacility.isNotEmpty ? bedProvider.selectedFacility : '';

              return FutureBuilder<Map<String, int>>(
                future: bedProvider.getBedStats(facility),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {
                    'total': 0,
                    'available': 0,
                    'occupied': 0,
                    'reserved': 0,
                    'cleaning': 0,
                    'blocked': 0,
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(authProvider),
                      const SizedBox(height: 24),
                      _buildFacilitySelector(bedProvider),
                      const SizedBox(height: 24),
                      Text(
                        'Bed Status Overview',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatisticGrid(stats),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Text(
        'Dashboard',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${user?.name}!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${user?.role} • ${user?.facility}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySelector(BedProvider bedProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: bedProvider.selectedFacility.isEmpty ? null : bedProvider.selectedFacility,
        isExpanded: true,
        underline: Container(),
        hint: Text('Select Facility', style: GoogleFonts.inter(fontSize: 14)),
        items: bedProvider.facilities
            .map((facility) => DropdownMenuItem<String>(
                  value: facility.id,
                  child: Text(
                    facility.name,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ))
            .toList(),
        onChanged: (String? value) {
          if (value != null) {
            bedProvider.selectFacility(value);
          }
        },
      ),
    );
  }

  Widget _buildStatisticGrid(Map<String, int> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          title: 'Total',
          value: stats['total']?.toString() ?? '0',
          icon: Icons.hotel_rounded,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Available',
          value: stats['available']?.toString() ?? '0',
          icon: Icons.check_circle_rounded,
          color: AppTheme.successColor,
        ),
        _buildStatCard(
          title: 'Occupied',
          value: stats['occupied']?.toString() ?? '0',
          icon: Icons.people_rounded,
          color: AppTheme.errorColor,
        ),
        _buildStatCard(
          title: 'Reserved',
          value: stats['reserved']?.toString() ?? '0',
          icon: Icons.lock_clock_rounded,
          color: AppTheme.warningColor,
        ),
        _buildStatCard(
          title: 'Cleaning',
          value: stats['cleaning']?.toString() ?? '0',
          icon: Icons.cleaning_services_rounded,
          color: AppTheme.secondaryColor,
        ),
        _buildStatCard(
          title: 'Blocked',
          value: stats['blocked']?.toString() ?? '0',
          icon: Icons.block_rounded,
          color: const Color(0xFF6B778C),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'View Beds',
                icon: Icons.bed_rounded,
                onTap: () {
                  // Navigate to beds screen
                  // This will be handled by bottom navigation
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Allocate',
                icon: Icons.add_circle_outline_rounded,
                onTap: () {
                  // Navigate to allocate screen
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
