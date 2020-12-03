part of 'main.dart';

class LoginPage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  LoginPage(
      this._fireStore, this._storage, this._speechProvider, this.translator);

  @override
  State<LoginPage> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();

  String _email = "";
  String _password = "";
  bool isInProgress = false;

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
              keyboardType: TextInputType.emailAddress,
              decoration: new InputDecoration(labelText: 'Email'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              keyboardType: TextInputType.visiblePassword,
              decoration: new InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new RaisedButton(
            child: new Text('Login'),
            onPressed: _loginPressed,
          ),
          new FlatButton(
            child: new Text('Dont have an account? Tap here to register.'),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterPage(
                          widget._fireStore,
                          widget._storage,
                          widget._speechProvider,
                          widget.translator)));
            },
          ),
          new FlatButton(
            child: new Text('Forgot Password?'),
            onPressed: _passwordReset,
          )
        ],
      ),
    );
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed() async {
    setState(() {
      isInProgress = true;
    });
    print('The user wants to login with $_email and $_password');
    final status =
        await FireAuth().loginAccount(email: _email, password: _password);
    setState(() {
      isInProgress = false;
    });
    if (status == AuthResultStatus.successful) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Dashboard(widget._fireStore, widget._storage,
                widget._speechProvider, widget.translator)),
      );
    } else {
      final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
      _showAlertDialog(errorMsg);
    }
  }

  _showAlertDialog(errorMsg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Login Failed',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(errorMsg),
          );
        });
  }

  void _passwordReset() {
    print("The user wants a password reset request sent to $_email");
  }
}

class AccountPage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  final bool needPop = false;
  int conferences_Size;

  AccountPage(
      this._fireStore, this._storage, this._speechProvider, this.translator);
  @override
  State<AccountPage> createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              _buildUserFields(),
              Text("Your Conferences:",textScaleFactor: 2),
              _buildCreatedConferenceBlocks(),
              Text("Conferences you attended:",textScaleFactor: 2),
              _buildAttendedConferenceBlocks(),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("InstantWords"),
      centerTitle: true,
    );
  }

  Widget _buildUserFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(context
                    .watch<FireAuth>()
                    .currentUser
                    .photoURL ??
                "https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
            radius: 100,
          ),
          Text("E-mail: " + context.watch<FireAuth>().currentUser.email,
              textScaleFactor: 1.5),
          Text("Username: " + context.watch<FireAuth>().currentUser.displayName,
              textScaleFactor: 1.5),
          
        ],
      ),
    );
  }

  Widget _buildButton() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new SizedBox(
            width: 300.0,
            height: 50.0,
            child: FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              heroTag: "btn1",
              label: Text(
                'LOGOUT',
                textScaleFactor: 2.0,
              ),
              onPressed: () async {
                context.read<FireAuth>().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                          widget._fireStore,
                          widget._storage,
                          widget._speechProvider,
                          widget.translator)),
                );
              },
              elevation: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedConferenceBlocks() {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _getConferences(),
        ),
      ),
    );
  }

  Widget _buildAttendedConferenceBlocks() {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _getAttendedConferences(),
        ),
      ),
    );
  }

  Widget _getConferences() {
    return FutureBuilder(
        future: widget._storage.getOwnerConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          widget.conferences_Size = content.length;
          return new ListView.builder(
            itemCount: widget.conferences_Size,
            itemBuilder: (BuildContext context, int index) {
              return new RaisedButton(
                onPressed: () => _goToConferencePressed(
                    content[index].id.toString(), content[index]['language']),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: new ListTile(
                        leading: Icon(Icons.analytics, size: 50),
                        title: Text(content[index].id.toString(),
                            textScaleFactor: 2),
                        subtitle: Text(content[index]['language'],
                            textScaleFactor: 1.2),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _getAttendedConferences() {
    return FutureBuilder(
        future: widget._storage.getAttendeeConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          widget.conferences_Size = content.length;
          return new ListView.builder(
            itemCount: widget.conferences_Size,
            itemBuilder: (BuildContext context, int index) {
              return new ElevatedButton(
                onPressed: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: new ListTile(
                        leading: Icon(Icons.analytics, size: 50),
                        title: Text(content[index].id.toString(),
                            textScaleFactor: 2),
                        subtitle: Text(content[index]['language'],
                            textScaleFactor: 1.2),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _goToConferencePressed(String id, String language) async {
    int confIndex = await widget._storage.getConferenceByID(id);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProviderDemoApp(
                widget._fireStore,
                widget._storage,
                widget._speechProvider,
                confIndex,
                language,
                widget.translator)));
  }
}

class RegisterPage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  RegisterPage(
      this._fireStore, this._storage, this._speechProvider, this.translator);

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
                      builder: (context) => LoginPage(
                          widget._fireStore,
                          widget._storage,
                          widget._speechProvider,
                          widget.translator)));
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
              builder: (context) => Dashboard(widget._fireStore,
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
