class EmergencyContact {
  final String id;
  final String name;
  final String number;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.number,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
    };
  }
}