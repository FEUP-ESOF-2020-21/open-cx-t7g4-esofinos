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

  var subscription;

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

    final conferenceTitle = StreamBuilder(
      stream: FirebaseFirestore.instance.collection('conferences').snapshots(),
      builder: (context, snapshot) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
                snapshot.data.documents[this._documentIndex].documentID
                    .toString(),
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)));
      },
    );

    final conferenceDescription = StreamBuilder(
      stream: FirebaseFirestore.instance.collection('conferences').snapshots(),
      builder: (context, snapshot) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
                snapshot.data.documents[this._documentIndex]['description']
                    .toString(),
                style: TextStyle(fontSize: 20)));
      },
    );

    final startButton = StreamBuilder(
      stream: FirebaseFirestore.instance.collection('conferences').snapshots(),
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () => {
              _startListen(),
              _listen(speechProvider,
                  snapshot.data.documents[this._documentIndex].documentID)
            },
            padding: EdgeInsets.all(12),
            color: Colors.lightBlueAccent,
            child:
                Text('Start Speaking', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );

    final stopButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () => {_stop(speechProvider)},
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Stop Speaking', style: TextStyle(color: Colors.white)),
      ),
    );

    final listeningStatus = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () => {},
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent[50],
        child: Text(
            speechProvider.isListening ? "I'm listening..." : "Not listening",
            style: TextStyle(color: Colors.black)),
      ),
    );

    final recognizedWords = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Center(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('conferences')
                  .snapshots(),
              builder: (context, snapshot) {
                if (speechProvider.hasResults && snapshot.hasData) {
                  _storage.updateConference(
                      snapshot.data.documents[this._documentIndex].documentID,
                      {'text': speechProvider.lastResult.recognizedWords});
                }

                if (!snapshot.hasData)
                  return Text('Loading data... Please wait...');
                return Text(
                  snapshot.data.documents[this._documentIndex]['text'],
                  textScaleFactor: 1.5,
                );
              },
            ),
          ),
        ),
      ),
    );

    final qrButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: qrGen,
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('QR Code', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            conferenceTitle,
            conferenceDescription,
            SizedBox(height: 24.0),
            startButton,
            stopButton,
            listeningStatus,
            SizedBox(height: 40.0),
            recognizedWords,
            SizedBox(height: 100.0),
            qrButton,
          ],
        ),
      ),
    );
  }

  void qrGen() async {
    String index = _documentIndex.toString();
    Uint8List contents = await scanner.generateBarCode(index);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Picture(contents)));
  }

  _listen(speechProvider, document) {
    if (_stopListen) return;
    speechProvider.listen(partialResults: true, localeId: _conferenceLanguage);
    subscription = speechProvider.stream.listen((recognitionEvent) async {
      switch (recognitionEvent.eventType) {
        case SpeechRecognitionEventType.finalRecognitionEvent:
          print("Final Recognition");
          _storage.updateConference(
              document, {'text': speechProvider.lastResult.recognizedWords});
          subscription.cancel();
          _listen(speechProvider, document);
          break;
        case SpeechRecognitionEventType.errorEvent:
          print("error in Recognition");
          subscription.cancel();
          _listen(speechProvider, document);
          break;
        default:
          break;
      }
    });
  }

  _startListen() {
    _stopListen = false;
  }

  _stop(speechProvider) {
    setState(() {
      _stopListen = true;
      speechProvider.listen(
          partialResults: true, localeId: _conferenceLanguage);
      speechProvider.cancel();
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
        body: SpectatorScreen(widget._speechProvider, widget._documentIndex,
            widget._conferenceLanguage, widget.translator),
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
      this._documentIndex, this._conferenceLanguage, this.translator);
}

class _SpectatorScreenState extends State<SpectatorScreen> {
  int _documentIndex;
  String _conferenceLanguage = "en_US";
  String _translationLanguage = "en_US";
  String _toBeTranslated = "";
  final translator;
  String _translation = "";

  _SpectatorScreenState(
      this._documentIndex, this._conferenceLanguage, this.translator);

  @override
  Widget build(BuildContext context) {
    final conferenceTitle = StreamBuilder(
      stream: FirebaseFirestore.instance.collection('conferences').snapshots(),
      builder: (context, snapshot) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
                snapshot.hasData
                    ? snapshot.data.documents[this._documentIndex].documentID
                        .toString()
                    : "Loading...",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)));
      },
    );

    final conferenceDescription = StreamBuilder(
      stream: FirebaseFirestore.instance.collection('conferences').snapshots(),
      builder: (context, snapshot) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
                snapshot.hasData
                    ? snapshot
                        .data.documents[this._documentIndex]['description']
                        .toString()
                    : "Loading... ",
                style: TextStyle(fontSize: 20)));
      },
    );

    final language = InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      child: DropdownButton<String>(
        underline: SizedBox(),
        isExpanded: true,
        onChanged: (selectedVal) => setState(() {
          _translationLanguage = selectedVal;
          setState(() {
            getTranslation(_toBeTranslated);
          });
        }),
        value: _translationLanguage,
        items: widget._speechProvider.locales
            .map<DropdownMenuItem<String>>(
              (localeName) => DropdownMenuItem<String>(
                value: localeName.localeId,
                child: Text(localeName.name),
              ),
            )
            .toList(),
      ),
    );

    final recognizedWords = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
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
                _conferenceLanguage =
                    snapshot.data.documents[this._documentIndex]['language'];
                return FutureBuilder(
                    future: getTranslation(_toBeTranslated),
                    builder: (BuildContext context,
                        AsyncSnapshot<String> asyncSnapshot) {
                      if (!asyncSnapshot.hasData) {
                        return Text("Loading...");
                      }
                      return Text(
                        _translation,
                        textScaleFactor: 1.5,
                      );
                    });
              },
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            conferenceTitle,
            conferenceDescription,
            SizedBox(height: 30.0),
            language,
            SizedBox(height: 100.0),
            recognizedWords,
          ],
        ),
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
