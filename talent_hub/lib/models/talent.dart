class Talent {
  final String id;
  final String name;
  final String category; // Artist, DJ, Comedian, Band
  final String bio;
  final String avatar;
  final String location;
  final double rating;
  final int reviewCount;
  final List<String> genres;
  final List<String> portfolio; // Images/videos (emojis for now)
  final int yearsOfExperience;
  final bool isVerified;
  final double priceRange; // Starting price
  final List<String> upcomingShows;

  Talent({
    required this.id,
    required this.name,
    required this.category,
    required this.bio,
    required this.avatar,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.genres,
    required this.portfolio,
    required this.yearsOfExperience,
    required this.isVerified,
    required this.priceRange,
    required this.upcomingShows,
  });
}
