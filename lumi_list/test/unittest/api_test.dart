import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/models/cast.dart';

void main() {
  group('Model / JSON unit tests', () {
    test('CastMember.fromJson handles null profile_path', () {
      final Map<String, dynamic> mockJson = {
        'name': 'Tom Hardy',
        'character': 'Bane',
        'profile_path': null,
      };

      final member = CastMember.fromJson(mockJson);

      expect(member.name, 'Tom Hardy');
      expect(member.character, 'Bane');
      expect(member.profilePath, isNull);
    });

    test('Omdb Json map access example', () {
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
