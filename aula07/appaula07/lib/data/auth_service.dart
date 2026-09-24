import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Substitua o IP pelo IP da sua máquina rodando o json-server
  static const String baseUrl = "http://192.168.x.x:3000"; 

  // 1. Função de Cadastro (POST em /cadastro-usuario)
  Future<bool> cadastrarUsuario(String nome, String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cadastro-usuario'), // Endpoint exigido
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "email": email,
        "senha": senha, // Em um app real, nunca envie senhas em texto puro
      }),
    );

    if (response.statusCode == 201) {
      return true; // Cadastro realizado com sucesso
    } else {
      return false; // Erro no cadastro
    }
  }

  // 2. Função de Login (Consumo em /usuario)
  Future<bool> fazerLogin(String email, String senha) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario'), // Endpoint exigido
    );

    if (response.statusCode == 200) {
      List<dynamic> usuarios = jsonDecode(response.body);
      
      // Procura se existe algum usuário com o email e senha fornecidos
      bool autenticado = usuarios.any((user) => 
          user['email'] == email && user['senha'] == senha);
          
      return autenticado;
    } else {
      throw Exception('Falha ao conectar com o servidor JSON');
    }
  }
}