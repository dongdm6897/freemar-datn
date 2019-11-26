abstract class RootObject {
  DateTime createdAt;
  DateTime updatedAt;

  RootObject({this.createdAt, this.updatedAt});

  factory RootObject.fromJSON(Map<String, dynamic> json) {
    return null;
  }

  RootObject.toJSON();

  static RootObject makeObj() {
    return null;
  }
}
