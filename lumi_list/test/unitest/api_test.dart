import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/models/cast.dart'; // 假设你的模型路径

void main() {
  group('TMDb Json ', () {
    test('CastMember Missing', () {
      final Map<String, dynamic> mockJson = {
        'name': 'Tom Hardy',
        'character': 'Bane',
        'profile_path': null 
      };

      final member = CastMember.fromJson(mockJson);

      expect(member.name, 'Tom Hardy');
      expect(member.character, 'Bane');
      expect(member.profilePath, isNull); 
    });
    test('Omdb Json', () {
  final Map<String, dynamic> mockData = {
    "Title": "Inception",
    "Director": "Christopher Nolan",
    "Plot": "A thief who steals secrets...",
    "Year": "2010"
  };

  final String director = mockData['Director'] ?? "No Info";
  final String year = mockData['Year'] ?? "N/A";

  expect(director, "Christopher Nolan");
  expect(year, "2010");
});
  });
}