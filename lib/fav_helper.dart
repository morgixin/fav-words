import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'favorite.dart';


class FavoriteHelper {
  static const _tableName = "favorite";
  static final FavoriteHelper _instance = FavoriteHelper._internal();

  factory FavoriteHelper() {
    return _instance;
  }

  FavoriteHelper._internal();

  Future<Database> get db async {
    return await initDb();
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "favorite.db");

    return openDatabase(path, version: 1, onCreate: _onCreateDb);
  }

  void _onCreateDb(Database db, int version) {
    db.execute("""
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL);
      );
    """);
  }

  Future<int> insertFavorite(Favorite favorite) async {
    var database = await db;

    return await database.insert(_tableName, favorite.toMap());
  }

  Future<int> deleteFavorite(int id) async {
    var database = await db;

    return await database.delete(_tableName, where: "id=?", whereArgs: [id]);
  }

  getFavorites() async {
    var database = await db;

    return await database.rawQuery("SELECT * FROM $_tableName;");
  }
}