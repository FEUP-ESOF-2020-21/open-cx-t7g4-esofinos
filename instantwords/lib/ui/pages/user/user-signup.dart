part of '../../../main.dart';

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
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('img/icon.png'),
      ),
    );

    final username = TextField(
      controller: _usernameFilter,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final email = TextField(
      controller: _emailFilter,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextField(
      controller: _passwordFilter,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final uploadButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: _uploadPressed,
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child:
            Text('Upload Profile Image', style: TextStyle(color: Colors.white)),
      ),
    );

    final registerButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: _createAccountPressed,
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Register', style: TextStyle(color: Colors.white)),
      ),
    );

    final loginLabel = FlatButton(
      child: Text(
        'Already have an account? Tap here to login.',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(widget._storage,
                    widget._speechProvider, widget.translator)));
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            username,
            SizedBox(height: 8.0),
            email,
            SizedBox(height: 8.0),
            password,
            uploadButton,
            registerButton,
            loginLabel
          ],
        ),
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
              builder: (context) => MainPage(
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
