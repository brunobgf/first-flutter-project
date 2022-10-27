import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(
        title: "Titulo com um sentido",
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();
  // A lista sempre
  var items = <Item>[];

  @override
  void initState() {
    print("init state");
    // TODO: implement initState
    super.initState();
    load();
  }

  void add() {
    setState(() {
      if (newTaskController.text.isEmpty) return;

      items.add(Item(
        title: newTaskController.text,
        done: false,
      ));
      newTaskController.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      items.removeAt(index);
      save();
    });
  }

  // Async function
  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    // Tratamento do data
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((task) => Item.fromJson(task)).toList();
      setState(() {
        items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
              labelText: widget.title,
              labelStyle: TextStyle(color: Colors.white)),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          // ! - Garante que vem String
          // .toString() similar ao Java
          // ou essa versão utilizando interpolação
          return Dismissible(
            key: Key("${item.title}"),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) => remove(index),
            child: CheckboxListTile(
              title: Text("${item.title}"),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Só passa a função add, não estpa chamando
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
