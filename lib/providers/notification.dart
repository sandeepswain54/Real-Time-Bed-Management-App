// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Bed A102 Ready for Cleaning',
      'message': 'Patient discharged from bed A102. Cleaning required.',
      'time': DateTime.now().subtract(Duration(minutes: 15)),
      'type': 'cleaning',
      'read': false,
    },
    {
      'title': 'New Allocation - Bed B201',
      'message': 'Bed B201 allocated to Michael Chen (ICU)',
      'time': DateTime.now().subtract(Duration(hours: 2)),
      'type': 'allocation',
      'read': false,
    },
    {
      'title': 'Maintenance Request',
      'message': 'Bed C301 reported AC issue',
      'time': DateTime.now().subtract(Duration(hours: 5)),
      'type': 'maintenance',
      'read': true,
    },
    {
      'title': 'Low Occupancy Alert',
      'message': 'North Wing occupancy below 50%',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'type': 'alert',
      'read': true,
    },
    {
      'title': 'Bed D102 Blocked',
      'message': 'Bed D102 marked for maintenance',
      'time': DateTime.now().subtract(Duration(days: 2)),
      'type': 'maintenance',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n['read']).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All notifications marked as read'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final time = notification['time'] as DateTime;
          final timeString = _getTimeString(time);
          
          return Container(
            margin: EdgeInsets.only(bottom: 12),
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
              border: !notification['read']
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                  size: 24,
                ),
              ),
              title: Text(
                notification['title'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    timeString,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Mark as read and navigate
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening notification...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getTimeString(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(time);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'allocation':
        return Icons.add_circle;
      case 'maintenance':
        return Icons.build;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'cleaning':
        return AppTheme.secondaryColor;
      case 'allocation':
        return AppTheme.successColor;
      case 'maintenance':
        return AppTheme.warningColor;
      case 'alert':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}