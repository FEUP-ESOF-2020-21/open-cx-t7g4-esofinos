import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'InstantWords Login',
      theme: new ThemeData(
        primarySwatch: Colors.blue
      ),
      home: new LoginPage(),
    );
  }
}

class ProviderDemoApp extends StatefulWidget {
  @override
  _ProviderDemoAppState createState() => _ProviderDemoAppState();
}



class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => new _LoginPageState();
}


class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

// Used for controlling whether the user is loggin or creating an account
enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _email = "";
  String _password = "";
  FormType _form = FormType.login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange () async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            _buildTextFields(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("InstantWords Login"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(
                labelText: 'Email'
              ),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(
                labelText: 'Password'
              ),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Login'),
              onPressed: _loginPressed,
            ),
            new FlatButton(
              child: new Text('Dont have an account? Tap here to register.'),
              onPressed: _formChange,
            ),
            new FlatButton(
              child: new Text('Forgot Password?'),
              onPressed: _passwordReset,
            )
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Create an Account'),
              onPressed: _createAccountPressed,
            ),
            new FlatButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed () {
    print('The user wants to login with $_email and $_password');
	Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProviderDemoApp()),
            );
  }

  void _createAccountPressed () {
    print('The user wants to create an accoutn with $_email and $_password');

  }

  void _passwordReset () {
    print("The user wants a password reset request sent to $_email");
  }


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
  int _state = 0;
  void _setCurrentLocale(SpeechToTextProvider speechProvider) {
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
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
                  child: Icon(
                      !speechProvider.isAvailable || speechProvider.isListening
                          ? Icons.mic
                          : Icons.mic_none),
                  onPressed: () => _listen(speechProvider),
                ),
                FloatingActionButton(
                  child: Text('Stop'),
                  onPressed: speechProvider.isListening
                      ? () => speechProvider.stop()
                      : null,
                ),
                FloatingActionButton(
                  child: Text('Cancel'),
                  onPressed: speechProvider.isListening
                      ? () => speechProvider.cancel()
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
    speechProvider.listen(
              partialResults: true, localeId: _currentLocaleId);
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
