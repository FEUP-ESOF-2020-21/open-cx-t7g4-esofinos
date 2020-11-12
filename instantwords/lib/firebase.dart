part of 'main.dart';

class FireStore {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
}

class FireStorage {
  final storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    TaskSnapshot task = await storage.ref().child(path).putFile(file);

    return task.ref.getDownloadURL();
  }

  uploadImage(profileImgPath) async {
    final _picker = ImagePicker();
    PickedFile image;

    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null) {
        var downloadURL = await uploadFile(profileImgPath, file);

        print(downloadURL);
      } else {
        print('No path Received');
      }
    } else {
      print('Grant permission and try again!');
    }
  }

  updateConference(document, newValues) {
    FirebaseFirestore.instance
        .collection('conferences')
        .doc(document)
        .update(newValues)
        .catchError((error) {
      print(error);
    });

  addConference(conferenceName, language) {
    FirebaseFirestore.instance
        .collection('conferences')
        .doc(conferenceName)
        .set({'language': language, 'text': ""})
        .then((value) => print("Conferemce Added"))
        .catchError((error) => print("Failed to add conference: $error"));
  }

  Future<List<QueryDocumentSnapshot>> getConferences() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("conferences").get();
    return snapshot.docs;
  }
}

class FireAuth {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  User get currentUser => auth.currentUser;

  Stream<User> get authStateChanges => auth.authStateChanges();

  Future<void> register(
      {String email,
      String password,
      String displayName,
      String photoURL}) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => value.user
              .updateProfile(displayName: displayName, photoURL: photoURL));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
  }

  Future<void> loginAccount({String email, String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
