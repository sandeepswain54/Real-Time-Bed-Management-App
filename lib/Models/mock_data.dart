import 'package:bed_app/Models/bed_model.dart';

class MockData {
  // Mock users for login
  static const mockUsers = [
    {'email': 'admin', 'password': 'admin', 'role': 'Admin'},
    {
      'email': 'operator@hospital.com',
      'password': 'operator123',
      'role': 'Operator'
    },
    {
      'email': 'maintenance@hospital.com',
      'password': 'maintenance123',
      'role': 'Maintenance Staff'
    },
  ];

  // Mock facilities
  static const facilities = [
    {'id': '1', 'name': 'Hospital A', 'location': 'Downtown', 'beds': 150},
    {'id': '2', 'name': 'Hospital B', 'location': 'Uptown', 'beds': 200},
    {'id': '3', 'name': 'Hostel', 'location': 'Campus', 'beds': 100},
    {
      'id': '4',
      'name': 'Emergency Center',
      'location': 'Central',
      'beds': 50
    },
  ];

  // Mock wards
  static const wards = [
    'ICU - Intensive Care',
    'General Ward',
    'Pediatrics',
    'Surgery',
    'Maternity',
    'Emergency',
    'Psychiatric',
    'Cardiology',
  ];

  // Mock patients
  static const patients = [
    {
      'id': 'P001',
      'name': 'John Smith',
      'age': 45,
      'condition': 'Hypertension'
    },
    {
      'id': 'P002',
      'name': 'Sarah Johnson',
      'age': 32,
      'condition': 'Post-Surgery Recovery'
    },
    {
      'id': 'P003',
      'name': 'Michael Chen',
      'age': 67,
      'condition': 'Cardiac Monitoring'
    },
    {
      'id': 'P004',
      'name': 'Emma Wilson',
      'age': 28,
      'condition': 'Orthopedic Care'
    },
    {
      'id': 'P005',
      'name': 'David Brown',
      'age': 55,
      'condition': 'Respiratory Support'
    },
    {
      'id': 'P006',
      'name': 'Lisa Anderson',
      'age': 41,
      'condition': 'General Recovery'
    },
    {
      'id': 'P007',
      'name': 'Robert Martinez',
      'age': 73,
      'condition': 'Long-term Care'
    },
    {
      'id': 'P008',
      'name': 'Jennifer Lee',
      'age': 29,
      'condition': 'Maternity Care'
    },
  ];

  // Generate mock beds
  static List<BedModel> generateMockBeds() {
    List<BedModel> beds = [];
    final statuses = ['Available', 'Occupied', 'Reserved', 'Cleaning', 'Blocked'];
    final mockPatients = [
      'John Smith',
      'Sarah Johnson',
      'Michael Chen',
      'Emma Wilson',
      'David Brown',
      'Lisa Anderson',
    ];

    int bedCounter = 0;
    for (int facility = 1; facility <= 4; facility++) {
      for (int ward = 1; ward <= 8; ward++) {
        for (int bed = 1; bed <= 5; bed++) {
          bedCounter++;
          final randomStatus = statuses[bedCounter % statuses.length];
          final facilityName = facilities[facility - 1]['name'] as String? ?? 'Hospital $facility';
          beds.add(
            BedModel(
              id: 'BED-${String.fromCharCode(65 + ward - 1)}$bedCounter',
              number: '$ward-${bed.toString().padLeft(2, '0')}',
              facility: facilityName,
              facilityId: facility.toString(),
              floor: ward.toString(),
              ward: wards[ward - 1],
              status: randomStatus,
              currentPatient: randomStatus == 'Occupied'
                  ? mockPatients[bedCounter % mockPatients.length]
                  : null,
              assignedPatient: randomStatus == 'Occupied'
                  ? mockPatients[bedCounter % mockPatients.length]
                  : null,
              lastUpdated: DateTime.now().subtract(
                Duration(minutes: (bedCounter % 120)),
              ),
              pricePerNight: 150.0 + (bedCounter * 10),
              amenities: ['TV', 'AC', 'WiFi', 'Bathroom'],
              notes: randomStatus == 'Cleaning'
                  ? 'Routine cleaning in progress'
                  : randomStatus == 'Maintenance'
                      ? 'Awaiting maintenance inspection'
                      : null,
            ),
          );
        }
      }
    }

    return beds;
  }

  // Analytics mock data
  static Map<String, dynamic> getAnalyticsData() {
    return {
      'utilization': [
        {'hour': '00:00', 'percentage': 45.0},
        {'hour': '04:00', 'percentage': 38.0},
        {'hour': '08:00', 'percentage': 72.0},
        {'hour': '12:00', 'percentage': 88.0},
        {'hour': '16:00', 'percentage': 92.0},
        {'hour': '20:00', 'percentage': 65.0},
        {'hour': '24:00', 'percentage': 55.0},
      ],
      'turnaroundTime': [
        {'day': 'Mon', 'hours': 4.2},
        {'day': 'Tue', 'hours': 3.8},
        {'day': 'Wed', 'hours': 5.1},
        {'day': 'Thu', 'hours': 4.5},
        {'day': 'Fri', 'hours': 6.2},
        {'day': 'Sat', 'hours': 5.9},
        {'day': 'Sun', 'hours': 4.1},
      ],
      'occupancyTrends': [
        {'week': 'W1', 'occupied': 120, 'available': 80},
        {'week': 'W2', 'occupied': 145, 'available': 55},
        {'week': 'W3', 'occupied': 160, 'available': 40},
        {'week': 'W4', 'occupied': 155, 'available': 45},
        {'week': 'W5', 'occupied': 135, 'available': 65},
      ]
    };
  }

  // Maintenance tasks
  static const maintenanceTasks = [
    {
      'id': 'TASK001',
      'bedId': 'BED-A1',
      'taskType': 'Cleaning',
      'status': 'In Progress',
      'priority': 'High',
      'assignedTo': 'John Doe'
    },
    {
      'id': 'TASK002',
      'bedId': 'BED-B5',
      'taskType': 'Maintenance',
      'status': 'Pending',
      'priority': 'Medium',
      'assignedTo': 'Jane Smith'
    },
    {
      'id': 'TASK003',
      'bedId': 'BED-C3',
      'taskType': 'Inspection',
      'status': 'Completed',
      'priority': 'Low',
      'assignedTo': 'Mike Johnson'
    },
    {
      'id': 'TASK004',
      'bedId': 'BED-D2',
      'taskType': 'Cleaning',
      'status': 'Pending',
      'priority': 'High',
      'assignedTo': 'Alice Brown'
    },
    {
      'id': 'TASK005',
      'bedId': 'BED-E4',
      'taskType': 'Repair',
      'status': 'In Progress',
      'priority': 'High',
      'assignedTo': 'Bob Wilson'
    },
  ];
}
