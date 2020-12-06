part of '../../main.dart';

class RegisterPage extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  RegisterPage(this._storage, this._speechProvider, this.translator);

  @override
  State<RegisterPage> createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();
  bool isInProgress = false;
  bool uploadedPicture = false;
  String _email = "";
  String _password = "";
  String _username = "";
  String profileImg =
      "https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg";
  String profileImgPath;
  _RegisterPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _usernameFilter.addListener(_usernameListen);
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

  void _usernameListen() {
    if (_usernameFilter.text.isEmpty) {
      _username = "";
    } else {
      _username = _usernameFilter.text;
    }
  }

  @override
  initState() {
    super.initState();

    profileImgPath = 'profiles/';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: isInProgress,
        child: new Scaffold(
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
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("InstantWords Registration"),
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
              decoration: new InputDecoration(labelText: 'Email'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ),
          new Container(
            child: new TextField(
              controller: _usernameFilter,
              decoration: new InputDecoration(labelText: 'Username'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new RaisedButton(
            child: new Text('Upload Photo'),
            onPressed: _uploadPressed,
          ),
          new RaisedButton(
            child: new Text('Create an Account'),
            onPressed: _createAccountPressed,
          ),
          new FlatButton(
            child: new Text('Have an account? Click here to login.'),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(widget._storage,
                          widget._speechProvider, widget.translator)));
            },
          )
        ],
      ),
    );
  }

  void _uploadPressed() {
    profileImgPath += _username;
    widget._storage.uploadImage(profileImgPath);
    setState(() {
      uploadedPicture = true;
    });
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  Future<void> _createAccountPressed() async {
    print('The user wants to create an accoutn with $_email and $_password');
    if (!uploadedPicture)
      _showAlertDialog("No Profile Picture!");
    else {
      String pURL = await widget._storage.storage
              .ref()
              .child(profileImgPath)
              .getDownloadURL() ??
          profileImg;
      final status = await FireAuth().register(
          email: _email,
          password: _password,
          displayName: _username,
          photoURL: pURL);
      if (status == AuthResultStatus.successful) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Dashboard(
                  widget._storage, widget._speechProvider, widget.translator)),
        );
      } else {
        final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
        _showAlertDialog(errorMsg);
      }
    }
  }

  _showAlertDialog(errorMsg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Register Failed',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(errorMsg),
          );
        });
  }
}
