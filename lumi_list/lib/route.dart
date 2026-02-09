import 'package:flutter/material.dart';
import 'package:lumi_list/pages/profile_page.dart';

import 'pages/login_page.dart';
import 'pages/signup_page.dart';

import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/me_page.dart';

import 'pages/edit_profile_page.dart';
import 'pages/forgot_password_page.dart';


import 'pages/see_later_page.dart';

import 'pages/auth_gate.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const AuthGate(), 
  '/login': (context) => const LoginPage(),
  '/signup': (context) => const SignupPage(),
  '/forgot_password': (context) => const ForgotPasswordPage(),
  '/profile': (context) => const ProfilePage(),
  '/edit_profile': (context) => const EditProfilePage(),
  '/search': (context) => const SearchPage(),
  '/mylist': (context) => const MyListPage(),
  '/seelater': (context) => const SeeLaterPage(),
};
