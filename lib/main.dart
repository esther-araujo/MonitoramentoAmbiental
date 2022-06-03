// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Monitoramento'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int luz = 0;
  int temperatura = 0;
  int umidade = 0;
  int pressao = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Icon(
          Icons.troubleshoot,
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Card(
                elevation: 20,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Luminosidade',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$luz lm/W'),
                      leading: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.yellow,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Pressão Atmosférica',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$pressao atm'),
                      leading: Icon(
                        Icons.landscape,
                        color: Colors.brown,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Temperatura',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$temperatura °C'),
                      leading: Icon(
                        Icons.thermostat,
                        color: Colors.red,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Umidade',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$umidade %'),
                      leading: Icon(
                        Icons.water_drop,
                        color: Colors.blue[500],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
