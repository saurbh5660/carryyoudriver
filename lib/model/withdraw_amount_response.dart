class WithdrawAmountResponse {
  WithdrawAmountResponse({
      this.success, 
      this.code, 
      this.message, 
      this.body,});

  WithdrawAmountResponse.fromJson(dynamic json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
  }
  bool? success;
  int? code;
  String? message;
  Body? body;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['code'] = code;
    map['message'] = message;
    if (body != null) {
      map['body'] = body?.toJson();
    }
    return map;
  }

}

class Body {
  Body({
      this.stripeAccountConnected,
      this.id,
  });

  Body.fromJson(dynamic json) {
    stripeAccountConnected = json['stripeAccountConnected'];
    id = json['id'];
  }
  bool? stripeAccountConnected;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['stripeAccountConnected'] = stripeAccountConnected;
    map['id'] = id;
    return map;
  }

}