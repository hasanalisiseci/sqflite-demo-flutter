import 'package:flutter/material.dart';
import 'package:sqflite_demo/models/notes.dart';
import 'package:sqflite_demo/utils/dbHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Notes> allNotes = List<Notes>();
  bool aktiflik = false;
  var _controllerTitle = TextEditingController();
  var _controllerDesc = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  int clickedNoteIndex;
  int clickedNoteID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseHelper.allNotes().then((allNotesMapList) {
      for (Map noteInMapList in allNotesMapList) {
        allNotes.add(Notes.fromMap(noteInMapList));
      }
      setState(() {});
    }).catchError((error) => print("Hata:" + error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notlarım"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      autofocus: false,
                      controller: _controllerTitle,
                      decoration: InputDecoration(
                        labelText: "Başlık",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      autofocus: false,
                      controller: _controllerDesc,
                      decoration: InputDecoration(
                        labelText: "Açıklama",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Text("Kaydet"),
                  color: Colors.green,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _addNote(
                          Notes(_controllerTitle.text, _controllerDesc.text));
                    }
                  },
                ),
                RaisedButton(
                  child: Text("Güncelle"),
                  color: Colors.yellow,
                  onPressed: clickedNoteID == null
                      ? null
                      : () {
                          if (_formKey.currentState.validate()) {
                            _uptadeNote(Notes.withID(clickedNoteID,
                                _controllerTitle.text, _controllerDesc.text));
                          }
                        },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: allNotes.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _controllerTitle.text = allNotes[index].title;
                          _controllerDesc.text = allNotes[index].description;
                          clickedNoteIndex = index;
                          clickedNoteID = allNotes[index].id;
                        });
                      },
                      title: Text(allNotes[index].title),
                      subtitle: Text(allNotes[index].description),
                      trailing: GestureDetector(
                        onTap: () {
                          _deleteNote(allNotes[index].id, index);
                        },
                        child: Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Crud İşlemlerinin AraYüze Uygulanması

  void _addNote(Notes note) async {
    var addedNoteID = await _databaseHelper.addNote(note);
    note.id = addedNoteID;

    if (addedNoteID > 0) {
      setState(() {
        allNotes.insert(0, note);
        _controllerTitle.text = "";
        _controllerDesc.text = "";
      });
    }
  }

  void _uptadeNote(Notes note) async {
    var sonuc = await _databaseHelper.updateNote(note);

    setState(() {
      allNotes[clickedNoteIndex] = note;
      _controllerTitle.text = "";
      _controllerDesc.text = "";
      clickedNoteID = null;
    });
  }

  void _deleteNote(int deletedNoteId, int deletedNoteIndex) async {
    var sonuc = await _databaseHelper.deleteNote(deletedNoteId);

    setState(() {
      allNotes.removeAt(deletedNoteIndex);
    });
  }
}
