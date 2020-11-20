part of 'main.dart';

class Dashboard extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  Dashboard(
      this._fireStore, this._storage, this._speechProvider, this.translator);

  @override
  State<Dashboard> createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int conferences_Size;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBarWidget(widget._fireStore, widget._storage,
          widget._speechProvider, widget.translator),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            _buildAddConference(),
            _buildConferenceBlocks(),
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

  Widget _buildConferenceBlocks() {
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

  Widget _getConferences() {
    return FutureBuilder(
        future: widget._storage.getConferences(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          conferences_Size = content.length;
          return new ListView.builder(
            itemCount: conferences_Size,
            itemBuilder: (BuildContext context, int index) {
              return new RaisedButton(
                onPressed: () =>
                    _conferencePressed(index, content[index]['language']),
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

  Widget _buildAddConference() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: RaisedButton(
        onPressed: _createConferencePressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
              child: const ListTile(
                leading: Icon(Icons.add_to_photos, size: 40),
                title: Text('Add conference', textScaleFactor: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _conferencePressed(int index, String language) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpectatorWidget(
              widget._fireStore,
              widget._storage,
              widget._speechProvider,
              index,
              language,
              widget.translator),
        ));
  }

  void _createConferencePressed() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CreateConferencePage(
                widget._fireStore,
                widget._storage,
                widget._speechProvider,
                this.conferences_Size,
                widget.translator)));
  }
}

class CreateConferencePage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  int conference_Size;
  final translator;

  CreateConferencePage(this._fireStore, this._storage, this._speechProvider,
      this.conference_Size, this.translator);

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

  void _createConferencePressed() {
    widget._storage.addConference(
        _name, _language, context.read<FireAuth>().currentUser.uid);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProviderDemoApp(
                widget._fireStore,
                widget._storage,
                widget._speechProvider,
                widget.conference_Size,
                _language,
                widget.translator)));
  }
}