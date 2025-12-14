class UserProfile {
  final String name;
  final String email;
  final String initials;
  final String badgeText;
  final int totalDonations;
  final int totalRequests;
  final int rewardPoints;
  final String memberSince;
  final int successRate;
  final String responseTime;
  final String language;

  UserProfile({
    required this.name,
    required this.email,
    required this.initials,
    required this.badgeText,
    required this.totalDonations,
    required this.totalRequests,
    required this.rewardPoints,
    required this.memberSince,
    required this.successRate,
    required this.responseTime,
    required this.language,
  });
}

