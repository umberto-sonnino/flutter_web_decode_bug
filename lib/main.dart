import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _allCodecs = <ui.Codec>[];

  Future<void> _initCodecs() async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifest);
    final paths = manifestMap.keys
        .where((String key) => key.contains('images'))
        .map((String key) => Uri.decodeComponent(key));
    await Future.wait(
      paths.map(
        (e) => rootBundle.load(e).then((loaded) {
          print('Decoding $e');
          return ui.instantiateImageCodec(loaded.buffer.asUint8List());
        }).then(_allCodecs.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _initCodecs,
              child: const Text('Get Codecs'),
            ),
          ],
        ),
      ),
    );
  }
}
