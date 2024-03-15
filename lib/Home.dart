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
  Map<String, dynamic> _ultimoRemovido = {};

  final TextEditingController _controllerTarefa = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lerArquivo();
  }

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  Future<void> _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      if (await arquivo.exists()) {
        final dados = await arquivo.readAsString();
        if (dados.isNotEmpty) {
          setState(() {
            _listaTarefas = json.decode(dados).cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (e) {
      print("Erro ao ler arquivo: $e");
    }
  }

  Future<void> _salvarArquivo() async {
    try {
      final arquivo = await _getFile();
      final dados = json.encode(_listaTarefas);
      await arquivo.writeAsString(dados);
    } catch (e) {
      print("Erro ao salvar arquivo: $e");
    }
  }

  void _salvarTarefa() {
    final textoDigitado = _controllerTarefa.text.trim();
    if (textoDigitado.isNotEmpty) {
      final novaTarefa = {
        'titulo': textoDigitado,
        'realizada': false,
      };
      setState(() {
        _listaTarefas.add(novaTarefa);
      });
      _salvarArquivo();
      _controllerTarefa.clear();
    }
  }

  Widget _criarItemLista(BuildContext context, int index) {
    final tarefa = _listaTarefas[index];
    return Dismissible(
      key: Key(tarefa['titulo']),
      background: Container(
        color: Colors.green,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          print("direção endStart");
        } else if (direction == DismissDirection.startToEnd) {
          print("direção startToEnd");
        }
        setState(() {
          _ultimoRemovido = _listaTarefas.removeAt(index);
        });
        _salvarArquivo();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            content: const Text("Tarefa Excluída!!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _listaTarefas.insert(index, _ultimoRemovido);
                });
                _salvarArquivo();
              },
            ),
          ),
        );
      },
      child: CheckboxListTile(
        title: Text(tarefa['titulo']),
        value: tarefa['realizada'],
        onChanged: (valorAlterado) {
          setState(() {
            tarefa['realizada'] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
    );
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
                  TextButton(
                    child: Text("Cancelar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text("Salvar"),
                    onPressed: () {
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      body: ListView.builder(
        itemCount: _listaTarefas.length,
        itemBuilder: _criarItemLista,
      ),
    );
  }
}
