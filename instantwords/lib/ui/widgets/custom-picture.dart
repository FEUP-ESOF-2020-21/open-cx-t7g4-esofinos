part of '../../main.dart';

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
