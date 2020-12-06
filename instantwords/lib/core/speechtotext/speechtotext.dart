part of '../../main.dart';

class ProviderDemoApp extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  final int _documentIndex;
  final String _conferenceLanguage;

  ProviderDemoApp(this._storage, this._speechProvider, this._documentIndex,
      this._conferenceLanguage, this.translator);

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
            widget._storage, widget._speechProvider, widget.translator),
        body: SpeechProviderExampleWidget(
            widget._storage, widget._documentIndex, widget._conferenceLanguage),
      ),
    );
  }
}

class SpeechProviderExampleWidget extends StatefulWidget {
  final FireStorage _storage;
  final int _documentIndex;
  final String _conferenceLanguage;
  SpeechProviderExampleWidget(
      this._storage, this._documentIndex, this._conferenceLanguage);

  @override
  _SpeechProviderExampleWidgetState createState() =>
      _SpeechProviderExampleWidgetState(
          this._storage, this._documentIndex, this._conferenceLanguage);
}

class _SpeechProviderExampleWidgetState
    extends State<SpeechProviderExampleWidget> {
  final FireStorage _storage;
  int _documentIndex;
  String _conferenceLanguage;
  bool _stopListen = false;

  _SpeechProviderExampleWidgetState(
      this._storage, this._documentIndex, this._conferenceLanguage);

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

  void qrGen() async {
    String index = _documentIndex.toString();
    Uint8List contents = await scanner.generateBarCode(index);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Picture(contents)));
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
                _startListen(),
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
              onPressed: () => _stop(
                speechProvider,
              ),
            );
          },
        ),
        StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('conferences').snapshots(),
          builder: (context, snapshot) {
            return FloatingActionButton(
              heroTag: "btn4",
              child: Text('QR'),
              onPressed: () => qrGen(),
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
    if (_stopListen) return;
    _stopListen = false;
    speechProvider.listen(partialResults: true, localeId: _conferenceLanguage);
    speechProvider.stream.listen((recognitionEvent) async {
      switch (recognitionEvent.eventType) {
        case SpeechRecognitionEventType.finalRecognitionEvent:
          _storage.updateConference(
              document, {'text': speechProvider.lastResult.recognizedWords});
          speechProvider.listen(
              partialResults: true, localeId: _conferenceLanguage);
          break;
        case SpeechRecognitionEventType.errorEvent:
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

  _startListen() {
    setState(() {
      _stopListen = false;
    });
  }

  _stop(speechProvider) {
    setState(() {
      _stopListen = true;
      speechProvider.stop();
    });
  }
}

class SpectatorWidget extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  final int _documentIndex;
  final String _conferenceLanguage;

  SpectatorWidget(this._storage, this._speechProvider, this._documentIndex,
      this._conferenceLanguage, this.translator);

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
            widget._storage, widget._speechProvider, widget.translator),
        body: SpectatorScreen(
            widget._speechProvider,
            widget._documentIndex,
            widget._conferenceLanguage,
            widget.translator),
      ),
    );
  }
}

class SpectatorScreen extends StatefulWidget {
  final SpeechToTextProvider _speechProvider;
  final int _documentIndex;
  final String _conferenceLanguage;
  final translator;
  SpectatorScreen(this._speechProvider, this._documentIndex,
      this._conferenceLanguage, this.translator);

  @override
  _SpectatorScreenState createState() => _SpectatorScreenState(
      this._documentIndex,
      this._conferenceLanguage,
      this.translator);
}

class _SpectatorScreenState extends State<SpectatorScreen> {
  int _documentIndex;
  String _conferenceLanguage = "en_US";
  String _translationLanguage = "en_US";
  String _toBeTranslated = "";
  final translator;
  String _translation = "";

  _SpectatorScreenState(this._documentIndex, this._conferenceLanguage, this.translator);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [_buildLanguageDropdown(), _buildRecognizedWords()]);
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
                _translationLanguage = selectedVal;
                setState(() {
                  getTranslation(_toBeTranslated);
                });
              }),
              value: _translationLanguage,
              items: widget._speechProvider.locales
                  //Change here to widget.translator.languagelist
                  //And find way to get list of languages
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

  Widget _buildRecognizedWords() {
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
                    if (!snapshot.hasData) {
                      return Text('Loading data... Please wait...');
                    }
                    _toBeTranslated =
                        snapshot.data.documents[this._documentIndex]['text'];
                    _conferenceLanguage = snapshot
                        .data.documents[this._documentIndex]['language'];
                    return FutureBuilder(
                        future: getTranslation(_toBeTranslated),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> asyncSnapshot) {
                          if (!asyncSnapshot.hasData) {
                            return Text("Loading...");
                          }
                          return Text(_translation);
                        });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getTranslation(String text) async {
    String conLan = _conferenceLanguage.split('_')[0];
    String traLan = _translationLanguage.split('_')[0];
    _translation =
        (await translator.translate(text, from: conLan, to: traLan)).text;
    if (_translation == null) {
      _translation = "Could not translate!";
    }
    return _translation;
  }
}
