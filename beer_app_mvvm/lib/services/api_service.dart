import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/beer_data.dart';
import '../models/app_state.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<BeerData> generateBeerDescription(String beerName) async {
    final openaiKey = dotenv.env['OPENAI_API_KEY'];
    if (openaiKey == null || openaiKey.isEmpty) {
      throw AppException(AppError.apiKey, 'OpenAI API key not found');
    }

    final prompt = '''
「$beerName」のうんちくを作ります。
参考にするのはよなよなエールです。下記によなよなエールのうんちくを書きます。
そちらを参考に、$beerName のうんちくを考えてください。
情報が足りない場合は検索してもよいです。味の変化がわかるように書いてください。

「おや、この香りは？お気づきのようですね。もぎたてのレモンのような、グレープフルーツの果皮のような華やかな香り。その正体は、ブルワーが愛してやまないカスケードというホップなのです。鼻腔をくすぐるこの香りを楽しむために、ぜひグラスのご用意を。香りを満喫するのが、クラフトビールの魅力ですからね。お次は味にもご注目。カラメルを思わせる甘みがふわっと広がり、炭酸の波がジュワッと押しよせる。苦味とジューシーさのうねりの中で気分が盛り上がり、心地よい酸味でフィナーレを迎える。物語の終わりを惜しむ中、鼻に抜ける香りの余韻がエンドロールのように続いていく。そして、またもう一口飲みたくなる。それはまるで、結末を知っているのに何度も見返してしまう映画のよう。あ、ついつい語りすぎました。でも、もう少しお時間をもらっていいですか？」
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $openaiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 500,
          'temperature': 0.9,
        }),
      );

      if (response.statusCode != 200) {
        throw AppException(AppError.network, 'OpenAI API request failed: ${response.statusCode}');
      }

      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      final description = json['choices']?[0]?['message']?['content'] ?? '';

      if (description.isEmpty) {
        throw AppException(AppError.parsing, 'Empty description received from OpenAI');
      }

      // 画像を取得
      final imageUrl = await _fetchBeerImage(beerName);

      return BeerData(
        name: beerName,
        description: description,
        imageUrl: imageUrl,
        category: 'AI生成',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppError.unknown, 'Failed to generate beer description: $e');
    }
  }

  Future<String> _fetchBeerImage(String beerName) async {
    final unsplashKey = dotenv.env['UNSPLASH_ACCESS_KEY'];
    if (unsplashKey == null || unsplashKey.isEmpty) {
      return ''; // 画像がなくても続行
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/search/photos?query=$beerName&per_page=1'),
        headers: {
          'Authorization': 'Client-ID $unsplashKey'
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return results[0]['urls']['regular'] ?? '';
        }
      }
    } catch (e) {
      // 画像取得失敗は致命的ではない
    }

    return '';
  }
}