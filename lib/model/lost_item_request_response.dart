class LostItemRequestResponse {
  LostItemRequestResponse({
      this.success, 
      this.code, 
      this.message, 
      this.body,});

  LostItemRequestResponse.fromJson(dynamic json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = [];
      json['body'].forEach((v) {
        body?.add(Body.fromJson(v));
      });
    }
  }
  bool? success;
  num? code;
  String? message;
  List<Body>? body;

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

class Body {
  Body({
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.bookingId, 
      this.userId, 
      this.driverId, 
      this.description, 
      this.countryCode, 
      this.phoneNumber, 
      this.userConfirm, 
      this.driverConfirm, 
      this.sendToAdminOrNot, 
      this.paymentStatus, 
      this.dropLatitude, 
      this.dropLongitude, 
      this.dropLocation, 
      this.amount, 
      this.startNavigationStatus, 
      this.booking, 
      this.user,});

  Body.fromJson(dynamic json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    bookingId = json['bookingId'];
    userId = json['userId'];
    driverId = json['driverId'];
    description = json['description'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    userConfirm = json['userConfirm'];
    driverConfirm = json['driverConfirm'];
    sendToAdminOrNot = json['sendToAdminOrNot'];
    paymentStatus = json['paymentStatus'];
    dropLatitude = json['dropLatitude'];
    dropLongitude = json['dropLongitude'];
    dropLocation = json['dropLocation'];
    amount = json['amount'];
    startNavigationStatus = json['startNavigationStatus'];
    booking = json['booking'] != null ? Booking.fromJson(json['booking']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? id;
  String? createdAt;
  String? updatedAt;
  String? bookingId;
  String? userId;
  String? driverId;
  dynamic description;
  String? countryCode;
  String? phoneNumber;
  num? userConfirm;
  num? driverConfirm;
  num? sendToAdminOrNot;
  num? paymentStatus;
  dynamic dropLatitude;
  dynamic dropLongitude;
  dynamic dropLocation;
  num? amount;
  num? startNavigationStatus;
  Booking? booking;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['bookingId'] = bookingId;
    map['userId'] = userId;
    map['driverId'] = driverId;
    map['description'] = description;
    map['countryCode'] = countryCode;
    map['phoneNumber'] = phoneNumber;
    map['userConfirm'] = userConfirm;
    map['driverConfirm'] = driverConfirm;
    map['sendToAdminOrNot'] = sendToAdminOrNot;
    map['paymentStatus'] = paymentStatus;
    map['dropLatitude'] = dropLatitude;
    map['dropLongitude'] = dropLongitude;
    map['dropLocation'] = dropLocation;
    map['amount'] = amount;
    map['startNavigationStatus'] = startNavigationStatus;
    if (booking != null) {
      map['booking'] = booking?.toJson();
    }
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}

class User {
  User({
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.role, 
      this.adminApprovalStatus, 
      this.isNotificationOnOff, 
      this.fullName, 
      this.email, 
      this.countryCode, 
      this.phoneNumber, 
      this.password, 
      this.profilePicture, 
      this.city, 
      this.country, 
      this.socialType, 
      this.socialId, 
      this.customerId, 
      this.status, 
      this.isOtpVerified, 
      this.location, 
      this.latitude, 
      this.longitude, 
      this.isOnline, 
      this.licenceFrontImage, 
      this.licenceBackImage, 
      this.driversLicenseNumber, 
      this.issuedOn, 
      this.licenceType, 
      this.dob, 
      this.nationality, 
      this.expiryDate, 
      this.pictureOfVehicle, 
      this.typeOfVehicleId, 
      this.vehicleRegistrationImage, 
      this.registrationExpiryDate, 
      this.insurancePolicyImage, 
      this.insuranceExpiryDate, 
      this.vehicleNumber, 
      this.resetToken, 
      this.resetTokenExpires, 
      this.deviceToken, 
      this.deviceType, 
      this.socketId, 
      this.vehicleModel, 
      this.vehicleColor, 
      this.petsAllowed, 
      this.sixPlusSeats,});

  User.fromJson(dynamic json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    role = json['role'];
    adminApprovalStatus = json['adminApprovalStatus'];
    isNotificationOnOff = json['isNotificationOnOff'];
    fullName = json['fullName'];
    email = json['email'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    password = json['password'];
    profilePicture = json['profilePicture'];
    city = json['city'];
    country = json['country'];
    socialType = json['socialType'];
    socialId = json['socialId'];
    customerId = json['customerId'];
    status = json['status'];
    isOtpVerified = json['isOtpVerified'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isOnline = json['isOnline'];
    licenceFrontImage = json['licenceFrontImage'];
    licenceBackImage = json['licenceBackImage'];
    driversLicenseNumber = json['driversLicenseNumber'];
    issuedOn = json['issuedOn'];
    licenceType = json['licenceType'];
    dob = json['dob'];
    nationality = json['nationality'];
    expiryDate = json['expiryDate'];
    pictureOfVehicle = json['pictureOfVehicle'];
    typeOfVehicleId = json['typeOfVehicleId'];
    vehicleRegistrationImage = json['vehicleRegistrationImage'];
    registrationExpiryDate = json['registrationExpiryDate'];
    insurancePolicyImage = json['insurancePolicyImage'];
    insuranceExpiryDate = json['insuranceExpiryDate'];
    vehicleNumber = json['vehicleNumber'];
    resetToken = json['resetToken'];
    resetTokenExpires = json['resetTokenExpires'];
    deviceToken = json['deviceToken'];
    deviceType = json['deviceType'];
    socketId = json['socketId'];
    vehicleModel = json['vehicleModel'];
    vehicleColor = json['vehicleColor'];
    petsAllowed = json['petsAllowed'];
    sixPlusSeats = json['sixPlusSeats'];
  }
  String? id;
  String? createdAt;
  String? updatedAt;
  num? role;
  num? adminApprovalStatus;
  num? isNotificationOnOff;
  String? fullName;
  String? email;
  String? countryCode;
  String? phoneNumber;
  String? password;
  String? profilePicture;
  String? city;
  String? country;
  num? socialType;
  dynamic socialId;
  String? customerId;
  num? status;
  num? isOtpVerified;
  dynamic location;
  dynamic latitude;
  dynamic longitude;
  num? isOnline;
  dynamic licenceFrontImage;
  dynamic licenceBackImage;
  dynamic driversLicenseNumber;
  dynamic issuedOn;
  dynamic licenceType;
  dynamic dob;
  dynamic nationality;
  dynamic expiryDate;
  dynamic pictureOfVehicle;
  dynamic typeOfVehicleId;
  dynamic vehicleRegistrationImage;
  dynamic registrationExpiryDate;
  dynamic insurancePolicyImage;
  dynamic insuranceExpiryDate;
  dynamic vehicleNumber;
  dynamic resetToken;
  dynamic resetTokenExpires;
  String? deviceToken;
  String? deviceType;
  String? socketId;
  dynamic vehicleModel;
  dynamic vehicleColor;
  num? petsAllowed;
  num? sixPlusSeats;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['role'] = role;
    map['adminApprovalStatus'] = adminApprovalStatus;
    map['isNotificationOnOff'] = isNotificationOnOff;
    map['fullName'] = fullName;
    map['email'] = email;
    map['countryCode'] = countryCode;
    map['phoneNumber'] = phoneNumber;
    map['password'] = password;
    map['profilePicture'] = profilePicture;
    map['city'] = city;
    map['country'] = country;
    map['socialType'] = socialType;
    map['socialId'] = socialId;
    map['customerId'] = customerId;
    map['status'] = status;
    map['isOtpVerified'] = isOtpVerified;
    map['location'] = location;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['isOnline'] = isOnline;
    map['licenceFrontImage'] = licenceFrontImage;
    map['licenceBackImage'] = licenceBackImage;
    map['driversLicenseNumber'] = driversLicenseNumber;
    map['issuedOn'] = issuedOn;
    map['licenceType'] = licenceType;
    map['dob'] = dob;
    map['nationality'] = nationality;
    map['expiryDate'] = expiryDate;
    map['pictureOfVehicle'] = pictureOfVehicle;
    map['typeOfVehicleId'] = typeOfVehicleId;
    map['vehicleRegistrationImage'] = vehicleRegistrationImage;
    map['registrationExpiryDate'] = registrationExpiryDate;
    map['insurancePolicyImage'] = insurancePolicyImage;
    map['insuranceExpiryDate'] = insuranceExpiryDate;
    map['vehicleNumber'] = vehicleNumber;
    map['resetToken'] = resetToken;
    map['resetTokenExpires'] = resetTokenExpires;
    map['deviceToken'] = deviceToken;
    map['deviceType'] = deviceType;
    map['socketId'] = socketId;
    map['vehicleModel'] = vehicleModel;
    map['vehicleColor'] = vehicleColor;
    map['petsAllowed'] = petsAllowed;
    map['sixPlusSeats'] = sixPlusSeats;
    return map;
  }

}

class Booking {
  Booking({
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
      this.typeOfVehicleId, 
      this.scheduleType, 
      this.bookingDate, 
      this.bookingTime, 
      this.paymentStatus, 
      this.otp, 
      this.otpVerify, 
      this.reason,});

  Booking.fromJson(dynamic json) {
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
    otp = json['otp'];
    otpVerify = json['otpVerify'];
    reason = json['reason'];
  }
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? driverId;
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
  String? typeOfVehicleId;
  num? scheduleType;
  dynamic bookingDate;
  dynamic bookingTime;
  num? paymentStatus;
  String? otp;
  num? otpVerify;
  dynamic reason;

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
    map['otp'] = otp;
    map['otpVerify'] = otpVerify;
    map['reason'] = reason;
    return map;
  }

}