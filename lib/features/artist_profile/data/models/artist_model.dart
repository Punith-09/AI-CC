class ArtistModel {
  final String name;
  final String location;
  final String profileImage;
  final String coverImage;
  final List<String> roles;

  final int projects;
  final String followers;
  final double rating;
  final int awards;

  final String experience;
  final String languages;

  const ArtistModel({
    required this.name,
    required this.location,
    required this.profileImage,
    required this.coverImage,
    required this.roles,
    required this.projects,
    required this.followers,
    required this.rating,
    required this.awards,
    required this.experience,
    required this.languages,
  });
}
