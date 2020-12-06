part of '../../main.dart';

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
        await uploadFile(profileImgPath, file);
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

    List<QueryDocumentSnapshot> snapshot =
        [...snapshotLess.docs, ...snapshotGreat.docs].toSet().toList();
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

