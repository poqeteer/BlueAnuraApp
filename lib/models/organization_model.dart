class OrganizationModel {
  const OrganizationModel({this.code, this.name});

  final String code;
  final String name;

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'name': name,
      };
  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(code: json["code"], name: json["name"]);
  }

  String toJsonString() {
    return '\{"code":"$code","name":"$name"\}';
  }
}

