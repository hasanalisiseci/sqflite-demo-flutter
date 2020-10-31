import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/models/notes.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String _notesTable = "notes";
  String _columnID = "id";
  String _columnTitle = "title";
  String _columnDescription = "description";

  //Kontroller sonrası değerler aktaracağımız için "factory" anahtar kelimesini kullandık.
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }
  //Singleton sınıfların dışarıdan nesnesini oluşmasını istemediğimiz
  //için Constructor’ları private olarak belirtilmelidir.
  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  _initializeDatabase() async {
    String dbPath = join(await getDatabasesPath(), "notes.db");
    var notesDb = openDatabase(dbPath, version: 1, onCreate: _createDb);
    return notesDb;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $_notesTable ($_columnID INTEGER PRIMARY KEY AUTOINCREMENT, $_columnTitle TEXT, $_columnDescription TEXT )");
  }

  //Crud Methods
  Future<List<Map<String, dynamic>>> allNotes() async {
    var db = await _getDatabase();
    var result = await db.query(_notesTable, orderBy: "$_columnID DESC");
    return result;
  }

  Future<int> addNote(Notes note) async {
    //değişken oluşturup, var olan database'imizi çağırıp oluşturduğumuz değişkene atıyoruz
    var db = await _getDatabase();
    //daha sonrasında db üzerinden insert methodunu kullanarak ekleme işlemini yapıyoruz.
    //insert methodu bizden gelen verinin ekleneceği tabloyu, eklenecek veriyi(burda map'e çeviriyoruz)
    //ve nullColumnHack değeri istiyor, biz columnID değerini atıyoruz.
    var result = await db.insert(_notesTable, note.toMap(),
        nullColumnHack: "$_columnID");
    return result;
  }

  //Not güncelleme işleminde de ilk olarak not ekleme işlemindeki gibi database'i alıyoruz.
  Future<int> updateNote(Notes note) async {
    var db = await _getDatabase();
    //Daha sonra update metoduyla gelen notu güncelleme işlemine gönderiyoruz burada where ve whereArgs
    //parametreleri isteniyoruz bizden. Where için columnId değerini
    var result = await db.update(_notesTable, note.toMap(),
        where: "$_columnID = ?", whereArgs: [note.id]);
    return result;
  }

  //Not silme işlemimiz de ise parametre olarak sadece id göndermemiz işimizi görecektir.
  Future<int> deleteNote(int id) async {
    //Not silme işleminde de ilk olarak not ekleme işlemindeki gibi database'i alıyoruz.
    var db = await _getDatabase();
    //Daha sonra database'den ilgili id'deki değerleri delete etmesini istiyoruz.
    var result =
        await db.delete(_notesTable, where: "$_columnID", whereArgs: [id]);
    return result;
  }
}
