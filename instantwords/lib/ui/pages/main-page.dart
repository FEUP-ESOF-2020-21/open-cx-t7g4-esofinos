part of '../../main.dart';

class MainPage extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  MainPage(this._storage, this._speechProvider, this.translator);

  @override
  State<MainPage> createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController _searchController = TextEditingController();

  List _allResults = [];
  List _resultsList = [];
  final _languageList = LanguageList();

  int _currentIndex = 0;
  Widget screenWidget;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    updateConferenceList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  updateConferenceList() async {
    _allResults = await widget._storage
        .getNonOwnedConferences(context.read<FireAuth>().currentUser.uid);
    setState(() {
      _currentIndex = 0;
      screenWidget = _buildDashboard();
    });
  }

  updateSceenWidget(newIndex) {
    if (newIndex == 0) {
      _currentIndex = newIndex;
      screenWidget = _buildDashboard();
    } else if (newIndex == 1) {
      _currentIndex = newIndex;
      screenWidget = _buildSearch();
    } else if (newIndex == 2) {
      _scanQR();
    } else {
      _createConferencePressed();
    }
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() async {
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
      updateSceenWidget(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBarWidget(
          widget._storage, widget._speechProvider, widget.translator),
      body: screenWidget,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return new BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(.60),
      selectedFontSize: 14,
      unselectedFontSize: 14,
      key: Key('bottom_bar'),
      onTap: (value) {
        setState(() => {updateSceenWidget(value)});
      },
      items: [
        BottomNavigationBarItem(
          label: 'Dashboard',
          icon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(
          label: 'Search',
          icon: Icon(Icons.search),
        ),
        BottomNavigationBarItem(
          label: 'QR',
          icon: Icon(Icons.qr_code),
        ),
        BottomNavigationBarItem(
          label: 'Create',
          icon: Icon(Icons.create),
        ),
      ],
    );
  }

  void _conferencePressed(String name, String language) async {
    widget._storage.addVisitor(name, context.read<FireAuth>().currentUser.uid);
    int confIndex = await widget._storage.getConferenceByID(name);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpectatorWidget(widget._storage,
              widget._speechProvider, confIndex, language, widget.translator),
        ));
  }

  Widget _buildDashboard() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 15, bottom: 30),
              child: Text("Conferences",
                  textScaleFactor: 2,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
          Expanded(
            child: ListView.builder(
              itemCount: _allResults.length,
              itemBuilder: (BuildContext context, int index) {
                return new Padding(
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(12),
                    color: Colors.white,
                    onPressed: () => _conferencePressed(
                        _allResults[index].id.toString(),
                        _allResults[index]['language']),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Text(_allResults[index].id.toString(),
                              textScaleFactor: 2, style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        Text(formatDate(_allResults[index]['date'].toDate(), [dd, '/', mm, '/', yyyy]),
                              textScaleFactor: 1.2, style: TextStyle(color: Colors.black54),),
                        SizedBox(height: 10.0),
                        Text(_allResults[index]['description'],
                              textScaleFactor: 1.2),
                        SizedBox(height: 4.0),
                        Text(
                            'Language: ' +
                                LanguageConverter.convertLanguage(
                                    _allResults[index]['language']),
                            textScaleFactor: 1.2, style: TextStyle(color: Colors.black54)),
                            SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 15, bottom: 30),
              child: Text("Search For Conferences",
                  textScaleFactor: 2,
                  style: TextStyle(fontWeight: FontWeight.bold))),
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
                          subtitle: Text(
                              LanguageConverter.convertLanguage(
                                  _resultsList[index]['language']),
                              textScaleFactor: 1.2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scanQR() async {
    String indexStr = await scanner.scan();

    if (indexStr == null) return;

    int index = int.parse(indexStr);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpectatorWidget(widget._storage,
              widget._speechProvider, index, "en-US", widget.translator),
        ));
  }

  void _createConferencePressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateConferencePage(
                widget._storage, widget._speechProvider, widget.translator)));
  }
}
