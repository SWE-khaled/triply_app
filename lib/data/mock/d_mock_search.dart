// Mock data for the Users management screen
class MockUser {
  final String name;
  final String email;
  final String phone;
  final String type; // 'Tourist' | 'Guide'
  final String activity; // e.g. '18 bookings' | '8 trips'
  final String status; // 'active' | 'suspended'

  const MockUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.activity,
    required this.status,
  });
}

final List<MockUser> mockUsers = [
  MockUser(
    name: 'Sara Ahmed',
    email: 'sara@email.com',
    phone: '+20 101 221 9044',
    type: 'Tourist',
    activity: '18 bookings',
    status: 'active',
  ),
  MockUser(
    name: 'John Miller',
    email: 'john@email.com',
    phone: '+1 415 555 0182',
    type: 'Tourist',
    activity: '6 bookings',
    status: 'active',
  ),
  MockUser(
    name: 'Nour Hassan',
    email: 'nour@email.com',
    phone: '+20 122 806 3371',
    type: 'Tourist',
    activity: '11 bookings',
    status: 'active',
  ),
  MockUser(
    name: 'Yasmin Ali',
    email: 'yasmin@guide.com',
    phone: '+20 100 441 2298',
    type: 'Guide',
    activity: '8 trips',
    status: 'active',
  ),
  MockUser(
    name: 'Karim Nabil',
    email: 'karim@guide.com',
    phone: '+20 111 782 1045',
    type: 'Guide',
    activity: '14 trips',
    status: 'suspended',
  ),
];
