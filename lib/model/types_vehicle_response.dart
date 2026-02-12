class TypesVehicleResponse {
  TypesVehicleResponse({
      this.success, 
      this.code, 
      this.message, 
      this.body,});

  TypesVehicleResponse.fromJson(dynamic json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = [];
      json['body'].forEach((v) {
        body?.add(VehicleTypes.fromJson(v));
      });
    }
  }
  bool? success;
  int? code;
  String? message;
  List<VehicleTypes>? body;

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

class VehicleTypes {
  VehicleTypes({
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.name, 
      this.image, 
      this.type,
      this.price,});

  VehicleTypes.fromJson(dynamic json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'];
    image = json['image'];
    price = json['price'];
    type = json['type'];
  }
  String? id;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? image;
  int? type;
  num? price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['name'] = name;
    map['image'] = image;
    map['type'] = type;
    map['price'] = price;
    return map;
  }

}