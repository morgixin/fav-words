class Favorite {
  late String name;
  int? id;

  Favorite (this.name);

  Favorite.fromMap(Map map) {
    id = map["id"];
    name = map["name"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name
    };
    return map;
  }

  String getName() {
    return name;
  }

  @override
  String toString() {
    return 'Favorite{id: $id, name: $name}';
  }
}