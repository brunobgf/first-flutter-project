import 'dart:convert';

import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/src/models/item.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  var items = <Item>[];
  HomePageCubit(this.items) : super(HomePageInitial());

  void _saveItems() async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setString("data", jsonEncode(items));
  }

  Future loadItems() async {
    var prefs = await SharedPreferences.getInstance();

    var data = prefs.getString("data");

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((task) => Item.fromJson(task)).toList();
      items = result;
      emit(HomePageLoaded(items));
    }
  }

  void removeItem(int index) {
    final currentState = state;
    if (currentState is HomePageLoaded) {
      items.removeAt(index);
      emit(HomePageLoaded(currentState.todo));
      _saveItems();
    }
  }

  void addItemToList(Item item) {
    final currentState = state;
    if (currentState is HomePageLoaded) {
      currentState.todo.add(item);
      emit(HomePageLoaded(currentState.todo));
    }
    _saveItems();
  }
}
