part of 'main.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  AppBarWidget(this._fireStore, this._storage, this._speechProvider,this.translator)
      : preferredSize = Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('InstantWords'),
      actions: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                      this._fireStore, this._storage, this._speechProvider, this.translator),
                ));
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(context
                    .watch<FireAuth>()
                    .currentUser
                    ?.photoURL ??
                "https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
            radius: 50,
          ),
        ),
      ],
      elevation: 50.0,
    );
  }

  @override
  final Size preferredSize; // default is 56.0
}


class Picture extends StatelessWidget {

final Uint8List _imageBytes;
  Picture(this._imageBytes);

  @override
  Widget build(BuildContext context) {
    var title = 'QR Code';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Image.memory(this._imageBytes),
      ),
    );
  }
}
