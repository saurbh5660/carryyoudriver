class WithdrawalHistoryResponse {
  WithdrawalHistoryResponse({
      this.success, 
      this.code, 
      this.message, 
      this.body,});

  WithdrawalHistoryResponse.fromJson(dynamic json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = [];
      json['body'].forEach((v) {
        body?.add(WithdrawalBody.fromJson(v));
      });
    }
  }
  bool? success;
  int? code;
  String? message;
  List<WithdrawalBody>? body;

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

class WithdrawalBody {
  WithdrawalBody({
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.userId, 
      this.amount, 
      this.paymentStatus,});

  WithdrawalBody.fromJson(dynamic json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['userId'];
    amount = json['amount'];
    paymentStatus = json['paymentStatus'];
  }
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  int? amount;
  int? paymentStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['userId'] = userId;
    map['amount'] = amount;
    map['paymentStatus'] = paymentStatus;
    return map;
  }

}