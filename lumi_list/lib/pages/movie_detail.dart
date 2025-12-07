import 'package:flutter/material.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text("Movie Detail")),
      body: Center(
        child: Text("Movie details coming soon.\nData: $movie"),
      ),
    );
  }
}
