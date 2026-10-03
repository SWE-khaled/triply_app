// Mock data for Bookings, Notifications, and Places

// ── Bookings ────────────────────────────────────────────
class MockBooking {
  final String user;
  final String trip;
  final String guide;
  final String date;
  final String status; // 'confirmed' | 'pending' | 'cancelled'
  final String price;
  final String type; // 'Private' | 'Public'

  const MockBooking({
    required this.user,
    required this.trip,
    required this.guide,
    required this.date,
    required this.status,
    required this.price,
    required this.type,
  });
}

final List<MockBooking> mockBookings = [
  MockBooking(
    user: 'Sara Ahmed',
    trip: 'Luxor & Aswan 4D',
    guide: 'Mahmoud Ali',
    date: 'Oct 02',
    status: 'confirmed',
    price: 'EGP 6,200',
    type: 'Private',
  ),
  MockBooking(
    user: 'John Miller',
    trip: 'Cairo Pyramids Day',
    guide: 'Hany Samir',
    date: 'Oct 02',
    status: 'pending',
    price: 'EGP 1,450',
    type: 'Public',
  ),
  MockBooking(
    user: 'Nour Hassan',
    trip: 'Siwa Oasis 3D',
    guide: 'Omar Fathy',
    date: 'Oct 01',
    status: 'confirmed',
    price: 'EGP 4,800',
    type: 'Public',
  ),
  MockBooking(
    user: 'Lina Schmidt',
    trip: 'Alexandria Tour',
    guide: 'Mona Adel',
    date: 'Sep 30',
    status: 'cancelled',
    price: 'EGP 1,100',
    type: 'Public',
  ),
  MockBooking(
    user: 'Youssef Ali',
    trip: 'Dahab Diving 2D',
    guide: 'Karim Nabil',
    date: 'Sep 30',
    status: 'confirmed',
    price: 'EGP 3,300',
    type: 'Private',
  ),
];

// ── Notifications (not visible in main flow but required by structure) ──
class MockNotification {
  final String title;
  final String body;
  final String time;

  const MockNotification({
    required this.title,
    required this.body,
    required this.time,
  });
}

final List<MockNotification> mockNotifications = [
  MockNotification(
    title: 'New guide application',
    body: 'Mariam Adel submitted verification documents.',
    time: '10:24 AM',
  ),
  MockNotification(
    title: 'Trip application pending',
    body: 'Luxor & Aswan 4D is awaiting your review.',
    time: '09:10 AM',
  ),
  MockNotification(
    title: 'Booking cancelled',
    body: 'Lina Schmidt cancelled Alexandria Tour booking.',
    time: 'Yesterday',
  ),
];

// ── Places (not used directly in admin but part of project structure) ──
class MockPlace {
  final String name;
  final String city;
  final String imageUrl;

  const MockPlace({
    required this.name,
    required this.city,
    required this.imageUrl,
  });
}

final List<MockPlace> mockPlaces = [
  MockPlace(
    name: 'Great Pyramid of Giza',
    city: 'Giza',
    imageUrl: 'https://picsum.photos/seed/giza/400/300',
  ),
  MockPlace(
    name: 'Karnak Temple',
    city: 'Luxor',
    imageUrl: 'https://picsum.photos/seed/luxor/400/300',
  ),
  MockPlace(
    name: 'Abu Simbel',
    city: 'Aswan',
    imageUrl: 'https://picsum.photos/seed/aswan/400/300',
  ),
];
