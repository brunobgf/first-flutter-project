part of 'home_page_cubit.dart';

class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageLoaded extends HomePageState {
  final List<Item> todo;
  HomePageLoaded(this.todo);
}
