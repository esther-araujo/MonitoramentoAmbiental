import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:io';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

void main() {
  runApp(const MyApp());
}

var pongCount = 0; // Pong counter
var historicoL = [];
var historicoT = [];
var historicoU = [];
var historicoP = [];
int indexHistorico = 0;
String luz = '0';
String temperatura = '0';
String umidade = '0';
String pressao = '0';
String topicT = "medida/temperatura";
String topicU = "medida/umidade";
String topicP = "medida/pressaoAtm";
String topicL = "medida/luminosidade";
String broker = "";
String username = "";
String password = "";
String response = "";

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
      resizeToAvoidBottomInset: false,
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
                  child: _buildHist(),
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

  List<String> dataList = ['1', '2'];

  Widget _buildHist() {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text(dataList[index]));
                  })),
          Expanded(
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text(dataList[index]));
                  })),
          Expanded(
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text(dataList[index]));
                  })),
          Expanded(
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text(dataList[index]));
                  })),
        ],
      ),
    );
  }

  Widget _buildSensors() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                MyCustomForm(),
                Text(response,
                    style: TextStyle(color: Color.fromARGB(255, 1, 77, 4))),
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
        if (c[0].topic == topicT) {
          temperatura = pt;
        } else if (c[0].topic == topicP) {
          pressao = pt;
        } else if (c[0].topic == topicU) {
          umidade = pt;
        } else {
          luz = pt;
        }
      });
      updateHistoric();
      //imprime as listas com historico das medidas para teste
      print(historicoL);
      print(historicoU);
      print(historicoT);
      print(historicoP);
    });
  }

  void onSubscribed(String topic) {
    setState(() {});
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    setState(() {
      response = "Desconectado do broker";
    });
  }

  /// The successful connect callback
  void onConnected() {
    setState(() {
      response = "Conexão com broker ativa";
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }

  void updateHistoric() {
    if (historicoL.length < 10) {
      historicoL.add(luz);
      historicoT.add(temperatura);
      historicoU.add(umidade);
      historicoP.add(pressao);
    } else {
      historicoL[indexHistorico] = luz;
      historicoT[indexHistorico] = temperatura;
      historicoU[indexHistorico] = umidade;
      historicoP[indexHistorico] = pressao;
      indexHistorico++;
      if (indexHistorico == 10) indexHistorico = 0;
    }
  }
}

class MyCustomForm extends StatelessWidget {
  const MyCustomForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Host',
            ),
            onChanged: (newText) {
              broker = newText;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Usuário',
            ),
            onChanged: (newText) {
              username = newText;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Senha',
            ),
            onChanged: (newText) {
              password = newText;
            },
          ),
        ),
      ],
    );
  }
}
