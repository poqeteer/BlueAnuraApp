class CategoryModel {
  const CategoryModel({this.code, this.name, this.specimenRequired});

  final String code;
  final String name;
  final bool specimenRequired;

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'name': name,
        'specimenRequired': specimenRequired
      };
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(code: json["code"], name: json["name"], specimenRequired: json["specimenRequired"]);
  }

  String toJsonString() {
    return '\{"code":"$code","name":"$name","specimenRequired":$specimenRequired\}';
  }
}

