part of 'main.dart';

class ProviderDemoApp extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  int _documentIndex;
  String _conferenceLanguage;

  ProviderDemoApp(this._fireStore, this._storage, this._speechProvider,
      this._documentIndex, this._conferenceLanguage,this.translator);

  @override
  _ProviderDemoAppState createState() => new _ProviderDemoAppState();
}

class _ProviderDemoAppState extends State<ProviderDemoApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechToTextProvider>.value(
      value: widget._speechProvider,
      child: Scaffold(
        appBar: AppBarWidget(
            widget._fireStore, widget._storage, widget._speechProvider,widget.translator),
        body: SpeechProviderExampleWidget(widget._fireStore, widget._storage,
            widget._documentIndex, widget._conferenceLanguage),
      ),
    );
  }
}

class SpeechProviderExampleWidget extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  int _documentIndex;
  String _conferenceLanguage;
  SpeechProviderExampleWidget(this._fireStore, this._storage,
      this._documentIndex, this._conferenceLanguage);

  @override
  _SpeechProviderExampleWidgetState createState() =>
      _SpeechProviderExampleWidgetState(this._fireStore, this._storage,
          this._documentIndex, this._conferenceLanguage);
}

class _SpeechProviderExampleWidgetState
    extends State<SpeechProviderExampleWidget> {
  final FireStore _fireStore;
  final FireStorage _storage;
  int _documentIndex;
  String _conferenceLanguage;
  bool _stopListen = false;

  _SpeechProviderExampleWidgetState(this._fireStore, this._storage,
      this._documentIndex, this._conferenceLanguage);

  @override
  Widget build(BuildContext context) {
    var speechProvider = Provider.of<SpeechToTextProvider>(context);

    if (speechProvider.isNotAvailable) {
      return Center(
        child: Text(
            'Speech recognition not available, no permission or not available on the device.'),
      );
    }

    return Column(children: [
      _buildControlBar(speechProvider),
      _buildRecognizedWords(speechProvider),
      _buildErrorStatus(speechProvider),
      _buildListeningStatus(speechProvider)
    ]);
  }

  Widget _buildControlBar(speechProvider) {
    return Container(
      child: Column(
        children: <Widget>[_buildButtons(speechProvider)],
      ),
    );
  }

  Widget _buildButtons(speechProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('conferences').snapshots(),
          builder: (context, snapshot) {
            return FloatingActionButton(
              heroTag: "btn2",
              child: Icon(
                  !speechProvider.isAvailable || speechProvider.isListening
                      ? Icons.mic
                      : Icons.mic_none),
              onPressed: () => {
                print("Listening to: " +
                    snapshot.data.documents[this._documentIndex].documentID),
                _listen(speechProvider,
                    snapshot.data.documents[this._documentIndex].documentID)
              },
            );
          },
        ),
        StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('conferences').snapshots(),
          builder: (context, snapshot) {
            return FloatingActionButton(
              heroTag: "btn3",
              child: Text('Stop'),
              onPressed: () => _stop(speechProvider,
                  snapshot.data.documents[this._documentIndex].documentID),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecognizedWords(speechProvider) {
    return Expanded(
      flex: 4,
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Recognized Words',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).selectedRowColor,
              child: Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('conferences')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (speechProvider.hasResults) {
                      print("In builder, wrote to: " +
                          snapshot
                              .data.documents[this._documentIndex].documentID);
                      _storage.updateConference(
                          snapshot
                              .data.documents[this._documentIndex].documentID,
                          {'text': speechProvider.lastResult.recognizedWords});
                    }

                    if (!snapshot.hasData)
                      return Text('Loading data... Please wait...');
                    return Text(
                        snapshot.data.documents[this._documentIndex]['text']);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(speechProvider) {
    return Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Error Status',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          Center(
            child: speechProvider.hasError
                ? Text(speechProvider.lastError.errorMsg)
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningStatus(speechProvider) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).backgroundColor,
      child: Center(
        child: speechProvider.isListening
            ? Text(
                "I'm listening...",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                'Not listening',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  _listen(speechProvider, document) {
    _stopListen = false;
    if (_stopListen) return;
    print("In listen (start), wrote to: " + document);
    speechProvider.listen(partialResults: true, localeId: _conferenceLanguage);
    speechProvider.stream.listen((recognitionEvent) async {
      switch (recognitionEvent.eventType) {
        case SpeechRecognitionEventType.finalRecognitionEvent:
          print("In listen (pause), wrote to: " + document);
          _storage.updateConference(
              document, {'text': speechProvider.lastResult.recognizedWords});
          speechProvider.listen(
              partialResults: true, localeId: _conferenceLanguage);
          break;
        case SpeechRecognitionEventType.errorEvent:
          print("In listen (error), wrote to: " + document);
          _storage.updateConference(
              document, {'text': speechProvider.lastResult.recognizedWords});
          speechProvider.listen(
              partialResults: true, localeId: _conferenceLanguage);
          break;
        default:
          break;
      }
    });
  }

  _stop(speechProvider, document) {
    setState(() {
      _stopListen = true;
    });

    speechProvider.stop();
  }
}

class SpectatorWidget extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  int _documentIndex;
  String _conferenceLanguage;

  SpectatorWidget(this._fireStore, this._storage, this._speechProvider,
      this._documentIndex, this._conferenceLanguage,this.translator);

  @override
  _SpectatorWidgetState createState() => new _SpectatorWidgetState();
}

class _SpectatorWidgetState extends State<SpectatorWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechToTextProvider>.value(
      value: widget._speechProvider,
      child: Scaffold(
        appBar: AppBarWidget(
            widget._fireStore, widget._storage, widget._speechProvider,widget.translator),
        body: SpectatorScreen(widget._fireStore, widget._storage, widget._speechProvider,
            widget._documentIndex, widget._conferenceLanguage,widget.translator),
      ),
    );
  }
}

class SpectatorScreen extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  int _documentIndex;
  String _conferenceLanguage;
  final translator;
  SpectatorScreen(this._fireStore, this._storage, this._speechProvider,
      this._documentIndex, this._conferenceLanguage,this.translator);

  @override
  _SpectatorScreenState createState() =>
      _SpectatorScreenState(this._fireStore, this._storage, this._speechProvider,
          this._documentIndex, this._conferenceLanguage,this.translator);
}

class _SpectatorScreenState
    extends State<SpectatorScreen> {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  int _documentIndex;
  String _conferenceLanguage;
  final translator;
  var _translation;

  _SpectatorScreenState(this._fireStore, this._storage, this._speechProvider,
      this._documentIndex, this._conferenceLanguage,this.translator);


  @override
  Widget build(BuildContext context) {
    return Column(children: [
       _buildLanguageDropdown(),
      _buildRecognizedWords()
    ]);
  }
   Widget _buildLanguageDropdown() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 25),
          child: Text('Language', textScaleFactor: 1.5),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: DropdownButton<String>(
              onChanged: (selectedVal) => setState(() {
                _conferenceLanguage = selectedVal;
              }),
              value: _conferenceLanguage,
              items: widget._speechProvider.locales
                  .map<DropdownMenuItem<String>>(
                      (localeName) => DropdownMenuItem<String>(
                            value: localeName.localeId,
                            child: Text(localeName.name),
                          ))
                  .toList(),
            ))
      ],
    );
  }
  Widget _buildRecognizedWords(){
    return Expanded(
      flex: 4,
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Recognized Words',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).selectedRowColor,
              child: Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('conferences')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Text('Loading data... Please wait...');
                    //getTranslation(snapshot.data.documents[this._documentIndex]['text']);
                    return Text(snapshot.data.documents[this._documentIndex]['text']);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Text> getTranslation(String text) async {
    print(_conferenceLanguage.split("_")[0]);
      _translation = await translator.translate(
                          text,
                          to: _conferenceLanguage.split("_")[0]);
  }

}
