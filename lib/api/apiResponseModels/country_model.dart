class Country {
  Country({
    this.id,
    this.code,
    this.name,
    this.shortCode,
  });

  int ?id;
  String? code;
  String? name;
  String? shortCode;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    shortCode: json["short_code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
    "short_code": shortCode,
  };
}