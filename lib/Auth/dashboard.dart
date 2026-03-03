// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth.dart';
import '../providers/bed_provider.dart';
import '../Models/user_model.dart';
import '../Theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final bedProvider = Provider.of<BedProvider>(context, listen: false);
    setState(() => _isLoadingAnalytics = true);
    try {
      final analytics = await bedProvider.getAnalytics();
      setState(() {
        _analytics = analytics;
        _isLoadingAnalytics = false;
      });
    } catch (e) {
      setState(() => _isLoadingAnalytics = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load analytics: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bedProvider = Provider.of<BedProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(context, authProvider.currentUser!),
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No new notifications'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await bedProvider.loadData();
              await _loadAnalytics();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data refreshed'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: bedProvider.isLoading || _isLoadingAnalytics
          ? Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            authProvider.currentUser?.name ?? 'User',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              authProvider.currentUser?.role == UserRole.admin
                                  ? '👨‍💼 Administrator'
                                  : authProvider.currentUser?.role == UserRole.operator
                                      ? '👩‍💼 Bed Operator'
                                      : '🔧 Maintenance Staff',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        authProvider.currentUser?.avatar ?? '',
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Facility Selector
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/facility-selector');
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Facility',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              bedProvider.facilities.isNotEmpty
                                  ? bedProvider.facilities.firstWhere(
                                      (f) => f.id == bedProvider.selectedFacility,
                                      orElse: () => bedProvider.facilities.first,
                                    ).name
                                  : 'Loading...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Stats Cards
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Beds',
                    (_analytics?['totalBeds'] ?? 0).toString(),
                    Icons.hotel,
                    Color(0xFF0052CC),
                  ),
                  _buildStatCard(
                    'Available',
                    (_analytics?['available'] ?? 0).toString(),
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    'Occupied',
                    (_analytics?['occupied'] ?? 0).toString(),
                    Icons.person,
                    AppTheme.errorColor,
                  ),
                  _buildStatCard(
                    'Occupancy Rate',
                    '${_analytics?['occupancyRate'] ?? 0}%',
                    Icons.trending_up,
                    AppTheme.warningColor,
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickActionCard(
                      'Bed Grid',
                      Icons.grid_view,
                      AppTheme.primaryColor,
                      () => Navigator.pushNamed(context, '/bed-grid'),
                    ),
                    if (authProvider.currentUser?.role != UserRole.maintenance)
                      _buildQuickActionCard(
                        'Allocate Bed',
                        Icons.add_circle,
                        AppTheme.successColor,
                        () => Navigator.pushNamed(context, '/allocation'),
                      ),
                    if (authProvider.currentUser?.role == UserRole.admin)
                      _buildQuickActionCard(
                        'Analytics',
                        Icons.analytics,
                        AppTheme.warningColor,
                        () => Navigator.pushNamed(context, '/analytics'),
                      ),
                    if (authProvider.currentUser?.role == UserRole.maintenance)
                      _buildQuickActionCard(
                        'Maintenance',
                        Icons.build,
                        AppTheme.secondaryColor,
                        () => Navigator.pushNamed(context, '/maintenance'),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Real-time Allocations Feed
              if (bedProvider.recentAllocations.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-time Allocations',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bedProvider.recentAllocations.length,
                        separatorBuilder: (_, __) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final allocation = bedProvider.recentAllocations[index];
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppTheme.successColor,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
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
                                        'Bed ${allocation['bedNumber']} allocated',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Patient: ${allocation['patientName']} | ${allocation['ward']}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'now',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              // Occupancy Chart
              Container(
                padding: EdgeInsets.all(16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bed Status Overview',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Today',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: (_analytics?['available'] ?? 0).toDouble(),
                              title: '${_analytics?['available'] ?? 0}',
                              color: AppTheme.successColor,
                              radius: 50,
                              titleStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: (_analytics?['occupied'] ?? 0).toDouble(),
                              title: '${_analytics?['occupied'] ?? 0}',
                              color: AppTheme.errorColor,
                              radius: 50,
                              titleStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: (_analytics?['reserved'] ?? 0).toDouble(),
                              title: '${_analytics?['reserved'] ?? 0}',
                              color: AppTheme.warningColor,
                              radius: 50,
                              titleStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: (_analytics?['cleaning'] ?? 0).toDouble(),
                              title: '${_analytics?['cleaning'] ?? 0}',
                              color: AppTheme.secondaryColor,
                              radius: 50,
                              titleStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem('Available', AppTheme.successColor),
                        _buildLegendItem('Occupied', AppTheme.errorColor),
                        _buildLegendItem('Reserved', AppTheme.warningColor),
                        _buildLegendItem('Cleaning', AppTheme.secondaryColor),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Recent Activity
              Container(
                padding: EdgeInsets.all(16),
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
                      'Recent Activity',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildActivityItem(
                      'Bed A102 allocated to Robert Johnson',
                      '2 hours ago',
                      Icons.add_circle,
                      AppTheme.successColor,
                    ),
                    _buildActivityItem(
                      'Bed B202 marked for cleaning',
                      '3 hours ago',
                      Icons.cleaning_services,
                      AppTheme.secondaryColor,
                    ),
                    _buildActivityItem(
                      'Bed A103 reserved for Emily Davis',
                      '5 hours ago',
                      Icons.event_available,
                      AppTheme.warningColor,
                    ),
                    _buildActivityItem(
                      'Bed C302 checked out',
                      '6 hours ago',
                      Icons.exit_to_app,
                      AppTheme.errorColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User user) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, 50, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  SizedBox(height: 12),
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    Icons.dashboard,
                    'Dashboard',
                    () {
                      Navigator.pop(context);
                    },
                    true,
                  ),
                  _buildDrawerItem(
                    Icons.grid_view,
                    'Bed Grid',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/bed-grid');
                    },
                    false,
                  ),
                  _buildDrawerItem(
                    Icons.add_circle,
                    'Allocate Bed',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/allocation');
                    },
                    false,
                  ),
                  _buildDrawerItem(
                    Icons.analytics,
                    'Analytics',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/analytics');
                    },
                    false,
                  ),
                  _buildDrawerItem(
                    Icons.build,
                    'Maintenance',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/maintenance');
                    },
                    false,
                  ),
                  _buildDrawerItem(
                    Icons.location_on,
                    'Facilities',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/facility-selector');
                    },
                    false,
                  ),
                  Divider(),
                  _buildDrawerItem(
                    Icons.logout,
                    'Logout',
                    () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isSelected) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: EdgeInsets.only(right: 12),
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  time,
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
    );
  }
}