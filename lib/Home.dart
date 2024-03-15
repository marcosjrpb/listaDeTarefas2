import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _listaTarefas = [];

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
        List<dynamic> listaJson = json.decode(dados);
        setState(() {
          _listaTarefas = listaJson.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Erro ao ler arquivo: $e");
    }
  }

  _salvarArquivo() async {
    try {
      await _lerArquivo(); // Ler dados do arquivo antes de adicionar nova tarefa
      var arquivo = await _getFile();

      // Criar dados da nova tarefa
      Map<String, dynamic> tarefa = {
        'titulo': "Ir ao Shopping",
        'realizada': false,
      };

      _listaTarefas.add(tarefa); // Adicionar nova tarefa à lista

      String dados = json.encode(_listaTarefas); // Converter lista para JSON
      await arquivo.writeAsString(dados); // Escrever dados atualizados no arquivo
    } catch (e) {
      print("Erro ao salvar arquivo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _salvarArquivo();
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
                  decoration: InputDecoration(labelText: "Digite sua tarefa"),
                ),
                actions: [
                  FloatingActionButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context)),
                  FloatingActionButton(
                      child: Text("Salva"),
                      onPressed: () {
                        // Adicionar aqui a lógica para salvar a nova tarefa
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
              itemCount: _listaTarefas.length > 10 ? 10 : _listaTarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_listaTarefas[index]['titulo']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


