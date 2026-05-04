class RequestListResponse {
  RequestListResponse({
      this.success, 
      this.code, 
      this.message, 
      this.body,});

  RequestListResponse.fromJson(dynamic json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = [];
      json['body'].forEach((v) {
        body?.add(RequestBody.fromJson(v));
      });
    }
  }
  bool? success;
  num? code;
  String? message;
  List<RequestBody>? body;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['code'] = code;
    map['message'] = message;
    if (body != null) {
      map['body'] = body?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class RequestBody {
  RequestBody({
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.userId, 
      this.driverId, 
      this.deliveryCode, 
      this.pickUpLocation, 
      this.pickUpLatitude, 
      this.pickUpLongitude, 
      this.destinationLocation, 
      this.destinationLatitude, 
      this.destinationLongitude, 
      this.status, 
      this.amount, 
      this.distance, 
      this.distanceTxt,
      this.typeOfVehicleId,
      this.scheduleType, 
      this.bookingDate, 
      this.bookingTime, 
      this.paymentStatus, 
      this.user,});

  RequestBody.fromJson(dynamic json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['userId'];
    driverId = json['driverId'];
    deliveryCode = json['deliveryCode'];
    pickUpLocation = json['pickUpLocation'];
    pickUpLatitude = json['pickUpLatitude'];
    pickUpLongitude = json['pickUpLongitude'];
    destinationLocation = json['destinationLocation'];
    destinationLatitude = json['destinationLatitude'];
    destinationLongitude = json['destinationLongitude'];
    status = json['status'];
    amount = json['amount'];
    distance = json['distance'];
    typeOfVehicleId = json['typeOfVehicleId'];
    scheduleType = json['scheduleType'];
    bookingDate = json['bookingDate'];
    bookingTime = json['bookingTime'];
    paymentStatus = json['paymentStatus'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  dynamic driverId;
  dynamic deliveryCode;
  String? pickUpLocation;
  String? pickUpLatitude;
  String? pickUpLongitude;
  String? destinationLocation;
  String? destinationLatitude;
  String? destinationLongitude;
  num? status;
  num? amount;
  num? distance;
  String? distanceTxt;
  String? typeOfVehicleId;
  num? scheduleType;
  dynamic bookingDate;
  dynamic bookingTime;
  num? paymentStatus;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['userId'] = userId;
    map['driverId'] = driverId;
    map['deliveryCode'] = deliveryCode;
    map['pickUpLocation'] = pickUpLocation;
    map['pickUpLatitude'] = pickUpLatitude;
    map['pickUpLongitude'] = pickUpLongitude;
    map['destinationLocation'] = destinationLocation;
    map['destinationLatitude'] = destinationLatitude;
    map['destinationLongitude'] = destinationLongitude;
    map['status'] = status;
    map['amount'] = amount;
    map['distance'] = distance;
    map['typeOfVehicleId'] = typeOfVehicleId;
    map['scheduleType'] = scheduleType;
    map['bookingDate'] = bookingDate;
    map['bookingTime'] = bookingTime;
    map['paymentStatus'] = paymentStatus;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}

class User {
  User({
      this.id, 
      this.fullName, 
      this.phoneNumber,
      this.profilePicture,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    profilePicture = json['profilePicture'];
  }
  String? id;
  String? fullName;
  String? phoneNumber;
  String? profilePicture;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['fullName'] = fullName;
    map['phoneNumber'] = phoneNumber;
    map['profilePicture'] = profilePicture;
    return map;
  }

}