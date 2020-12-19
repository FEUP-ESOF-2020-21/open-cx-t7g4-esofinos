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
    final appBar = AppBar(
      title: new Text("Conferences"),
      centerTitle: true,
    );

    final name = TextField(
      controller: _nameFilter,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Conference Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final language = InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      child: DropdownButton<String>(
        underline: SizedBox(),
        isExpanded: true,
        hint: Text('Language'),
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
      ),
    );

    final createButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: _createConferencePressed,
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Create Conference', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            name,
            SizedBox(height: 8.0),
            language,
            SizedBox(height: 48.0),
            createButton
          ],
        ),
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
