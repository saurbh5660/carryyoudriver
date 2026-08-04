class ApiConstants {
  static const String _baseUrl = "http://15.206.216.86:4005";
  // static const String _baseUrl = "http://192.168.1.81:7766/api";
  static const String socketUrl = "http://15.206.216.86:4005/";
  // static const String socketUrl = "http://192.168.1.81:7766/";
  static const String userImageUrl = "http://15.206.216.86:4005";
  // static const String userImageUrl = "http://192.168.1.81:7766";
  static const String placesKey = "AIzaSyDxxwe76maBPfAuoQxmMeUemXS9O4ssO-w";


  static const String signUp = "$_baseUrl/users/signUp";
  static const String otpVerify = "$_baseUrl/users/otpVerify";
  static const String otpResend = "$_baseUrl/users/resendOtp";
  static const String licenseDetailAdd = "$_baseUrl/users/licenceDetailAdd";
  static const String typeOfVehicleList = "$_baseUrl/users/getTypeOfVechileList";
  static const String login = "$_baseUrl/users/login";
  static const String forgotPassword = "$_baseUrl/users/forgotPassword";
  static const String updateLocation = "$_baseUrl/users/updateUserLocation";
  static const String requestList = "$_baseUrl/users/bookingList";
  static const String bookingAcceptReject = "$_baseUrl/users/bookingAcceptReject";
  static const String bookingDetail = "$_baseUrl/users/bookingDetail";
  static const String driverWallet = "$_baseUrl/users/driverWallet";
  static const String getLostItemRequestDetail = "$_baseUrl/users/getLostItemRequestDetail";
  static const String bookingStatusChange = "$_baseUrl/users/bookingStatusChange";
  static const String startNavigation = "$_baseUrl/users/itemLoastStatusChange";
  static const String isOnlineStatusChange = "$_baseUrl/users/isOnlineStatusChange";
  static const String bookingList = "$_baseUrl/users/bookingList";
  static const String bookingJobHistory = "$_baseUrl/users/bookingJobHistory";
  static const String lostItemRequest = "$_baseUrl/users/getLostItemRequest";
  static const String driverHaveItemConfimByDriver = "$_baseUrl/users/driverHaveItemConfimByDriver";
  static const String getUserDetail = "$_baseUrl/users/getUserDetail";
  static const String updateProfile = "$_baseUrl/users/updateProfile";
  static const String vehicleInformationUpdate = "$_baseUrl/users/vehicleInformationUpdate";
  static const String withdrawAmount = "$_baseUrl/users/withdrawAmount";
  static const String stripeConnect = "$_baseUrl/users/stripeConnect";
  static const String withdrawalHistory = "$_baseUrl/users/withdrawalHistory";
  static const String notificationsList = "$_baseUrl/users/notificationList";
  static const String deleteAccount = "$_baseUrl/users/deleteUser";
  static const String ratingUser = "$_baseUrl/users/ratingUser";
  static const String logout = "$_baseUrl/users/logout";
  static const String sendNotificationToUserWhenDriverIsNearBy = "$_baseUrl/users/sendNotificationToUserWhenDriverIsNearBy";
  static const String callCustomer = "$_baseUrl/users/callCustomer";


}
