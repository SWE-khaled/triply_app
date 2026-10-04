class EarningActivity {
  final String id;
  final String title;
  final double amountEgp;

  const EarningActivity({
    required this.id,
    required this.title,
    required this.amountEgp,
  });

  factory EarningActivity.fromJson(Map<String, dynamic> json) {
    return EarningActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      amountEgp: (json['amountEgp'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'amountEgp': amountEgp};
  }
}

class EarningsSummary {
  final double availableBalance;
  final String month;
  final List<EarningActivity> activities;

  const EarningsSummary({
    required this.availableBalance,
    required this.month,
    required this.activities,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      availableBalance: (json['availableBalance'] as num).toDouble(),
      month: json['month'] as String,
      activities: (json['activities'] as List)
          .map((e) => EarningActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
