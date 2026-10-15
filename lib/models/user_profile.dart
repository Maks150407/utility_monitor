class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String? photoUrl;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    this.photoUrl,
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? photoUrl,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  static const defaultUser = UserProfile(
    fullName: 'Максим Меленевич',
    email: 'maks@example.com',
    phone: '+380 67 123 45 67',
    photoUrl: null,
  );
}
