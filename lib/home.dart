import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _readData().then((data) => {_todoList = json.decode(data)});
  }

  List _todoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    debugPrint("saving data");
    String data = json.encode(_todoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.deepPurple),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: Colors.deepPurple))),
                  ),
                ),
                ElevatedButton(
                  child: Text("ADD"),
                  onPressed: () => _addTodo(),
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: buildItem,
            padding: EdgeInsets.only(top: 10.0),
            itemCount: _todoList.length,
          ))
        ],
      ),
    );
  }

  Widget buildItem(context, index) => Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        child: CheckboxListTile(
          activeColor: Colors.deepPurple,
          title: Text(_todoList[index]["title"]),
          value: _todoList[index]["ok"],
          secondary: CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(
              _todoList[index]["ok"] ? Icons.check : Icons.error,
              color: Colors.white,
            ),
          ),
          onChanged: (c) {
            setState(() {
              _todoList[index]["ok"] = c;
              _saveData();
            });
          },
        ),
        background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment(-0.9, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            )),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_todoList[index]);
            _lastRemovedPos = index;
            _todoList.removeAt(index);

            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa ${_lastRemoved["title"]} removida"),
              action: SnackBarAction(
                label: "Desfaazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                },
              ),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        },
      );
}
