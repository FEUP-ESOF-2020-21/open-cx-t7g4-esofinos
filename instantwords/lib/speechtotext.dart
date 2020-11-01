part of 'main.dart';

class ProviderDemoApp extends StatefulWidget {
  @override
  _ProviderDemoAppState createState() => _ProviderDemoAppState();
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
          appBar: AppBar(
            title: const Text('InstantWords'),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage()),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage('img/antonio_costa.jpg'),
                  radius: 50,
                ),
              ),
            ],
            elevation: 50.0,
          ),
          body: SpeechProviderExampleWidget(),
        ),
      ),
    );
  }
}

class SpeechProviderExampleWidget extends StatefulWidget {
  @override
  _SpeechProviderExampleWidgetState createState() =>
      _SpeechProviderExampleWidgetState();
}

class _SpeechProviderExampleWidgetState
    extends State<SpeechProviderExampleWidget> {
  String _currentLocaleId = "";
  void _setCurrentLocale(SpeechToTextProvider speechProvider) {
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
      if (speechProvider.systemLocale.localeId.isNotEmpty)
        _currentLocaleId = speechProvider.systemLocale.localeId;
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
                FloatingActionButton(
                  heroTag: "btn2",
                  child: Icon(
                      !speechProvider.isAvailable || speechProvider.isListening
                          ? Icons.mic
                          : Icons.mic_none),
                  onPressed: () => _listen(speechProvider),
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
                  child: speechProvider.hasResults
                      ? Text(
                          speechProvider.lastResult.recognizedWords,
                          textAlign: TextAlign.center,
                        )
                      : Container(),
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

  _listen(speechProvider) {
    speechProvider.listen(partialResults: true, localeId: _currentLocaleId);
    StreamSubscription<SpeechRecognitionEvent> _subscription;
    _subscription = speechProvider.stream.listen((recognitionEvent) async {
      switch (recognitionEvent.eventType) {
        case SpeechRecognitionEventType.finalRecognitionEvent:
          speechProvider.listen(
              partialResults: true, localeId: _currentLocaleId);
          break;
        default:
          break;
      }
    });
  }
}
