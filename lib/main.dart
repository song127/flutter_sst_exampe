import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// 유튜브 영상 참고하여 만든 예시 코드
// 영상에서는 예외처리 및 재실행 기능이 존재하지않아 추가적인 코드를 집어넣음
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press Voice Btn';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // 음성인식이 끝나면 알아서 noListening 상태로 바뀌면서 분석하고 _text 에 넣음
  // 인식 언어는 자동으로 구분해서 넣어줌
  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) { // 현재 상태 알려줌 ex) listening or noListening
            print('onStatus : $val');
            if(val == "notListening") {
              _speech.stop();
              setState(() {
                _isListening = false;
              });
            }
          },
          onError: (val) { // 에러 발생시 알아서 안의 메소드 실행
            print('onError : $val');
            _speech.stop();
            setState(() {
              _isListening = false;
              _text = '다시 말씀해주세요';
            });
          });

      if (available) { // available 은 이 핸드폰에서 stt 가 가능한지의 여부임
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Confidence : ${(_confidence * 100.0).toStringAsFixed(1)} %'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow( // 버튼 반짝거리게하는 패키지
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listenVoice,
          tooltip: 'listen',
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Center(
        child: Text('$_text'),
      ),
    );
  }
}
