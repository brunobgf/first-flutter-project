import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../cubit/home_page_cubit.dart';
import '../models/item.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageCubit _cubit;

  var newTaskController = TextEditingController();

  var items = <Item>[];

  @override
  void initState() {
    super.initState();

    _cubit = HomePageCubit(items);

    _cubit.loadItems();
  }

  _saveItems() async {
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
      body: BlocBuilder<HomePageCubit, HomePageState>(
        bloc: _cubit,
        builder: (context, state) {
          return ListView.builder(
            itemCount: _cubit.items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _cubit.items[index];
              return Dismissible(
                key: Key(
                  "${item.title}",
                ),
                background: Container(
                  color: Colors.red.withOpacity(0.2),
                ),
                onDismissed: (direction) => _cubit.removeItem(index),
                child: CheckboxListTile(
                  title: Text(
                    "${item.title}",
                  ),
                  value: item.done,
                  onChanged: (value) {
                    setState(() {
                      item.done = value;
                      _saveItems();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (newTaskController.text.isEmpty) return;

          _cubit.addItemToList(Item(
            title: newTaskController.text,
            done: false,
          ));
          newTaskController.text = "";
          print("add");
        },
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
