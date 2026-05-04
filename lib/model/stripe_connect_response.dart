class StripeConnectResponse {
  StripeConnectResponse({
      this.success, 
      this.code, 
      this.message, 
      this.body,});

  StripeConnectResponse.fromJson(dynamic json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    body = json['body'];
  }
  bool? success;
  int? code;
  String? message;
  String? body;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['code'] = code;
    map['message'] = message;
    map['body'] = body;
    return map;
  }

}