import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:io';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

void main() {
  runApp(const MyApp());
}

var pongCount = 0; // Pong counter
String luz = '0';
String temperatura = '0';
String umidade = '0';
String pressao = '0';
String topicT = "medida/temperatura";
String topicU = "medida/umidade";
String topicP = "medida/pressaoAtm";
String topicL = "medida/luminosidade";
String broker = "10.0.0.101";

final client = MqttServerClient(broker, '');

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoramento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Monitoramento'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController page = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: page,
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
            ),
            title: Column(
              children: [
                ConstrainedBox(
                    constraints: const BoxConstraints(
                  maxHeight: 150,
                  maxWidth: 150,
                )),
                const Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
            ),
            items: [
              SideMenuItem(
                priority: 0,
                title: 'Sensores',
                onTap: () {
                  page.jumpToPage(0);
                },
                icon: const Icon(Icons.sensors),
              ),
              SideMenuItem(
                priority: 1,
                title: 'Histórico',
                onTap: () {
                  page.jumpToPage(1);
                },
                icon: const Icon(Icons.history),
              ),
              SideMenuItem(
                priority: 4,
                title: 'Configurações',
                onTap: () {
                  page.jumpToPage(4);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: page,
              children: [
                Container(
                  color: Colors.white,
                  child: _buildSensors(),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Histórico',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: _buildConfig(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensors() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Luminosidade',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('$luz i'),
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
    );
  }

  Widget _buildConfig() {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                MyCustomForm(),
                ElevatedButton(
                  onPressed: _connect,
                  child: const Text('Conectar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _connect() async {
    client.logging(on: false);

    client.setProtocolV311();

    client.keepAlivePeriod = 20;

    client.onDisconnected = onDisconnected;

    client.onConnected = onConnected;

    client.onSubscribed = onSubscribed;

    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    String username="aluno";
    String password="aluno*123";

    try {
      await client.connect(username, password);
    } catch (e) {
      print(e);
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }

    //o # indica que a inscrição ocorre para todos os topicos dentro de medida/
    const topic = 'medida/#';
    // inscrição
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;

      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //identificando para qual tópico veio a mensagem para setar os valores na tela
      setState(() {
        if (c[0].topic == topicT)
          temperatura = pt;
        else if (c[0].topic == topicP)
          pressao = pt;
        else if (c[0].topic == topicU)
          umidade = pt;
        else
          luz = pt;
      });
      //print(pt);
    });
  }

  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
    if (pongCount == 3) {
      print('EXAMPLE:: Pong count is correct');
    } else {
      print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }
}

class MyCustomForm extends StatelessWidget {
  const MyCustomForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Host',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Usuário',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Senha',
            ),
          ),
        ),
      ],
    );
  }
}
