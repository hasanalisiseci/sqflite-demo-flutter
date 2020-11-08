import 'package:flutter/material.dart';
import 'package:sqflite_demo/models/notes.dart';
import 'package:sqflite_demo/utils/dbHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Notes> allNotes = new List<Notes>();
  bool aktiflik = false;
  var _controllerTitle = TextEditingController();
  var _controllerDesc = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  int clickedNoteID;

  void getNotes() async {
    var notesFuture = _databaseHelper.getAllNotes();
    await notesFuture.then((data) {
      setState(() {
        this.allNotes = data;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Notlarım"),
        ),
        body: Container(
            child: Column(children: <Widget>[
          Form(
              key: _formKey,
              child: Column(children: <Widget>[
                buildForm(_controllerTitle, "Başlık"),
                buildForm(_controllerDesc, "Açıklama")
              ])),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildButton("Kaydet", Colors.green, saveObject),
                buildButton("Güncelle", Colors.yellow, updateObject)
              ]),
          Expanded(
              child: ListView.builder(
                  itemCount: allNotes.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: ListTile(
                            onTap: () {
                              setState(() {
                                _controllerTitle.text = allNotes[index].title;
                                _controllerDesc.text =
                                    allNotes[index].description;
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
                            )));
                  }))
        ])));
  }

  Widget buildForm(TextEditingController txtController, String str) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
            autofocus: false,
            controller: txtController,
            decoration:
                InputDecoration(labelText: str, border: OutlineInputBorder())));
  }

  Widget buildButton(String str, Color buttonColor, Function eventFunc) {
    return RaisedButton(
      child: Text(str),
      color: buttonColor,
      onPressed: () {
        eventFunc();
      },
    );
  }

  void updateObject() {
    if (clickedNoteID != null) {
      if (_formKey.currentState.validate()) {
        _uptadeNote(Notes.withID(
            clickedNoteID, _controllerTitle.text, _controllerDesc.text));
      }
    } else {
      alert();
    }
  }

  void saveObject() {
    if (_formKey.currentState.validate()) {
      _addNote(Notes(_controllerTitle.text, _controllerDesc.text));
    }
  }

  void alert() {
    AlertDialog alert = AlertDialog(
      title: Text("SEÇİLİ NOT YOK!"),
      content: Text("Lütfen bir not seçerek güncelleme işlemi yapınız!"),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Crud İşlemlerinin AraYüze Uygulanması

  void _addNote(Notes note) async {
    await _databaseHelper.insert(note);

    setState(() {
      getNotes();
      _controllerTitle.text = "";
      _controllerDesc.text = "";
    });
  }

  void _uptadeNote(Notes note) async {
    await _databaseHelper.update(note);

    setState(() {
      getNotes();
      _controllerTitle.text = "";
      _controllerDesc.text = "";
      clickedNoteID = null;
    });
  }

  void _deleteNote(int deletedNoteId, int deletedNoteIndex) async {
    await _databaseHelper.delete(deletedNoteId);

    setState(() {
      getNotes();
    });
  }
}
