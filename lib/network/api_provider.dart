import 'package:carry_you_driver/model/booking_detail_response.dart';
import 'package:carry_you_driver/model/booking_history_response.dart';
import 'package:carry_you_driver/model/common_response.dart';
import 'package:carry_you_driver/model/license_response.dart';
import 'package:carry_you_driver/model/lost_item_request_detail_response.dart';
import 'package:carry_you_driver/model/lost_item_request_response.dart';
import 'package:carry_you_driver/model/notification_list_response.dart';
import 'package:carry_you_driver/model/request_list_response.dart';
import 'package:carry_you_driver/model/stripe_connect_response.dart';
import 'package:carry_you_driver/model/types_vehicle_response.dart';
import 'package:carry_you_driver/model/wallet_response.dart';
import 'package:carry_you_driver/model/withdraw_amount_response.dart';
import 'package:carry_you_driver/model/withdrawal_history_response.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import '../common/apputills.dart';
import '../model/booking_list_response.dart';
import '../model/profile_response.dart';
import '../model/signup_response.dart';
import 'api_constants.dart';
import 'base_client.dart';
import 'package:dio/dio.dart' as dio;

class ApiProvider {
  static late BaseClient _baseClient;
  final logger = Logger();

  ApiProvider() {
    _baseClient = BaseClient();
    _baseClient.init();
  }

