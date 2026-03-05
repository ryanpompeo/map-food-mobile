import 'package:map_food/models/usuario.dart';

class UserState {
  static AppUser currentUser = AppUser(role: UserRole.guest);

  static void loginUser() {
    currentUser = AppUser(id: "123", role: UserRole.user);
  }

  static void loginVendor() {
    currentUser = AppUser(id: "999", role: UserRole.vendor);
  }

  static void logout() {
    currentUser = AppUser(role: UserRole.guest);
  }
}
