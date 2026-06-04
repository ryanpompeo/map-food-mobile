class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const startup = '/startup';

  static const login = '/auth/login';
  static const register = '/auth/register';

  static const guestHome = '/guest';
  static const guestSearch = '/guest/search';
  static const guestProfile = '/guest/profile';

  static const consumerHome = '/consumer';
  static const consumerFavorites = '/consumer/favorites';
  static const consumerOrders = '/consumer/orders';
  static const consumerReviews = '/consumer/reviews';

  static const merchantDashboard = '/merchant';
  static const merchantSetup = '/merchant/setup';
  static const merchantStore = '/merchant/store';
  static const merchantReviews = '/merchant/reviews';
  static const merchantStatus = '/merchant/status';
}
