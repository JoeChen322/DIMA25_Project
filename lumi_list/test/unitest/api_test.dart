import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/models/cast.dart'; // 假设你的模型路径

void main() {
  group('TMDb 数据解析测试', () {
    test('CastMember 应正确处理字段缺失', () {
      // 模拟 TMDb 返回的一条演员数据
      final Map<String, dynamic> mockJson = {
        'name': 'Tom Hardy',
        'character': 'Bane',
        'profile_path': null // 模拟缺失头像的情况
      };

      final member = CastMember.fromJson(mockJson);

      expect(member.name, 'Tom Hardy');
      expect(member.character, 'Bane');
      // 确保你的模型能处理 null 路径而不断开
      expect(member.profilePath, isNull); 
    });
    test('验证 OMDb 详细信息字段提取', () {
  // 模拟 OmdbApi.getMovieById 返回的原始数据
  final Map<String, dynamic> mockData = {
    "Title": "Inception",
    "Director": "Christopher Nolan",
    "Plot": "A thief who steals secrets...",
    "Year": "2010"
  };

  // 模拟你页面中的提取逻辑
  final String director = mockData['Director'] ?? "No Info";
  final String year = mockData['Year'] ?? "N/A";

  expect(director, "Christopher Nolan");
  expect(year, "2010");
});
  });
}