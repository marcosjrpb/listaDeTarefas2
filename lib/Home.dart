import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _listaTarefas = [];
  TextEditingController _controllerTarefa = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lerArquivo(); // Chamar a função de leitura ao iniciar o widget
  }

  _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _lerArquivo() async {
    try {
      var arquivo = await _getFile();
      if (await arquivo.exists()) {
        String dados = await arquivo.readAsString();
        if (dados.isNotEmpty) {
          List<dynamic> listaJson = json.decode(dados);
          setState(() {
            _listaTarefas = listaJson.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (e) {
      print("Erro ao ler arquivo: $e");
    }
  }

  _salvarTarefa() async {
    String textoDigitado = _controllerTarefa.text;

    // Criar dados da nova tarefa
    Map<String, dynamic> tarefa = {
      'titulo': textoDigitado,
      'realizada': false,
    };

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text = "";// Chamar o método para salvar o arquivo após adicionar uma nova tarefa
  }

  _salvarArquivo() async {
    try {
      var arquivo = await _getFile();
      String dados = json.encode(_listaTarefas); // Converter lista para JSON
      await arquivo.writeAsString(dados); // Escrever dados atualizados no arquivo
    } catch (e) {
      print("Erro ao salvar arquivo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration: InputDecoration(labelText: "Digite sua tarefa"),
                ),
                actions: [
                  FloatingActionButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context)),
                  FloatingActionButton(
                      child: Text("Salva"),
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      }),
                ],
              );
            },
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_listaTarefas[index]['titulo']),
                  value: _listaTarefas[index]['realizada'],
                  onChanged: (valorAlterado) {
                    setState(() {
                      _listaTarefas[index]['realizada'] = valorAlterado;

                    });
                    _salvarArquivo();
                  },
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}
