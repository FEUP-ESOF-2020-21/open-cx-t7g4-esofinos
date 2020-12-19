import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:translator/src/langs/language.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:typed_data';
import 'package:date_format/date_format.dart';

part 'core/database/firebase.dart';
part 'core/database/fireauth.dart';
part 'core/database/authexceptionhandler.dart';
part 'core/services/language-converter.dart';
part 'ui/widgets/custom-header-curved-container.dart';
part 'ui/widgets/custom-picture.dart';
part 'ui/widgets/custom-app-bar.dart';
part 'ui/pages/user/user-login.dart';
part 'ui/pages/user/user-profile.dart';
part 'ui/pages/user/user-signup.dart';
part 'ui/pages/conference/conference-create.dart';
part 'ui/pages/main-page.dart';
part 'core/speechtotext/speechtotext.dart';

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
  final FireStorage storage = FireStorage();
  final translator = GoogleTranslator();
  final SpeechToTextProvider speechProvider =
      SpeechToTextProvider(SpeechToText());

  Future<void> initSpeechState() async {
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
        home: LoginPage(storage, speechProvider, translator),
      ),
    );
  }
}
