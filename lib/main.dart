import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conversor de moeda',
      theme: ThemeData(
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data;

  double dolar;
  double euro;

  TextEditingController realController = TextEditingController();
  TextEditingController dolarController = TextEditingController();
  TextEditingController euroController = TextEditingController();

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChanged(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(value);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(value);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(value);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Conversor'),
      ),
      body: FutureBuilder(
        future: _getData(),
        builder: (_, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Colors.deepPurpleAccent),
                ),
              );
              break;
            case ConnectionState.done:
              dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 22.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.monetization_on,
                      size: 120,
                      color: Colors.deepPurpleAccent,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _textField(
                      label: "Real",
                      prefix: "R\$ ",
                      controller: realController,
                      onChagend: _realChanged,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _textField(
                      label: "Dolar",
                      prefix: "\$ ",
                      controller: dolarController,
                      onChagend: _dolarChanged,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _textField(
                      label: "Euro",
                      prefix: "€",
                      controller: euroController,
                      onChagend: _euroChanged,
                    ),
                  ],
                ),
              );
              break;
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar os dados :(',
                  ),
                );
              }
              return Container();
          }
        },
      ),
    );
  }
}

Future<Map> _getData() async {
  final response =
      await http.get("https://api.hgbrasil.com/finance?key=c2eb2c59");

  return jsonDecode(response.body);
}

Widget _textField({
  @required String label,
  @required String prefix,
  TextEditingController controller,
  Function onChagend,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(
      fontSize: 16,
    ),
    decoration: InputDecoration(
      labelText: label,
      prefix: Text(
        prefix,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
    ),
    onChanged: onChagend,
  );
}
