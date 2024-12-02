import 'package:dimo/data/memo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'memo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            content TEXT,
            pin INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertMemo(Memo memo) async {
    Database db = await database;
    return await db.insert('memos', memo.toMap());
  }

  Future<List<Memo>> readMemos() async {
    Database db = await database;

    List<Map<String, dynamic>> maps = await db.query('memos');

    return List.generate(maps.length, (index) {
      return Memo(
          id: maps[index]['id'],
          name: maps[index]['name'],
          content: maps[index]['content'],
          pin: maps[index]['pin']);
    });
  }

  Future<List<Memo>> readPins() async {
    Database db = await database;

    List<Map<String, dynamic>> maps = await db.query('memos');
    List<Memo> memos = [];
    for (int i = 0; i < maps.length; i++) {
      if (maps[i]['pin'] == 1)
        memos.add(Memo(
            id: maps[i]['id'],
            name: maps[i]['name'],
            content: maps[i]['content'],
            pin: maps[i]['pin']));
    }
    return memos;
  }

  Future<List<Memo>> readMemo(String name) async {
    Database db = await database;

    List<Map<String, dynamic>> maps =
        await db.query('memos', where: 'name = ?', whereArgs: [name]);

    return List.generate(maps.length, (index) {
      return Memo(
          id: maps[index]['id'],
          name: maps[index]['name'],
          content: maps[index]['content'],
          pin: maps[index]['pin']);
    });
  }

//여기부분 추가했는데 로직 확인해야함
  Future<List<Memo>> readSimilarMemo(String str) async {
    Database db = await database;

    List<Map<String, dynamic>> maps =
        await db.rawQuery('select * from memos where name like "%$str%"');

    return List.generate(maps.length, (index) {
      return Memo(
          id: maps[index]['id'],
          name: maps[index]['name'],
          content: maps[index]['content'],
          pin: maps[index]['pin']);
    });
  }
//여기까지

  Future<void> updateMemo(Memo memo) async {
    Database db = await database;
    db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );

    print(await db.query('memos'));
  }

  Future<void> updateOnlyPin(name, pin) async {
    Database db = await database;

    List<Map<String, dynamic>> oldmaps =
        await db.query('memos', where: 'name = ?', whereArgs: [name]);

    Memo memo = Memo(
        id: oldmaps[0]['id'],
        name: oldmaps[0]['name'],
        content: oldmaps[0]['content'],
        pin: pin ? 1 : 0); //인자로 받은 pin값은 bool 타입이기때문에 정수형으로 변환

    db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );

    print(await db.query('memos'));
  }

  Future<void> deleteAllMemo() async {
    Database db = await database;
    db.delete(
      'memos',
    );
    print("deleteAll 실행됨");
  }

  Future<void> deleteOneMemo(String name) async {
    Database db = await database;
    db.delete(
      'memos',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<bool> isthereMemo(String name) async {
    Database db = await database;

    try {
      List<Map<String, dynamic>> map =
          await db.query('memos', where: 'name = ?', whereArgs: [name]);
      print(map[0]['name']);
    } catch (E) {
      return false; // print수행할때 데이터베이스에 데이터 없어서 에러 나면 false 리턴
    }

    return true; // 에러 안 났다는 건 데이터 있었다는 소리니까 true 리턴
  }

  Future<bool> haveMemos() async {
    Database db = await database;

    try {
      List<Map<String, dynamic>> map = await db.query('memos');
      print(map[0]['name']);
    } catch (E) {
      return false; // print수행할때 데이터베이스에 데이터 없어서 에러 나면 false 리턴
    }
    return true;
  }

  Future<int> dbSize() async {
    Database db = await database;

    int size = 0;
    try {
      List<Map<String, dynamic>> map = await db.query('memos');
      print(map[0]['name']);
      size = map.length;
    } catch (E) {
      return 0; // print수행할때 데이터베이스에 데이터 없어서 에러 나면 false 리턴
    }
    return size;
  }
}
