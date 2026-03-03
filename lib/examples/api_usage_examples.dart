import 'package:flutter/material.dart';
import 'package:bed_app/data/services/bed_service.dart';
import 'package:bed_app/data/services/ward_service.dart';
import 'package:bed_app/data/services/facility_service.dart';
import 'package:bed_app/data/models/bed_api_model.dart';
import 'package:bed_app/core/network/api_exceptions.dart';

/// Example 1: Simple Bed Listing
/// Demonstrates basic API usage to fetch and display beds
class BedsListExample extends StatefulWidget {
  @override
  _BedsListExampleState createState() => _BedsListExampleState();
}

class _BedsListExampleState extends State<BedsListExample> {
  final BedService _bedService = BedService();
  List<BedApiModel> _beds = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBeds();
  }

  Future<void> _loadBeds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _bedService.getAllBeds(
        page: 1,
        limit: 50,
      );
      
      setState(() {
        _beds = response.items;
        _isLoading = false;
      });
    } on NetworkException catch (e) {
      setState(() {
        _error = 'Network error: ${e.message}';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = 'API error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Beds')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Beds')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBeds,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Beds (${_beds.length})')),
      body: RefreshIndicator(
        onRefresh: _loadBeds,
        child: ListView.builder(
          itemCount: _beds.length,
          itemBuilder: (context, index) {
            final bed = _beds[index];
            return ListTile(
              title: Text('Bed ${bed.bedNumber}'),
              subtitle: Text('${bed.wardName} - ${bed.status}'),
              trailing: _buildStatusChip(bed.status),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Available':
        color = Colors.green;
        break;
      case 'Occupied':
        color = Colors.red;
        break;
      case 'Cleaning':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    
    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }
}

/// Example 2: Update Bed Status
/// Demonstrates how to update bed status with proper error handling
class UpdateBedStatusExample extends StatelessWidget {
  final String bedId = 'bed_123';
  final BedService _bedService = BedService();

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final updatedBed = await _bedService.updateBedStatus(bedId, newStatus);
      
      // Close loading
      Navigator.of(context).pop();
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bed status updated to ${updatedBed.status}'),
          backgroundColor: Colors.green,
        ),
      );
    } on ValidationException catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation error: ${e.message}'),
          backgroundColor: Colors.orange,
        ),
      );
    } on UnauthorizedException catch (e) {
      Navigator.of(context).pop();
      // Redirect to login
      Navigator.of(context).pushReplacementNamed('/login');
    } on ApiException catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Bed Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _updateStatus(context, 'Available'),
              child: Text('Mark as Available'),
            ),
            ElevatedButton(
              onPressed: () => _updateStatus(context, 'Occupied'),
              child: Text('Mark as Occupied'),
            ),
            ElevatedButton(
              onPressed: () => _updateStatus(context, 'Cleaning'),
              child: Text('Mark as Cleaning'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Get Bed Statistics
/// Demonstrates fetching analytics data
class BedStatsExample extends StatefulWidget {
  @override
  _BedStatsExampleState createState() => _BedStatsExampleState();
}

class _BedStatsExampleState extends State<BedStatsExample> {
  final BedService _bedService = BedService();
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _bedService.getBedStats();
      
      setState(() {
        _stats = {
          'total': stats.totalBeds,
          'available': stats.availableBeds,
          'occupied': stats.occupiedBeds,
          'occupancy': stats.occupancyRate,
        };
        _isLoading = false;
      });
    } on ApiException catch (e) {
      print('Error loading stats: ${e.message}');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16),
      children: [
        _buildStatCard('Total Beds', _stats['total']?.toString() ?? '0'),
        _buildStatCard('Available', _stats['available']?.toString() ?? '0', Colors.green),
        _buildStatCard('Occupied', _stats['occupied']?.toString() ?? '0', Colors.red),
        _buildStatCard('Occupancy', '${_stats['occupancy']?.toStringAsFixed(1) ?? '0'}%', Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, [Color? color]) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 4: Filter Beds by Ward
/// Demonstrates filtering with pagination
class FilterBedsByWardExample extends StatefulWidget {
  final String wardId;

  FilterBedsByWardExample({required this.wardId});

  @override
  _FilterBedsByWardExampleState createState() => _FilterBedsByWardExampleState();
}

class _FilterBedsByWardExampleState extends State<FilterBedsByWardExample> {
  final BedService _bedService = BedService();
  List<BedApiModel> _beds = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadBeds();
  }

  Future<void> _loadBeds() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await _bedService.getAllBeds(
        wardId: widget.wardId,
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        _beds.addAll(response.items);
        _hasMore = response.hasNext;
        _currentPage++;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      print('Error loading beds: ${e.message}');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ward Beds')),
      body: ListView.builder(
        itemCount: _beds.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _beds.length) {
            _loadBeds();
            return Center(child: CircularProgressIndicator());
          }

          final bed = _beds[index];
          return ListTile(
            title: Text('Bed ${bed.bedNumber}'),
            subtitle: Text(bed.status),
          );
        },
      ),
    );
  }
}

