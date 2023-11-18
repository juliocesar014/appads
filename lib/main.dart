// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API - Usuários',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String apiStatus = '';
  List<Map<String, dynamic>> _userList = [];

  Future<void> _verificarAPI() async {
    final response =
        await http.get(Uri.parse('https://auth-api-user.onrender.com/health'));

    if (response.statusCode == 200) {
      setState(() {
        apiStatus = 'API está online:\n${response.body}';
      });
    } else {
      setState(() {
        apiStatus =
            'Erro ao verificar API. Código de status: ${response.statusCode}';
      });
    }
  }

  Future<void> _listarUsuarios() async {
    final response =
        await http.get(Uri.parse('https://auth-api-user.onrender.com/users'));

    if (response.statusCode == 200) {
      setState(() {
        _userList = List<Map<String, dynamic>>.from(json.decode(response.body));
      });

      _mostrarModalListaUsuarios();
    } else {
      setState(() {
        _userList = [];
        apiStatus =
            'Erro ao obter lista de usuários. Código de status: ${response.statusCode}';
      });
    }
  }

  void _mostrarModalListaUsuarios() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lista de Usuários'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _userList.length,
              itemBuilder: (context, index) {
                var user = _userList[index];
                return ListTile(
                  title: Text('ID: ${user['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nome: ${user['name']}'),
                      Text('Email: ${user['email']}'),
                      Text('Password: ${user['password']}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _mostrarModalDeletarUsuario(user['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Deletar'),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _mostrarModalEditarUsuario(user['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Editar'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalCriarUsuario() {
    String nome = '';
    String email = '';
    String senha = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Usuário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  nome = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Senha'),
                onChanged: (value) {
                  senha = value;
                },
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _criarUsuario(nome, email, senha);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _criarUsuario(String nome, String email, String senha) async {
    final response = await http.post(
      Uri.parse('https://auth-api-user.onrender.com/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': nome,
        'email': email,
        'password': senha,
      }),
    );

    if (response.statusCode == 200) {
      _mostrarModalCadastroSucesso();
    } else {
      setState(() {
        apiStatus =
            'Erro ao criar usuário. Código de status: ${response.statusCode}';
      });
    }
  }

  void _mostrarModalCadastroSucesso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Usuário cadastrado com sucesso!'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalDeletarUsuario(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletar Usuário'),
          content: const Text('Tem certeza que deseja deletar este usuário?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletarUsuario(userId);
              },
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletarUsuario(int userId) async {
    final response = await http.delete(
      Uri.parse('https://auth-api-user.onrender.com/users/$userId'),
    );

    if (response.statusCode == 200) {
      _mostrarModalDeletarSucesso();
    } else {
      setState(() {
        apiStatus =
            'Erro ao deletar usuário. Código de status: ${response.statusCode}';
      });
    }
  }

  void _mostrarModalDeletarSucesso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Usuário deletado com sucesso!'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalEditarUsuario(int userId) {
    var user = _userList.firstWhere((user) => user['id'] == userId);
    String editNome = user['name'];
    String editEmail = user['email'];
    String editSenha = user['password'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Usuário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                controller: TextEditingController(text: editNome),
                onChanged: (value) {
                  editNome = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: TextEditingController(text: editEmail),
                onChanged: (value) {
                  editEmail = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Senha'),
                controller: TextEditingController(text: editSenha),
                onChanged: (value) {
                  editSenha = value;
                },
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _editarUsuario(userId, editNome, editEmail, editSenha);
              },
              child: const Text('Editar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarUsuario(
      int userId, String nome, String email, String senha) async {
    final response = await http.put(
      Uri.parse('https://auth-api-user.onrender.com/users/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': nome,
        'email': email,
        'password': senha,
      }),
    );

    if (response.statusCode == 200) {
      _mostrarModalEditarSucesso();
    } else {
      setState(() {
        apiStatus =
            'Erro ao editar usuário. Código de status: ${response.statusCode}';
      });
    }
  }

  void _mostrarModalEditarSucesso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Usuário editado com sucesso!'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalLogin() {
    String email = '';
    String senha = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Senha'),
                onChanged: (value) {
                  senha = value;
                },
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _loginUsuario(email, senha);
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginUsuario(String email, String senha) async {
    final response = await http.post(
      Uri.parse('https://auth-api-user.onrender.com/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': senha,
      }),
    );

    if (response.statusCode == 200) {
      _mostrarModalLoginSucesso(email);
    } else if (response.statusCode == 401) {
      _mostrarModalSenhaInvalida();
    } else {
      setState(() {
        apiStatus =
            'Erro ao fazer login. Código de status: ${response.statusCode}';
      });
    }
  }

  void _mostrarModalLoginSucesso(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text('Usuário autenticado com sucesso!\nEmail: $email'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalSenhaInvalida() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro de Autenticação'),
          content: const Text('Senha inválida. Tente novamente.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuários - API'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _verificarAPI,
              child: const Text('Verificar API'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _listarUsuarios,
              child: const Text('Listar Usuários'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _mostrarModalCriarUsuario,
              child: const Text('Adicionar Usuário'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _mostrarModalLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Text(
              apiStatus,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
