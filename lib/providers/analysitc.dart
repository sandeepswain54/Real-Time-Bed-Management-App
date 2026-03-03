// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bed_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final DateFormat _dateFormat = DateFormat('MMM dd');
  String _selectedPeriod = 'Week';
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = true;

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
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bedProvider = Provider.of<BedProvider>(context);

    if (_isLoadingAnalytics || bedProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Analytics')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Week', child: Text('This Week')),
              PopupMenuItem(value: 'Month', child: Text('This Month')),
              PopupMenuItem(value: 'Quarter', child: Text('This Quarter')),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Key Metrics
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Occupancy Rate',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              '${(_analytics?['occupancyRate'] ?? 0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (_analytics?['occupancyRate'] ?? 0) / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Status Distribution
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
                      'Bed Status Distribution',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (_analytics?['totalBeds'] ?? 100).toDouble(),
                          barGroups: [
                            _buildBarGroup('Available', _analytics?['available'] ?? 0, AppTheme.successColor),
                            _buildBarGroup('Occupied', _analytics?['occupied'] ?? 0, AppTheme.errorColor),
                            _buildBarGroup('Reserved', _analytics?['reserved'] ?? 0, AppTheme.warningColor),
                            _buildBarGroup('Cleaning', _analytics?['cleaning'] ?? 0, AppTheme.secondaryColor),
                            _buildBarGroup('Blocked', _analytics?['blocked'] ?? 0, Colors.grey),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = ['Avail', 'Occ', 'Res', 'Clean', 'Block'];
                                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                    return Text(
                                      titles[value.toInt()],
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Revenue Chart
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue Trend',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
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
                            _selectedPeriod,
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
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 1000,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < 7) {
                                    return Text(
                                      _dateFormat.format(DateTime.now().subtract(Duration(days: 6 - value.toInt()))),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 1200),
                                FlSpot(1, 1800),
                                FlSpot(2, 1500),
                                FlSpot(3, 2100),
                                FlSpot(4, 1900),
                                FlSpot(5, 2400),
                                FlSpot(6, 2800),
                              ],
                              isCurved: true,
                              color: AppTheme.primaryColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Additional Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatsCard(
                    'Avg. Turnaround',
                    '2.5 hrs',
                    Icons.timer,
                    AppTheme.warningColor,
                  ),
                  _buildStatsCard(
                    'Peak Hours',
                    '10 AM - 2 PM',
                    Icons.access_time,
                    AppTheme.secondaryColor,
                  ),
                  _buildStatsCard(
                    'Cleaning Time',
                    '45 min',
                    Icons.cleaning_services,
                    AppTheme.successColor,
                  ),
                  _buildStatsCard(
                    'No-show Rate',
                    '8%',
                    Icons.cancel,
                    AppTheme.errorColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(String label, int value, Color color) {
    return BarChartGroupData(
      x: ['Available', 'Occupied', 'Reserved', 'Cleaning', 'Blocked'].indexOf(label),
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: color,
          width: 22,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
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
}