/// Example 5: Create New Bed
/// Demonstrates POST request to create a resource
class CreateBedExample extends StatefulWidget {
  @override
  _CreateBedExampleState createState() => _CreateBedExampleState();
}

class _CreateBedExampleState extends State<CreateBedExample> {
  final BedService _bedService = BedService();
  final _formKey = GlobalKey<FormState>();
  final _bedNumberController = TextEditingController();
  final _wardIdController = TextEditingController();
  final _floorController = TextEditingController();
  bool _isCreating = false;

  Future<void> _createBed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final newBed = await _bedService.createBed(
        CreateBedRequest(
          bedNumber: _bedNumberController.text,
          wardId: _wardIdController.text,
          floor: _floorController.text,
          status: 'Available',
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bed ${newBed.bedNumber} created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(newBed);
    } on ValidationException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation error: ${e.getAllFieldErrors()}'),
          backgroundColor: Colors.red,
        ),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Bed')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _bedNumberController,
              decoration: InputDecoration(labelText: 'Bed Number'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _wardIdController,
              decoration: InputDecoration(labelText: 'Ward ID'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _floorController,
              decoration: InputDecoration(labelText: 'Floor'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isCreating ? null : _createBed,
              child: _isCreating
                  ? CircularProgressIndicator()
                  : Text('Create Bed'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 6: Integration with existing BedProvider
/// Shows how to integrate API with existing Provider
import 'package:provider/provider.dart';

class ApiBedProvider extends ChangeNotifier {
  final BedService _bedService = BedService();
  
  List<BedApiModel> _beds = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedWardId;

  List<BedApiModel> get beds => _beds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBeds({String? wardId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _bedService.getAllBeds(
        wardId: wardId,
        status: status,
        page: 1,
        limit: 100,
      );
      
      _beds = response.items;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load beds: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBedStatus(String bedId, String status) async {
    try {
      final updatedBed = await _bedService.updateBedStatus(bedId, status);
      
      // Update local cache
      final index = _beds.indexWhere((b) => b.id == bedId);
      if (index != -1) {
        _beds[index] = updatedBed;
        notifyListeners();
      }
      
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  void setWard(String? wardId) {
    _selectedWardId = wardId;
    loadBeds(wardId: wardId);
  }

  List<BedApiModel> getAvailableBeds() {
    return _beds.where((bed) => bed.status == 'Available').toList();
  }

  List<BedApiModel> getOccupiedBeds() {
    return _beds.where((bed) => bed.status == 'Occupied').toList();
  }

  int get totalBeds => _beds.length;
  int get availableBeds => getAvailableBeds().length;
  int get occupiedBeds => getOccupiedBeds().length;
}
