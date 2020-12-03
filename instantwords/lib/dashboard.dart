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
  TextEditingController _searchController = TextEditingController();

  Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  final _languageList = LanguageList();

  int conferencesSize;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    searchResultsList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() async {
    if (_allResults.isEmpty) {
      _allResults = await widget._storage
          .getNonOwnedConferences(context.read<FireAuth>().currentUser.uid);
    }

    var showResults = [];

    if (_searchController.text != "") {
      var text = _searchController.text.toLowerCase();
      for (var confSnapshot in _allResults) {
        var languageID = confSnapshot['language'].toString().toLowerCase();
        var languageName =
            _languageList[languageID.split('_')[0]].toString().toLowerCase();
        var id = confSnapshot.id.toLowerCase();

        if (languageID.contains(text) ||
            languageName.contains(text) ||
            id.contains(text)) {
          showResults.add(confSnapshot);
        }
      }
    } else {
      showResults = _allResults;
    }
    setState(() {
      _resultsList = showResults;
    });
  }

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
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                "Search Conference",
                textScaleFactor: 2,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: "Language or Conference Name"),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _resultsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return new RaisedButton(
                    onPressed: () => _conferencePressed(
                        index,
                        _resultsList[index].id.toString(),
                        _resultsList[index]['language']),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: new ListTile(
                            leading: Icon(Icons.analytics, size: 50),
                            title: Text(_resultsList[index].id.toString(),
                                textScaleFactor: 2),
                            subtitle: Text(_resultsList[index]['language'],
                                textScaleFactor: 1.2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            //_buildConferenceBlocks(),
          ],
        ),
      ),
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
        future: widget._storage
            .getNonOwnedConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          conferencesSize = content.length;
          return new ListView.builder(
            itemCount: conferencesSize,
            itemBuilder: (BuildContext context, int index) {
              return new RaisedButton(
                onPressed: () => _conferencePressed(index,
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

  void _conferencePressed(int index, String name, String language) {
    widget._storage.addVisitor(name, context.read<FireAuth>().currentUser.uid);
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateConferencePage(
                widget._fireStore,
                widget._storage,
                widget._speechProvider,
                this.conferencesSize,
                widget.translator)));
  }
}

class CreateConferencePage extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  int conferenceSize;
  final translator;

  CreateConferencePage(this._fireStore, this._storage, this._speechProvider,
      this.conferenceSize, this.translator);

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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProviderDemoApp(
                widget._fireStore,
                widget._storage,
                widget._speechProvider,
                widget.conferenceSize,
                _language,
                widget.translator)));
  }
}
