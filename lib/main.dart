import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:kongplugin/KongpluginHp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool loading = false;
  late AnimationController controller;

  var udpback = {};
  String connecthost = "";

  _toconnect(host) async {
    bool _udpList = await KongpluginHp().connectGayway(host);
    if (_udpList != null) {
      setState(() {
        connecthost = host;
      });
    }
  }

  _getconfig() async {
    var back = await KongpluginHp().getGaywayStatus();
    setState(() {
      udpback = back;
    });
  }

  _getpoint() async {
    setState(() {
      udpback = {};
      loading = true;
    });
    var back = await KongpluginHp().getPoint();
    setState(() {
      udpback = back;
      loading = false;
    });
  }

  _setpoint() async {
    setState(() {
      udpback = {};
    });
    var back = await KongpluginHp().setPointVal("wirtelimit0", "10");
    setState(() {
      udpback = back;
    });
  }

  _restartNow() async {
    try {
      setState(() {
        udpback = {};
      });
      var back = await KongpluginHp().post({
        "op": "device_control",
        "data": {
          "dev": {"power": 1}
        },
      });
      setState(() {
        udpback = back;
      });
    } catch (e) {}
  }

  bool isOpenWifi = false;

  _setConfig() async {
    try {
      setState(() {
        udpback = {};
      });
      var send = {
        "on": isOpenWifi ? 1 : 0,
        "ssid": "wifi_ssid",
        "pwd": "wifi_pwd"
      };

      var back = await KongpluginHp().post({
        "op": "set_config_common",
        "data": {"wifi_sta": send},
      });

      setState(() {
        udpback = back;
      });
    } catch (e) {}
  }

  searhGayway() async {
    setState(() {
      loading = true;
    });
    List? _udpList = await KongpluginHp().searhGayway();
    setState(() {
      loading = false;
    });
    if (_udpList.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
                child: Container(
                    padding: const EdgeInsets.all(15),
                    width: 320,
                    height: 300,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      //设置四周边框
                    ),
                    child: Column(
                      children: [
                        const Text('searchDDS.chooseDevice',
                            style: TextStyle(
                                color: Color.fromRGBO(15, 17, 28, 1),
                                fontSize: 17,
                                height: 2,
                                fontWeight: FontWeight.w700)),
                        Expanded(
                            child: ListView.builder(
                          itemCount: _udpList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return TextButton(
                              onPressed: () async {
                                _toconnect(_udpList[index]['host']);
                                Navigator.pop(context);
                              },
                              child: Text(_udpList[index]['name'] +
                                  "-" +
                                  _udpList[index]['host']),
                            );
                          },
                        ))
                      ],
                    )));
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: loading
              ? [
                  Center(
                    child: CircularProgressIndicator(
                      value: controller.value,
                      semanticsLabel: 'Circular progress indicator',
                    ),
                  )
                ]
              : [
                  Text(
                    'You have connect : ${connecthost}',
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: udpback.keys.toList().length,
                          itemBuilder: ((context, index) => Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${udpback.keys.toList()[index]}"),
                                    Text(
                                        "${udpback[udpback.keys.toList()[index]]}")
                                  ],
                                ),
                              )))),
                  if (connecthost != "")
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                _getconfig();
                              },
                              child: const Text("get config")),
                          TextButton(
                              onPressed: () {
                                _setConfig();
                              },
                              child: const Text("set config")),
                          TextButton(
                              onPressed: () {
                                _getpoint();
                              },
                              child: const Text("get point")),
                          TextButton(
                              onPressed: () {
                                _setpoint();
                              },
                              child: const Text("set point")),
                          TextButton(
                              onPressed: () {
                                _restartNow();
                              },
                              child: const Text("restart"))
                        ],
                      ),
                    )
                ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: FloatingActionButton(
          onPressed: searhGayway,
          tooltip: 'Increment',
          child: const Icon(Icons.search),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
