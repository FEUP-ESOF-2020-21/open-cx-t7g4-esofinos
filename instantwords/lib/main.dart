import 'dart:async';
import 'dart:collection';
//import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:translator/translator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

part 'firebase.dart';
part 'widgets.dart';
part 'speechtotext.dart';
part 'login.dart';
part 'dashboard.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(color: Colors.red),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return InstantWordsApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container(
          decoration: BoxDecoration(color: Colors.deepPurple),
        );
      },
    );
  }
}

class InstantWordsApp extends StatelessWidget {
  final FireStore firestore = FireStore();
  final FireStorage storage = FireStorage();
  final translator = GoogleTranslator();
  final SpeechToTextProvider speechProvider =
      SpeechToTextProvider(SpeechToText());

  Future<void> initSpeechState() async {
    print("Initializing speechProvider!");
    await speechProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    initSpeechState();
    return MultiProvider(
      providers: [
        Provider<FireAuth>(
          create: (context) => FireAuth(),
        ),
        StreamProvider(
          create: (context) => context.read<FireAuth>().authStateChanges,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'InstantWords Login',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginPage(firestore, storage, speechProvider, translator),
      ),
    );
  }
}
