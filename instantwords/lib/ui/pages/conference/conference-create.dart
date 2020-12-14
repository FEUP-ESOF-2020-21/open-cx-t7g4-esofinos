part of '../../../main.dart';

class CreateConferencePage extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  CreateConferencePage(this._storage, this._speechProvider, this.translator);

  @override
  State<CreateConferencePage> createState() => new _CreateConferencePageState();
}

class _CreateConferencePageState extends State<CreateConferencePage> {
  final TextEditingController _nameFilter = new TextEditingController();

  String _name;
  String _language;

  _CreateConferencePageState() {
    _nameFilter.addListener(_nameListen);
  }

  void _nameListen() {
    if (_nameFilter.text.isEmpty) {
      _name = "";
    } else {
      _name = _nameFilter.text;
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
            _buildInputFields(),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Conferences"),
      centerTitle: true,
    );
  }

  Widget _buildInputFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _nameFilter,
              decoration: new InputDecoration(labelText: 'Conference Name'),
            ),
          ),
          _buildLanguageDropdown()
        ],
      ),
    );
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
                _language = selectedVal;
              }),
              value: _language,
              items: widget._speechProvider.locales
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

  Widget _buildButton() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new RaisedButton(
            child: new Text('Create Conference'),
            onPressed: _createConferencePressed,
          )
        ],
      ),
    );
  }

  void _createConferencePressed() async {
    var exists = await widget._storage.getConferenceByID(_name);
    if (exists != -1) {
      _showAlertDialog("This conference already exists");
    } else if (_name == null) {
      _showAlertDialog("Please specify conference name");
    } else if (_language == null) {
      _showAlertDialog("Please specify language");
    } else {
      widget._storage.addConference(
          _name, _language, context.read<FireAuth>().currentUser.uid);
      int confIndex = await widget._storage.getConferenceByID(_name);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProviderDemoApp(
                  widget._storage,
                  widget._speechProvider,
                  confIndex,
                  _language,
                  widget.translator)));
    }
  }

  _showAlertDialog(errorMsg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Failed to create',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(errorMsg),
          );
        });
  }
}
