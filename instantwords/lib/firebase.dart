part of 'main.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
  weakPassword
}

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
  }

  addConference(conferenceName, language, uid) {
    FirebaseFirestore.instance
        .collection('conferences')
        .doc(conferenceName)
        .set({'language': language, 'text': "", 'owner': uid})
        .then((value) => print("Conference Added"))
        .catchError((error) => print("Failed to add conference: $error"));
  }

  addVisitor(conferenceName, uid) {
    FirebaseFirestore.instance
        .collection('conferences')
        .doc(conferenceName)
        .update({
          'visitors': FieldValue.arrayUnion([uid])
        })
        .then((value) => print("Conference Added"))
        .catchError((error) => print("Failed to add conference: $error"));
  }

  Future<List<QueryDocumentSnapshot>> getConferences() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("conferences").get();
    return snapshot.docs;
  }

  Future<int> getConferenceByID(String id) async {
    List<QueryDocumentSnapshot> conferences = await getConferences();

    for (int i = 0; i < conferences.length; i++) {
      if (conferences[i].id.toString() == id) return i;
    }
    return -1;
  }

  Future<List<QueryDocumentSnapshot>> getNonOwnedConferences(
      String owner) async {
    QuerySnapshot snapshotLess = await FirebaseFirestore.instance
        .collection("conferences")
        .where('owner', isLessThan: owner)
        .get();
    QuerySnapshot snapshotGreat = await FirebaseFirestore.instance
        .collection("conferences")
        .where('owner', isGreaterThan: owner)
        .get();
    
    List<QueryDocumentSnapshot> snapshot = [...snapshotLess.docs, ...snapshotGreat.docs].toSet().toList();
    return snapshot;
  }

  Future<List<QueryDocumentSnapshot>> getOwnerConferences(String owner) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("conferences")
        .where('owner', isEqualTo: owner)
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getAttendeeConferences(
      String attendee) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("conferences")
        .where('visitors', arrayContains: attendee)
        .get();
    return snapshot.docs;
  }
}

class FireAuth {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  AuthResultStatus status;

  User get currentUser => auth.currentUser;

  Stream<User> get authStateChanges => auth.authStateChanges();

  Future<AuthResultStatus> register(
      {String email,
      String password,
      String displayName,
      String photoURL}) async {
    try {
      UserCredential authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      //.then((value) => value.user
      //.updateProfile(displayName: displayName, photoURL: photoURL));
      if (authResult.user != null) {
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
    } catch (e) {
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<AuthResultStatus> loginAccount({String email, String password}) async {
    try {
      final authResult = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
    } catch (e) {
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}

class AuthExceptionHandler {
  static handleException(e) {
    var status;
    switch (e.code) {
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "ERROR_USER_DISABLED":
        status = AuthResultStatus.userDisabled;
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "email-already-in-use":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      case "weak-password":
        status = AuthResultStatus.weakPassword;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  ///
  /// Accepts AuthExceptionHandler.errorType
  ///
  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your password is wrong.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage =
            "The email has already been registered. Please login or reset your password.";
        break;
      case AuthResultStatus.weakPassword:
        errorMessage = "Password should be at least 6 characters.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }

    return errorMessage;
  }
}
