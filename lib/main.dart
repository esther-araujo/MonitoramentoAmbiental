import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

var pongCount = 0; // Pong counter
List historicoL = [];
List historicoT = [];
List historicoU = [];
List historicoP = [];
List historicoData = [];
List historicoHora = [];
int indexHistorico = 0;

String luz = '0';
String temperatura = '0';
String umidade = '0';
String pressao = '0';
String topicT = "medida/temperatura";
String topicU = "medida/umidade";
String topicP = "medida/pressaoAtm";
String topicL = "medida/luminosidade";
String configTempo = "config/tempo";
String hist = "historico";
String broker = "";
String username = "";
String password = "";
String response = "";
int _tempoAtual = 20;

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
                priority: 2,
                title: 'Configurações',
                onTap: () {
                  page.jumpToPage(2);
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

  Widget _buildHist() {
    return Scaffold(
      body: Container(
        child: new SingleChildScrollView(
          child: Column(
            children: List.generate(
              historicoL.length,
              (index) {
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          // The header
                          if (index == 0)
                            Container(
                                child: const Text(
                              '   ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            )),
                          ListTile(
                            title: AutoSizeText(
                              historicoData[index],
                              minFontSize: 10,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            subtitle: AutoSizeText(
                              historicoHora[index],
                              minFontSize: 7,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          // The header
                          if (index == 0)
                            Container(
                                child: const Text(
                              'L (i)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                          const Divider(),

                          ListTile(
                            title: AutoSizeText(
                              historicoL[index],
                              minFontSize: 11,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          // The header
                          if (index == 0)
                            Container(
                                child: const Text(
                              'PA (atm)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                          const Divider(),

                          ListTile(
                            title: AutoSizeText(
                              historicoP[index],
                              minFontSize: 11,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          // The header
                          if (index == 0)
                            Container(
                                child: const Text(
                              'T (°C)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                          const Divider(),

                          ListTile(
                            title: AutoSizeText(
                              historicoT[index],
                              minFontSize: 11,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          // The header
                          if (index == 0)
                            Container(
                                child: const Text(
                              'U (%)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                          const Divider(),

                          ListTile(
                            title: AutoSizeText(
                              historicoU[index],
                              minFontSize: 11,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensors() {
    final builder = MqttClientPayloadBuilder();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Intervalo das medições: $_tempoAtual s'),
          NumberPicker(
            value: _tempoAtual,
            minValue: 20,
            maxValue: 100,
            step: 20,
            onChanged: (value) => setState(() {
              _tempoAtual = value;
              if (client.connectionStatus!.state ==
                  MqttConnectionState.connected) {
                builder.clear();
                builder.addString(_tempoAtual.toString());
                client.publishMessage(
                    configTempo, MqttQos.exactlyOnce, builder.payload!);
              }
            }),
          ),
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
      debugShowCheckedModeBanner: false,
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

  void _updateTempo() async {}

  void _connect() async {
    client.logging(on: false);

    client.setProtocolV311();

    client.keepAlivePeriod = 20;

    client.onDisconnected = onDisconnected;

    client.onConnected = onConnected;

    client.onSubscribed = onSubscribed;

    client.pongCallback = pong;
    var rnd = new Random();
    var clientId = rnd.nextInt(200);
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId.toString())
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
    List historico_array;
    List historico_data;
    // inscrição
    client.subscribe(topic, MqttQos.atMostOnce);
    client.subscribe(configTempo, MqttQos.atMostOnce);
    client.subscribe(hist, MqttQos.atMostOnce);

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
        } else if (c[0].topic == topicL) {
          luz = pt;
        } else if (c[0].topic == configTempo) {
          _tempoAtual = int.parse(pt);
        } else {
          historico_array = pt.split(';');
          historicoT.clear();
          historicoL.clear();
          historicoU.clear();
          historicoP.clear();
          historicoData.clear();
          historicoHora.clear();
          for (var i = 0; i < historico_array.length; i++) {
            if (historico_array[i] != "") {
              historico_data = historico_array[i].split('|');
              historicoT.add(historico_data[0]);
              historicoL.add(historico_data[1]);
              historicoU.add(historico_data[2]);
              historicoP.add(historico_data[3]);
              historicoData.add(historico_data[4]);
              historicoHora.add(historico_data[5]);
            }
          }
        }
      });
    });
  }

  void onSubscribed(String topic) {
    setState(() {});
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    setState(() {
      response = "Erro de conexão";
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
