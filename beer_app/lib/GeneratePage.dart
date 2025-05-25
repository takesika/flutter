import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _controller = TextEditingController();
  String? _resultText;
  bool _isLoading = false;

  Future<void> _callChatGPT(String beerName) async {
    setState(() {
      _isLoading = true;
      _resultText = null;
    });

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const endpoint = 'https://api.openai.com/v1/chat/completions';
    final prompt = '''
「$beerName」のうんちくを作ります。
参考にするのはよなよなエールです。下記によなよなエールのうんちくを書きます。
そちらを参考に、$beerName のうんちくを考えてください。
情報が足りない場合は検索してもよいです。味の変化がわかるように書いてください。

「おや、この香りは？お気づきのようですね。もぎたてのレモンのような、グレープフルーツの果皮のような華やかな香り。その正体は、ブルワーが愛してやまないカスケードというホップなのです。鼻腔をくすぐるこの香りを楽しむために、ぜひグラスのご用意を。香りを満喫するのが、クラフトビールの魅力ですからね。お次は味にもご注目。カラメルを思わせる甘みがふわっと広がり、炭酸の波がジュワッと押しよせる。苦味とジューシーさのうねりの中で気分が盛り上がり、心地よい酸味でフィナーレを迎える。物語の終わりを惜しむ中、鼻に抜ける香りの余韻がエンドロールのように続いていく。そして、またもう一口飲みたくなる。それはまるで、結末を知っているのに何度も見返してしまう映画のよう。あ、ついつい語りすぎました。でも、もう少しお時間をもらっていいですか？」
''';
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': prompt,
          },
        ]
      }),
    );

    final body = response.bodyBytes;
    final jsonString = utf8.decode(body); // ← 明示的にUTF-8デコード
    final json = jsonDecode(jsonString);
    final content = json['choices'][0]['message']['content'];

    setState(() {
      _isLoading = false;
      _resultText = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('うんちくを探す')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'お酒の名前を入力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _callChatGPT(_controller.text);
              },
              child: const Text('うんちくを探す'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_resultText != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _resultText!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
