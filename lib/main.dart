import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool check = false;
  bool imagechecker = false;
  String _lastWords = '';
  String saidWord = '';
  dynamic meaning;

  dynamic example;

  dynamic pictureUrl;

  dynamic type;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      getDefinition(_lastWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audible Dictionary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: check
                    ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Your Word:",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '$saidWord',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Container(
                          color: Colors.grey,
                          child: Column(
                              children: [ Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Meaning:",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    '$meaning',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ]
                          )

                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                            color: Colors.grey,
                            child: Column(
                                children: [ Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Example:",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      '$example',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ]
                            )

                        ),
                      ),
                     imagechecker? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                            height: 100
                            ,
                            width: 100,
                            child:
                            Image.network(
                                '$pictureUrl')

                        ),
                      ):Container(child:Text(
                       'No image available',
                       style: TextStyle(
                           fontSize: 20.0,
                           fontWeight: FontWeight.bold,
                           color: Colors.black),
                     ),
                     )

                    ])

                    : const Text(
                  "Press the Button to start speaking",
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed:
                // If not yet listening for speech start, otherwise stop
                _speechToText.isNotListening ? _startListening : _stopListening,

                child: Icon(
                    _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  // <-- Button color
                  overlayColor:
                  MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.pressed))
                      return Colors.red; // <-- Splash color
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getDefinition(String word) async {
    String url =
        'https://owlbot.info/api/v4/dictionary/$word?=8f7bc064ce6ac0f41566b45bebc1e337dbec005e';
    var headers = {
      'Authorization': 'Token 08a5e3222b8be11a8bdcbaa455cb0f7ab1e7f608'
    };
    var request = http.Request('GET', Uri.parse(url));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var finalResponse = await response.stream.bytesToString();
      var jsonResponse = json.decode(finalResponse);
      // WordModel wordModel = json.decode(json.encode(finalResponse));
      //  print(wordModel.word);

      var definitions = json.decode(json.encode(jsonResponse['definitions']));
      print('definitions $definitions');
      print(jsonResponse["word"]);
      setState(() {
        saidWord = jsonResponse['word'];
        meaning = definitions[0]['definition'];
        example = definitions[0]['example'];
        pictureUrl = definitions[0]['image_url'];
        type = definitions[0]['type'];
        if (meaning != null) {
          check = true;
        }
        if(pictureUrl!=null){
          setState(() {
            imagechecker =true;
          });
        }
      });
      print('$saidWord $meaning $example $pictureUrl $type');
    } else {
      print(response.reasonPhrase);
    }
  }


}
