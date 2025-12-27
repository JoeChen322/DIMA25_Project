import 'package:flutter/material.dart';
import 'package:lumi_list/pages/profile_page.dart';

import 'pages/login_page.dart';
import 'pages/signup_page.dart';

import 'pages/home_page.dart';
import 'pages/search_page.dart';
//import 'pages/movie_detail.dart';
import 'pages/my_list.dart';

import 'pages/edit_profile_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/splash_page.dart';


final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomePage(),
  '/login': (context) => const LoginPage(), // LOGIN ROUTE
  '/signup': (context) => const SignupPage(),
  '/splash': (context) => const SplashPage(),
  '/forgot_password': (context) => const ForgotPasswordPage(),
  '/profile': (context) => const ProfilePage(),
  '/edit_profile': (context) => const EditProfilePage(),
  '/search': (context) => const SearchPage(),
  //'/detail': (context) => const MovieDetailPage(),
  '/mylist': (context) => const MyListPage(),
};
