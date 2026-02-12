import 'package:carry_you_driver/model/booking_detail_response.dart';
import 'package:carry_you_driver/model/common_response.dart';
import 'package:carry_you_driver/model/license_response.dart';
import 'package:carry_you_driver/model/request_list_response.dart';
import 'package:carry_you_driver/model/types_vehicle_response.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import '../common/apputills.dart';
import '../model/booking_list_response.dart';
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

  Future<SignupResponse> loginApi(
      Map<String, dynamic> body
      ) async {
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

  Future<LicenseResponse> licenseAddApi(
    Map<String, dynamic> body,
    String licenceFrontImage,
    String licenceBackImage,
  ) async {
    Utils.showLoading();
    if (licenceFrontImage.isNotEmpty &&
        !(licenceFrontImage.startsWith("http"))) {
      body['licenceFrontImage'] = await getMultipart(path: licenceFrontImage);
    }

    if (licenceBackImage.isNotEmpty && !(licenceBackImage.startsWith("http"))) {
      body['licenceBackImage'] = await getMultipart(path: licenceBackImage);
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

  Future<CommonResponse> updateLocation(
      Map<String, dynamic> body,
      bool showLoader
      ) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.updateLocation,
      requestType: RequestType.post,
      body: body,
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

  Future<RequestListResponse> requestList(
      bool showLoader
      ) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.requestList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if(showLoader){
        Utils.hideLoading();
      }
      return RequestListResponse.fromJson(response);
    } catch (e) {
      if(showLoader){
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
      bool showLoader
      ) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.bookingAcceptReject,
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

  Future<BookingDetailResponse> bookingDetail(
      Map<String, dynamic> body,
      bool showLoader
      ) async {
    if(showLoader){
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
      if(showLoader){
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if(showLoader){
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<BookingDetailResponse> bookingStatusChange(
      Map<String, dynamic> body,
      bool showLoader
      ) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.bookingStatusChange,
      requestType: RequestType.post,
      body: body
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if(showLoader){
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if(showLoader){
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<BookingDetailResponse> isOnlineStatusChange(
      Map<String, dynamic> body,
      bool showLoader
      ) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
        url: ApiConstants.isOnlineStatusChange,
        requestType: RequestType.post,
        body: body
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if(showLoader){
        Utils.hideLoading();
      }
      return BookingDetailResponse.fromJson(response);
    } catch (e) {
      if(showLoader){
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingDetailResponse.fromJson(res?.data);
      }
      return BookingDetailResponse(message: e.toString());
    }
  }

  Future<BookingListResponse> bookingList(bool showLoader) async {
    if(showLoader){
      Utils.showLoading();
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.bookingList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      if(showLoader){
        Utils.hideLoading();
      }
      return BookingListResponse.fromJson(response);
    } catch (e) {
      if(showLoader){
        Utils.hideLoading();
      }
      final res = (e as dynamic).response;
      if (res != null) {
        return BookingListResponse.fromJson(res?.data);
      }
      return BookingListResponse(message: e.toString());
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

  /* Future<LoginResponse> loginApi(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.login,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return LoginResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return LoginResponse.fromJson(res?.data);
      }
      return LoginResponse(message: e.toString());
    }
  }

  Future<CommonResponse> contactUs(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.contactus,
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

  Future<CommonResponse> createTask(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.createTask,
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

  Future<ContentResponse> cms(int type) async {
    Utils.showLoading();
    String urlWithParams = "${ApiConstants.cms}/$type";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return ContentResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return ContentResponse.fromJson(res?.data);
      }
      return ContentResponse(message: e.toString());
    }
  }

  Future<TaskModel> getTask() async {
    String urlWithParams = ApiConstants.getTask;
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return TaskModel.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return TaskModel.fromJson(res?.data);
      }
      return TaskModel(message: e.toString());
    }
  }

  Future<CommonResponse> changePassword(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.changePassword,
      requestType: RequestType.put,
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

  Future<CommonResponse> notificationStatus(Map<String, dynamic> body) async {
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.notificationStatus,
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

  Future<EmployeesResponse> getEmployees(Map<String, dynamic> body) async {
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.getEmployees,
      requestType: RequestType.get,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      return EmployeesResponse.fromJson(response);
    } catch (e) {
      final res = (e as dynamic).response;
      if (res != null) {
        return EmployeesResponse.fromJson(res?.data);
      }
      return EmployeesResponse(message: e.toString());
    }
  }

  Future<EmployeesResponse> getAllEmployees(Map<String, dynamic> body) async {
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.getEmployeesGet,
      requestType: RequestType.get,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      return EmployeesResponse.fromJson(response);
    } catch (e) {
      final res = (e as dynamic).response;
      if (res != null) {
        return EmployeesResponse.fromJson(res?.data);
      }
      return EmployeesResponse(message: e.toString());
    }
  }

  Future<CommonResponse> createRoute(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.createRoute,
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

  Future<GeneratePdfResponse> report(Map<String, dynamic> body) async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.report,
      requestType: RequestType.post,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return GeneratePdfResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return GeneratePdfResponse.fromJson(res?.data);
      }
      return GeneratePdfResponse(message: e.toString());
    }
  }

  Future<HomeResponse> home() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.home,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return HomeResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return HomeResponse.fromJson(res?.data);
      }
      return HomeResponse(message: e.toString());
    }
  }

  Future<EmployeeListResponse> getEmployeeList() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.employeeList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return EmployeeListResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return EmployeeListResponse.fromJson(res?.data);
      }
      return EmployeeListResponse(message: e.toString());
    }
  }

  Future<ProfileResponse> getProfile() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.getProfile,
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

  Future<NotificationResponse> getNotification() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.notificationList,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return NotificationResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return NotificationResponse.fromJson(res?.data);
      }
      return NotificationResponse(message: e.toString());
    }
  }

  Future<StopResponse> getScheduleDetail(String id) async {
    Utils.showLoading();
    String urlWithParams = "${ApiConstants.scheduleDetail}/$id";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return StopResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return StopResponse.fromJson(res?.data);
      }
      return StopResponse(message: e.toString());
    }
  }

  Future<CurrentPastResponse> getCurrentPast(Map<String, dynamic> body) async {
    Utils.showLoading();
    String queryString = Uri(queryParameters: body).query;
    String urlWithParams = "${ApiConstants.currentPast}?$queryString";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return CurrentPastResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return CurrentPastResponse.fromJson(res?.data);
      }
      return CurrentPastResponse(message: e.toString());
    }
  }

  Future<StopDetailResponse> getStopDetail(String id) async {
    Utils.showLoading();
    String urlWithParams = "${ApiConstants.stopDetail}/$id";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return StopDetailResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return StopDetailResponse.fromJson(res?.data);
      }
      return StopDetailResponse(message: e.toString());
    }
  }

  Future<LoginResponse> updateProfile(
    Map<String, dynamic> body,
    String imagePath,
  ) async {
    Utils.showLoading();
    if (imagePath.isNotEmpty && !(imagePath.startsWith("http"))) {
      Logger().d("djhfdjfdsfd");
      body['image'] = await getMultipart(path: imagePath);
    }
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.editProfile,
      requestType: RequestType.put,
      body: body,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return LoginResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return LoginResponse.fromJson(res?.data);
      }
      return LoginResponse(message: e.toString());
    }
  }

  Future<GeneratePdfResponse> generatePdf(String id) async {
    Utils.showLoading();
    String urlWithParams = "${ApiConstants.generatePdf}/$id";
    ApiRequest apiRequest = ApiRequest(
      url: urlWithParams,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return GeneratePdfResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return GeneratePdfResponse.fromJson(res?.data);
      }
      return GeneratePdfResponse(message: e.toString());
    }
  }

  Future<FaqResponse> faq() async {
    Utils.showLoading();
    ApiRequest apiRequest = ApiRequest(
      url: ApiConstants.faq,
      requestType: RequestType.get,
    );
    try {
      var response = await _baseClient.handleRequest(apiRequest);
      Utils.hideLoading();
      return FaqResponse.fromJson(response);
    } catch (e) {
      Utils.hideLoading();
      final res = (e as dynamic).response;
      if (res != null) {
        return FaqResponse.fromJson(res?.data);
      }
      return FaqResponse(message: e.toString());
    }
  }*/

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
}
