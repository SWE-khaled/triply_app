// Mock data for guide verification table
class MockGuide {
  final String name;
  final String email;
  final String document;
  final String city;
  final String status; // 'pending' | 'approved' | 'suspended'
  final String phone;
  final String submitted;
  final String docFileName;
  final List<MockUploadedTrip> uploadedTrips;

  const MockGuide({
    required this.name,
    required this.email,
    required this.document,
    required this.city,
    required this.status,
    this.phone = '',
    this.submitted = '',
    this.docFileName = '',
    this.uploadedTrips = const [],
  });
}

class MockUploadedTrip {
  final String title;
  final String status;

  const MockUploadedTrip({required this.title, required this.status});
}

final List<MockGuide> mockGuides = [
  MockGuide(
    name: 'Mariam Adel',
    email: 'mariam@guide.com',
    document: 'Tour Guide ID',
    city: 'Cairo',
    status: 'pending',
    phone: '+20 101 245 8890',
    submitted: 'Today, 10:24 AM',
    docFileName: 'mariam-guide-id.pdf',
    uploadedTrips: [
      MockUploadedTrip(title: 'Pyramids Golden Hour', status: 'Active'),
      MockUploadedTrip(title: 'Old Cairo Stories', status: 'Pending Review'),
    ],
  ),
  MockGuide(
    name: 'Omar Fathy',
    email: 'omar@guide.com',
    document: 'Syndicate Membership',
    city: 'Giza',
    status: 'pending',
    phone: '+20 100 332 7761',
    submitted: 'Today, 09:10 AM',
    docFileName: 'omar-syndicate.pdf',
    uploadedTrips: [
      MockUploadedTrip(title: 'Siwa Oasis 3D', status: 'Pending Review'),
    ],
  ),
  MockGuide(
    name: 'Hany Samir',
    email: 'hany@guide.com',
    document: 'Professional License',
    city: 'Luxor',
    status: 'approved',
    phone: '+20 111 654 3210',
    submitted: 'Yesterday, 3:00 PM',
    docFileName: 'hany-license.pdf',
    uploadedTrips: [
      MockUploadedTrip(title: 'Cairo Pyramids Day', status: 'Active'),
    ],
  ),
  MockGuide(
    name: 'Mona Adel',
    email: 'mona@guide.com',
    document: 'Tour Guide ID',
    city: 'Alexandria',
    status: 'approved',
    phone: '+20 122 987 6543',
    submitted: 'Oct 28, 11:45 AM',
    docFileName: 'mona-guide-id.pdf',
    uploadedTrips: [
      MockUploadedTrip(title: 'Alexandria Tour', status: 'Active'),
    ],
  ),
];
