part of 'main.dart';

class ProviderDemoApp extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;

  ProviderDemoApp(this._fireStore, this._storage);

  @override
  _ProviderDemoAppState createState() => new _ProviderDemoAppState();
}

class _ProviderDemoAppState extends State<ProviderDemoApp> {
  final SpeechToText speech = SpeechToText();
  SpeechToTextProvider speechProvider;

  @override
  void initState() {
    super.initState();
    speechProvider = SpeechToTextProvider(speech);
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    await speechProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechToTextProvider>.value(
      value: speechProvider,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(widget._fireStore, widget._storage),
          body: SpeechProviderExampleWidget(widget._fireStore, widget._storage),
        ),
      ),
    );
  }
}

class SpeechProviderExampleWidget extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;

  SpeechProviderExampleWidget(this._fireStore, this._storage);

  @override
  _SpeechProviderExampleWidgetState createState() =>
      _SpeechProviderExampleWidgetState(this._fireStore, this._storage);
}

class _SpeechProviderExampleWidgetState
    extends State<SpeechProviderExampleWidget> {
  final FireStore _fireStore;
  final FireStorage _storage;

  _SpeechProviderExampleWidgetState(this._fireStore, this._storage);

  String _currentLocaleId = "";
  void _setCurrentLocale(SpeechToTextProvider speechProvider) {
    //MUST FIX - LOCALE ID NULL ON LOGOOUT AND LOGIN
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
      try {
        if (speechProvider.systemLocale.localeId.isNotEmpty)
          _currentLocaleId = speechProvider.systemLocale.localeId;
      } catch (e) {
        print(e);
        _currentLocaleId = "en_GB";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var speechProvider = Provider.of<SpeechToTextProvider>(context);

    if (speechProvider.isNotAvailable) {
      return Center(
        child: Text(
            'Speech recognition not available, no permission or not available on the device.'),
      );
    }
    _setCurrentLocale(speechProvider);
    return Column(children: [
      Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('conferences')
                      .snapshots(),
                  builder: (context, snapshot) {
                    return FloatingActionButton(
                      heroTag: "btn2",
                      child: Icon(!speechProvider.isAvailable ||
                              speechProvider.isListening
                          ? Icons.mic
                          : Icons.mic_none),
                      onPressed: () => _listen(speechProvider,
                          snapshot.data.documents[0].documentID),
                    );
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn3",
                  child: Text('Stop'),
                  onPressed: speechProvider.isListening
                      ? () => speechProvider.stop()
                      : null,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                DropdownButton(
                  onChanged: (selectedVal) => _switchLang(selectedVal),
                  value: _currentLocaleId,
                  items: speechProvider.locales
                      .map(
                        (localeName) => DropdownMenuItem(
                          value: localeName.localeId,
                          child: Text(localeName.name),
                        ),
                      )
                      .toList(),
                ),
              ],
            )
          ],
        ),
      ),
      Expanded(
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
                      if (speechProvider.hasResults)
                        _storage.updateConference(
                            snapshot.data.documents[0].documentID, {
                          'Text': speechProvider.lastResult.recognizedWords
                        });
                      if (!snapshot.hasData)
                        return Text('Loading data... Please wait...');
                      return Text(snapshot.data.documents[0]['Text']);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
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
      ),
      Container(
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
      ),
    ]);
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  _listen(speechProvider, document) {
    speechProvider.listen(partialResults: true, localeId: _currentLocaleId);
    StreamSubscription<SpeechRecognitionEvent> _subscription;
    _subscription = speechProvider.stream.listen((recognitionEvent) async {
      switch (recognitionEvent.eventType) {
        case SpeechRecognitionEventType.finalRecognitionEvent:
          _storage.updateConference(
              document, {'Text': speechProvider.lastResult.recognizedWords});
          speechProvider.listen(
              partialResults: true, localeId: _currentLocaleId);
          break;
        default:
          break;
      }
    });
  }
}
