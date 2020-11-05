part of 'main.dart';

class LoginPage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;

  LoginPage(this._fireStore, this._storage);

  @override
  State<LoginPage> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();

  String _email = "";
  String _password = "";

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
                      builder: (context) =>
                          RegisterPage(widget._fireStore, widget._storage)));
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

  void _loginPressed() {
    print('The user wants to login with $_email and $_password');
    context.read<FireAuth>().loginAccount(email: _email, password: _password);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProviderDemoApp(widget._fireStore, widget._storage)),
    );
  }

  void _passwordReset() {
    print("The user wants a password reset request sent to $_email");
  }
}

class AccountPage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;

  AccountPage(this._fireStore, this._storage);
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
        child: new Column(
          children: <Widget>[
            _buildUserFields(),
            _buildButton(),
          ],
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
            backgroundImage:
                NetworkImage(context.watch<FireAuth>().currentUser.photoURL?? "https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
            radius: 200,
          ),
          Text(context.watch<FireAuth>().currentUser.email, textScaleFactor: 1.5),
          Text(context.watch<FireAuth>().currentUser.displayName, textScaleFactor: 1.5),
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
                      builder: (context) =>
                          LoginPage(widget._fireStore, widget._storage)),
                );
              },
              elevation: 10.0,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;

  RegisterPage(this._fireStore, this._storage);

  @override
  State<RegisterPage> createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();

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

    //TODO add user id to path
    profileImgPath = 'profiles/' + context.read<FireAuth>().currentUser.uid;
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
                      builder: (context) =>
                          LoginPage(widget._fireStore, widget._storage)));
            },
          )
        ],
      ),
    );
  }

  void _uploadPressed() {
    widget._storage.uploadImage(profileImgPath);
    
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  Future<void> _createAccountPressed() async {
    print('The user wants to create an accoutn with $_email and $_password');
    String pURL = await widget._storage.storage
                    .ref()
                    .child(profileImgPath)
                    .getDownloadURL() ?? profileImg;
                    
    context.read<FireAuth>().register(
        email: _email,
        password: _password,
        displayName: _username,
        photoURL: pURL
        );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProviderDemoApp(widget._fireStore, widget._storage)),
    );
  }
}
