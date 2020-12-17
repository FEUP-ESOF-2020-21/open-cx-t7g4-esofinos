part of '../../main.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;

  AppBarWidget(this._storage, this._speechProvider, this.translator)
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
                      this._storage, this._speechProvider, this.translator),
                ));
          },
          child: Padding(padding: EdgeInsets.only(right: 10),
          child:CircleAvatar(
            backgroundImage: NetworkImage(context
                    .watch<FireAuth>()
                    .currentUser
                    ?.photoURL ??
                "https://eu.ui-avatars.com/api/?name="+context
                    .watch<FireAuth>()
                    .currentUser.displayName),
            radius: 25,
            
          ),
        ),
        ),
      ],
      elevation: 50.0,
    );
  }

  @override
  final Size preferredSize; // default is 56.0
}
