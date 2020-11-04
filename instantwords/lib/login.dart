part of 'main.dart';

UserCredential userCredential;

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => new _LoginPageState();
}

// Used for controlling whether the user is loggin or creating an account
enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();

  String _email = "";
  String _password = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

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
  void _formChange() async {
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
              decoration: new InputDecoration(labelText: 'Email'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: 'Password'),
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

  void _loginPressed() {
    print('The user wants to login with $_email and $_password');
    loginAccount();
  }

  Future<void> loginAccount() async {
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProviderDemoApp()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  void _createAccountPressed() {
    print('The user wants to create an accoutn with $_email and $_password');
    createAccount();
  }

  Future<void> createAccount() async {
    try {
      userCredential=await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProviderDemoApp()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void _passwordReset() {
    print("The user wants a password reset request sent to $_email");
  }
}

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _email = "";

  _AccountPageState() {
    _getEmail();
  }

  void _getEmail() {
    _email = userCredential.user.email;
  }

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
            backgroundImage: AssetImage('img/antonio_costa.jpg'),
            radius: 200,
          ),
          Text(_email, textScaleFactor: 1.5),
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
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
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
