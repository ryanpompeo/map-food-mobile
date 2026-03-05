enum UserRole { guest, user, vendor }

class AppUser {
  final String? id;
  final UserRole role;

  AppUser({this.id, required this.role});
}
