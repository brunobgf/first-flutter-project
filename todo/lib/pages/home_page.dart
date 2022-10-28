import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/item.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  var items = <Item>[];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void addItem() {
    setState(() {
      if (newTaskController.text.isEmpty) return;

      items.add(Item(
        title: newTaskController.text,
        done: false,
      ));

      newTaskController.text = "";
      saveItems();
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
      saveItems();
    });
  }

  Future loadItems() async {
    var prefs = await SharedPreferences.getInstance();

    var data = prefs.getString("data");

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((task) => Item.fromJson(task)).toList();
      setState(() {
        items = result;
      });
    }
  }

  saveItems() async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setString("data", jsonEncode(items));
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
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return Dismissible(
            key: Key("${item.title}"),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) => removeItem(index),
            child: CheckboxListTile(
              title: Text("${item.title}"),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  saveItems();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
