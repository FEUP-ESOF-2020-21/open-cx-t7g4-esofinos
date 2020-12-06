part of '../../main.dart';

class AccountPage extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  final bool needPop = false;

  AccountPage(this._storage, this._speechProvider, this.translator);
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
              Text("Your Conferences:", textScaleFactor: 2),
              _buildCreatedConferenceBlocks(),
              Text("Conferences you attended:", textScaleFactor: 2),
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
                await scanner.scan();
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
        future: widget._storage
            .getOwnerConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          return new ListView.builder(
            itemCount: content.length,
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
        future: widget._storage
            .getAttendeeConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          return new ListView.builder(
            itemCount: content.length,
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
                widget._storage,
                widget._speechProvider,
                confIndex,
                language,
                widget.translator)));
  }
}
