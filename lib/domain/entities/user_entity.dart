/// Domain entity representing a user/service-provider (pure Dart, no JSON logic)
class UserEntity {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final String? imageUrl;
  final String? businessName;
  final String? city;
  final String? state;
  final String language;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.imageUrl,
    this.businessName,
    this.city,
    this.state,
    this.language = 'en',
    this.isActive = true,
  });
}
