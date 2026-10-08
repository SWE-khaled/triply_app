// Mock data for the Trips management screen
class MockTrip {
  final String title;
  final String guide;
  final String date;
  final int travelers;
  final String price;
  final String status; // 'active' | 'pending' | 'cancelled'

  const MockTrip({
    required this.title,
    required this.guide,
    required this.date,
    required this.travelers,
    required this.price,
    required this.status,
  });
}

final List<MockTrip> mockTrips = [
  MockTrip(
    title: 'Luxor & Aswan 4D',
    guide: 'Mahmoud Ali',
    date: 'Oct 12',
    travelers: 12,
    price: 'EGP 6,200',
    status: 'active',
  ),
  MockTrip(
    title: 'Cairo Pyramids Day',
    guide: 'Hany Samir',
    date: 'Oct 15',
    travelers: 8,
    price: 'EGP 1,450',
    status: 'active',
  ),
  MockTrip(
    title: 'Siwa Oasis 3D',
    guide: 'Omar Fathy',
    date: 'Oct 18',
    travelers: 6,
    price: 'EGP 4,800',
    status: 'pending',
  ),
  MockTrip(
    title: 'Alexandria Tour',
    guide: 'Mona Adel',
    date: 'Oct 20',
    travelers: 10,
    price: 'EGP 1,100',
    status: 'active',
  ),
];
