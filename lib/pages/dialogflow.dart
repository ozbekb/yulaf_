import 'dart:async';
import 'package:social_wall/widgets/chat_buble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
//import 'package:speech_to_text/speech_recognition_result.dart';
//import 'package:speech_to_text/speech_to_text.dart';

class DialogFlow extends StatefulWidget {
  const DialogFlow({Key? key}) : super(key: key);

  @override
  State<DialogFlow> createState() => _DialogFlowState();
}

class _DialogFlowState extends State<DialogFlow> {
  // message text controller
  final TextEditingController _textController = TextEditingController();

  // list of messages that will be displayed on the screen
  final List<ChatMessage> _messages = <ChatMessage>[];

  // for changing recording icon
  bool _isRecording = false;

  //late final SpeechToText speechToText;
  late StreamSubscription _recorderStatus;
  late StreamSubscription<List<int>> _audioStreamSubscription;
  late DialogflowGrpcV2Beta1 dialogflow;

  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  Future<void> initPlugin() async {
    // initializing speech t otext plugin
    // speechToText = SpeechToText();

    // requiried for setting up dialogflow
    final serviceAccount = ServiceAccount.fromString(
      await rootBundle.loadString(
        'assets/cred.json',
      ),
    );

    // dialogflow setup
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
    setState(() {});

    // Initialize speech recognition services, returns true if successful, false if failed.
    //await speechToText.initialize(
    //options: [SpeechToText.androidIntentLookup],
    //);
  }

  void stopStream() async {
    await _audioStreamSubscription.cancel();
  }

  void handleSubmitted(text) async {
    _textController.clear();

    ChatMessage message = ChatMessage(
      text: text,
      name: "You",
      type: true,
    );

    setState(() {
      _messages.insert(0, message);
    });

    // callling dialogflow api
    DetectIntentResponse data = await dialogflow.detectIntent(text, 'en-US');

    // getting meaningful response text
    String fulfillmentText = data.queryResult.fulfillmentText;
    if (fulfillmentText.isNotEmpty) {
      ChatMessage botMessage = ChatMessage(
        text: fulfillmentText,
        name: "Bot",
        type: false,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    }
  }

  /*void _onSpeechResult(SpeechRecognitionResult result) async {
    String lastWords = result.recognizedWords;

    // setting textediting controller to the speech value and moving cursor at the end
    _textController.text = lastWords;
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );

    setState(() {
      _isRecording = false;
    });
    await Future.delayed(const Duration(seconds: 5));
    _stopListening();
  }*/

  /*void handleStream() async {
    setState(() {
      _isRecording = true;
    });
    await speechToText.listen(
      onResult: _onSpeechResult,
    );
  }

  void _stopListening() async {
    await speechToText.stop();
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    _audioStreamSubscription.cancel();
    speechToText.stop();
    super.dispose();
  }*/

  // The chat interface
  //
  //------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.blue.shade400,
        title: const Text(
          "Dialogflow ChatBot",
          style: TextStyle(
              //color: Colors.white,
              ),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (ctx, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: handleSubmitted,
                    decoration: const InputDecoration.collapsed(
                        hintText: "Send a message"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => handleSubmitted(_textController.text),
                  ),
                ),
                /*IconButton(
                    iconSize: 30.0,
                    icon: Icon(_isRecording ? Icons.mic : Icons.mic_off),
                    onPressed: () {
                      // handleStream();
                    }),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
