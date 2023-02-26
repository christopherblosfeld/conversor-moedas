import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=6e8d619d';

// Para retornar somente a moeda Dólar > print(json.decode(response.body)["results"]["currencies"]["USD"]); Colocar diretamente no corpo do response.body
//print(await getData()); PRINTAR OS DADOS DA API

void main() async {
  runApp(MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          ))));
}

Future<Map> getData() async {
  final response = await http.get(Uri.parse(request));
  return jsonDecode(response.body);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  late double dolar;
  late double euro;
  late double btc;

  //Abaixo as funções que irão verificar quando os campos sofreram alteração

  void _realChanged(String text) {
    try {
      double real = double.parse(text);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
      btcController.text = (real / btc).toStringAsFixed(2);
    } catch (e) {
      print(e);
      return;
    }
  }

  void _dolarChanged(String text) {
    try {
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
      btcController.text = (dolar * this.dolar / btc).toStringAsFixed(2);
    } catch (e) {
      print(e);
      return;
    }
  }

  void _euroChanged(String text) {
    try {
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
      btcController.text = (euro * this.euro / btc).toStringAsFixed(2);
    } catch (e) {
      print(e);
      return;
    }
  }

  void _btcChanged(String text) {
    try {
      double btc = double.parse(text);
      realController.text = (btc * this.btc).toStringAsFixed(2);
      dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
      euroController.text = (btc * this.btc / euro).toStringAsFixed(2);
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.amber,
            title: Text('\$ Conversor \$'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _resetFields();
                  });
                },
              )
            ]),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    'Carregando os dados...',
                    style: TextStyle(color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Erro ao carregar dados :(',
                      style: TextStyle(color: Colors.amber),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  btc = snapshot.data!["results"]["currencies"]["BTC"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Icon(Icons.monetization_on,
                              size: 150, color: Colors.amber),
                          const Divider(),
                          buildTextField('Reais', 'R\$', realController,
                              _realChanged), //Passando os parâmetros da função que constrói o Text Field: Label, prefixo, controller e função de cálculo (conversão)
                          const Divider(),
                          buildTextField('Dólares', 'US\$', dolarController,
                              _dolarChanged),
                          const Divider(),
                          buildTextField(
                              'Euros', '€U\$', euroController, _euroChanged),
                          const Divider(),
                          buildTextField(
                              'Bitcoins', 'BTC\$', btcController, _btcChanged),
                        ]),
                  );
                }
            }
          },
        ));
  }

  void _resetFields() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
    btcController.text = '';
  }
}

Widget buildTextField(
    //Construtor de Text Field
    String label,
    String prefix,
    TextEditingController c,
    Function(String) f) {
  //Função criada para receber os parâmetros label prefix e controller dos campos TextField.
  return TextField(
    controller: c,
    onChanged: f,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber, fontSize: 25),
        border: const OutlineInputBorder(),
        prefixText: prefix),
    style: const TextStyle(color: Colors.amber),
  );
}
