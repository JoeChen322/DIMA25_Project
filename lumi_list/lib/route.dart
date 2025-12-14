import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/search_page.dart';
//import 'pages/movie_detail.dart';
import 'pages/my_list.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomePage(),
  '/search': (context) => const SearchPage(),
  //'/detail': (context) => const MovieDetailPage(),
  '/mylist': (context) => const MyListPage(),
};
