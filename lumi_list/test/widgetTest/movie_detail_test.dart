import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/movie_detail.dart';

void main() {
  testWidgets('Movie detail Widget Test', (WidgetTester tester) async {
    // set a narrow screen size 
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;

    // mock movie data
    final mockMovie = {
      'Title': 'Inception',
      'Poster': 'https://example.com/poster.jpg',
      'imdbID': 'tt1375666',
    };
   await tester.runAsync(() async {
    
    await tester.pumpWidget(MaterialApp(
      home: MovieDetailPage(movie: mockMovie),
      //sawait Future.delayed(Duration(milliseconds: 100));
    ));
    });

    //verify no overflow errors
    expect(tester.takeException(), isNull); 
    expect(find.textContaining('Later'), findsOneWidget);
    addTearDown(tester.view.resetPhysicalSize);
  });
}