  Future<SignupResponse> loginApi(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.login,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return SignupResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return SignupResponse.fromJson(res?.data);
      }
      return SignupResponse(message: e.toString());
    }
  }

  Future<SignupResponse> signUpApi(
    Map<String, dynamic> body,
    String image,
  ) async {
    Utils.showLoading();
    if (image.isNotEmpty && !(image.startsWith("http"))) {
      body['profilePicture'] = await getMultipart(path: image);
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.signUp,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return SignupResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return SignupResponse.fromJson(res?.data);
      }
      return SignupResponse(message: e.toString());
    }
  }

  Future<SignupResponse> otpVerify(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.otpVerify,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return SignupResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return SignupResponse.fromJson(res?.data);
      }
      return SignupResponse(message: e.toString());
    }
  }

  Future<SignupResponse> otpResend(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.otpResend,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return SignupResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return SignupResponse.fromJson(res?.data);
      }
      return SignupResponse(message: e.toString());
    }
  }

  Future<CommonResponse> forgotPassword(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.forgotPassword,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }
  Future<LicenseResponse> licenseAddApi(
    Map<String, dynamic> body,
    String licenceFrontImage,
    String licenceBackImage,
  ) async {
    Utils.showLoading();

    if (licenceFrontImage.isNotEmpty) {
      if (licenceFrontImage.startsWith("http") ||
          licenceFrontImage.startsWith("/images")) {
        String url = licenceFrontImage.startsWith("http")
            ? licenceFrontImage
            : "${ApiConstants.userImageUrl}$licenceFrontImage";
        body['licenceFrontImage'] = await getMultipartFromUrl(url: url);
      } else {
        body['licenceFrontImage'] = await getMultipart(path: licenceFrontImage);
      }
    }

    if (licenceBackImage.isNotEmpty) {
      if (licenceBackImage.startsWith("http") ||
          licenceBackImage.startsWith("/images")) {
        String url = licenceBackImage.startsWith("http")
            ? licenceBackImage
            : "${ApiConstants.userImageUrl}$licenceBackImage";
        body['licenceBackImage'] = await getMultipartFromUrl(url: url);
      } else {
        body['licenceBackImage'] = await getMultipart(path: licenceBackImage);
      }
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.licenseDetailAdd,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return LicenseResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return LicenseResponse.fromJson(res?.data);
      }
      return LicenseResponse(message: e.toString());
    }
  }

  Future<TypesVehicleResponse> typeVehicle() async {
    // Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.typeOfVehicleList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      // Utils.hideLoading();
      return TypesVehicleResponse.fromJson(response);
    } catch (e) {
      // Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return TypesVehicleResponse.fromJson(res?.data);
      }
      return TypesVehicleResponse(message: e.toString());
    }
  }

  Future<LicenseResponse> vehicleAddApi(
    Map<String, dynamic> body,
    String pictureOfVehicle,
    String vehicleRegistrationImage,
    String insurancePolicyImage,
  ) async {
    Utils.showLoading();
    if (pictureOfVehicle.isNotEmpty && !(pictureOfVehicle.startsWith("http"))) {
      body['pictureOfVehicle'] = await getMultipart(path: pictureOfVehicle);
    }

    if (vehicleRegistrationImage.isNotEmpty &&
        !(vehicleRegistrationImage.startsWith("http"))) {
      body['vehicleRegistrationImage'] = await getMultipart(
        path: vehicleRegistrationImage,
      );
    }

    if (insurancePolicyImage.isNotEmpty &&
        !(insurancePolicyImage.startsWith("http"))) {
      body['insurancePolicyImage'] = await getMultipart(
        path: insurancePolicyImage,
      );
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.licenseDetailAdd,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return LicenseResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return LicenseResponse.fromJson(res?.data);
      }
      return LicenseResponse(message: e.toString());
    }
  }

  Future<LicenseResponse> vehicleInformationUpdate(
    Map<String, dynamic> body,
    String pictureOfVehicle,
    String vehicleRegistrationImage,
    String insurancePolicyImage,
  ) async {
    Utils.showLoading();
    if (pictureOfVehicle.isNotEmpty) {
      if (pictureOfVehicle.startsWith("http") ||
          pictureOfVehicle.startsWith("/images")) {
        String url = pictureOfVehicle.startsWith("http")
            ? pictureOfVehicle
            : "${ApiConstants.userImageUrl}$pictureOfVehicle";
        body['pictureOfVehicle'] = await getMultipartFromUrl(url: url);
      } else {
        body['pictureOfVehicle'] = await getMultipart(path: pictureOfVehicle);
      }
    }

    if (vehicleRegistrationImage.isNotEmpty) {
      if (vehicleRegistrationImage.startsWith("http") ||
          vehicleRegistrationImage.startsWith("/images")) {
        String url = vehicleRegistrationImage.startsWith("http")
            ? vehicleRegistrationImage
            : "${ApiConstants.userImageUrl}$vehicleRegistrationImage";
        body['vehicleRegistrationImage'] =
            await getMultipartFromUrl(url: url);
      } else {
        body['vehicleRegistrationImage'] =
            await getMultipart(path: vehicleRegistrationImage);
      }
    }

    if (insurancePolicyImage.isNotEmpty) {
      if (insurancePolicyImage.startsWith("http") ||
          insurancePolicyImage.startsWith("/images")) {
        String url = insurancePolicyImage.startsWith("http")
            ? insurancePolicyImage
            : "${ApiConstants.userImageUrl}$insurancePolicyImage";
        body['insurancePolicyImage'] = await getMultipartFromUrl(url: url);
      } else {
        body['insurancePolicyImage'] =
            await getMultipart(path: insurancePolicyImage);
      }
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.vehicleInformationUpdate,
      requestType: RequestType.put,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return LicenseResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return LicenseResponse.fromJson(res?.data);
      }
      return LicenseResponse(message: e.toString());
    }
  }

  Future<CommonResponse> updateLocation(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.updateLocation,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return CommonResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  Future<RequestListResponse> requestList(bool showLoader) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.requestList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return RequestListResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return RequestListResponse.fromJson(res?.data);
      }
      return RequestListResponse(message: e.toString());
    }
  }

  Future<CommonResponse> bookingAcceptReject(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.bookingAcceptReject,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return CommonResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  Future<BookingDetailResponse> bookingDetail(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    String queryString = Uri(queryParameters: body).query;
    String urlWithParams = "${ApiConstants.bookingDetail}?$queryString";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<WalletResponse> getWalletDetail() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.driverWallet,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return WalletResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return WalletResponse.fromJson(res?.data);
      }
      return WalletResponse(message: e.toString());
    }
  }

  Future<LostItemRequestDetailResponse> lostItemRequestDetail(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    String queryString = Uri(queryParameters: body).query;
    String urlWithParams =
        "${ApiConstants.getLostItemRequestDetail}?$queryString";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return LostItemRequestDetailResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return LostItemRequestDetailResponse.fromJson(res?.data);
      }
      return LostItemRequestDetailResponse(message: e.toString());
    }
  }

  Future<BookingDetailResponse> bookingStatusChange(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.bookingStatusChange,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<LostItemRequestDetailResponse> startNavigation(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.startNavigation,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return LostItemRequestDetailResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return LostItemRequestDetailResponse.fromJson(res?.data);
      }
      return LostItemRequestDetailResponse(message: e.toString());
    }
  }

  Future<BookingDetailResponse> isOnlineStatusChange(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.isOnlineStatusChange,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<WithdrawAmountResponse> withdrawAmount(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.withdrawAmount,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return WithdrawAmountResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return WithdrawAmountResponse.fromJson(res?.data);
      }
      return WithdrawAmountResponse(message: e.toString());
    }
  }

  Future<StripeConnectResponse> stripeConnect() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.stripeConnect,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return StripeConnectResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return StripeConnectResponse.fromJson(res?.data);
      }
      return StripeConnectResponse(message: e.toString());
    }
  }

  Future<WithdrawalHistoryResponse> withdrawalHistory() async {
    // Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.withdrawalHistory,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      // Utils.hideLoading();
      return WithdrawalHistoryResponse.fromJson(response);
    } catch (e) {
      // Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return WithdrawalHistoryResponse.fromJson(res?.data);
      }
      return WithdrawalHistoryResponse(message: e.toString());
    }
  }

  Future<NotificationListResponse> getNotificationList() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.notificationsList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return NotificationListResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return NotificationListResponse.fromJson(res?.data);
      }
      return NotificationListResponse(message: e.toString());
    }
  }

  Future<BookingListResponse> bookingList(bool showLoader) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.bookingList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return BookingListResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingListResponse.fromJson(res?.data);
      }
      return BookingListResponse(message: e.toString());
    }
  }

  Future<BookingHistoryResponse> bookingJobHistory(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    String queryString = Uri(queryParameters: body).query;
    String urlWithParams = "${ApiConstants.bookingJobHistory}?$queryString";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return BookingHistoryResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingHistoryResponse.fromJson(res?.data);
      }
      return BookingHistoryResponse(message: e.toString());
    }
  }

  Future<LostItemRequestResponse> lostItemRequest(bool showLoader) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.lostItemRequest,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return LostItemRequestResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return LostItemRequestResponse.fromJson(res?.data);
      }
      return LostItemRequestResponse(message: e.toString());
    }
  }

  Future<SignupResponse> updateProfile(
    Map<String, dynamic> body,
    String image,
  ) async {
    Utils.showLoading();
    if (image.isNotEmpty && !(image.startsWith("http"))) {
      body['profilePicture'] = await getMultipart(path: image);
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.updateProfile,
      requestType: RequestType.put,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return SignupResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return SignupResponse.fromJson(res?.data);
      }
      return SignupResponse(message: e.toString());
    }
  }

  Future<ProfileResponse> getProfile() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.getUserDetail,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return ProfileResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return ProfileResponse.fromJson(res?.data);
      }
      return ProfileResponse(message: e.toString());
    }
  }

  Future<BookingDetailResponse> confirmByDriver(
    Map<String, dynamic> body,
    bool showLoader,
  ) async {
    if (showLoader) {
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.driverHaveItemConfimByDriver,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if (showLoader) {
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if (showLoader) {
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<CommonResponse> logout() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.logout,
      requestType: RequestType.post,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  Future<CommonResponse> deleteAccount() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.deleteAccount,
      requestType: RequestType.post,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  Future<CommonResponse> addRating(
      Map<String, dynamic> body,
      bool showLoader
      ) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
        url: ApiConstants.ratingUser,
        requestType: RequestType.post,
        body: body
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if(showLoader){
        Utils.hideLoading();
      }
      return CommonResponse.fromJson(response);
    } catch (e) {
      if(showLoader){
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  Future<CommonResponse> sendNotificationToUserWhenDriverIsNearBy(Map<String, dynamic> body) async {
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.sendNotificationToUserWhenDriverIsNearBy,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      return CommonResponse.fromJson(response);
    } catch (e) {
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  Future<CommonResponse> callCustomer(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.callCustomer,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(message: e.toString());
    }
  }

  static Future<dio.MultipartFile> getMultipartFromUrl(
      {required String url}) async {
    dio.Dio dioClient = dio.Dio();
    String fileName = url.split('/').last;
    final tempDir = await getTemporaryDirectory();
    final tempPath = "${tempDir.path}/$fileName";
    await dioClient.download(url, tempPath);
    return await getMultipart(path: tempPath);
  }

  static Future<dio.MultipartFile> getMultipart({required String path}) async {
    String fileName = path.split('/').last;
    String? mimeType = mime(fileName);
    String? mimee = mimeType?.split('/')[0];
    String? type = mimeType?.split('/')[1];
    return await dio.MultipartFile.fromFile(
      path,
      filename: fileName,
      contentType: MediaType(mimee ?? 'image', type ?? 'jpeg'),
    );
  }

  Future<CommonResponse> submitLegalAcceptance(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.legalAcceptanceAdd,
      requestType: RequestType.postRaw,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(success: false, message: e.toString());
    }
  }

  Future<CommonResponse> getCmsContent(String type) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: "${ApiConstants.getCmsContent}?type=$type",
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(success: false, message: e.toString());
    }
  }

  Future<CommonResponse> getDriverTermsPdf() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.getDriverTermsPdf,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(success: false, message: e.toString());
    }
  }

  Future<CommonResponse> getPrivacyPolicyPdf() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.getPrivacyPolicyPdf,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(success: false, message: e.toString());
    }
  }

  Future<CommonResponse> sendDriverTermsEmail() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.sendDriverTermsEmail,
      requestType: RequestType.post,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(success: false, message: e.toString());
    }
  }

  Future<CommonResponse> sendPrivacyPolicyEmail() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.sendPrivacyPolicyEmail,
      requestType: RequestType.post,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CommonResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CommonResponse.fromJson(res?.data);
      }
      return CommonResponse(success: false, message: e.toString());
    }
  }
}
