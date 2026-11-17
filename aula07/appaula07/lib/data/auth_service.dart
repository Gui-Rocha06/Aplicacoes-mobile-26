import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Consome o Json Server:
///   json-server db.json --port 3000 --host 0.0.0.0
class AuthService {
  /// Armazena o usuário atualmente autenticado na sessão.
  static Map<String, dynamic>? usuarioAtual;

  static bool get isAutenticado => usuarioAtual != null;
  static bool get isVisitante => usuarioAtual == null;
  static void deslogar() => usuarioAtual = null;

  /// Armazenamento local para permitir testes fluidos mesmo sem servidor ativo
  static final List<Map<String, dynamic>> _usuariosLocais = [
    {
      'id': '1',
      'nome': 'Administrador',
      'email': 'admin@hotel.com',
      'senha': '123',
    },
  ];

  static void _salvarLocal(Map<String, dynamic> usuario) {
    final idx = _usuariosLocais.indexWhere(
      (u) =>
          u['email']?.toString().toLowerCase() ==
          usuario['email']?.toString().toLowerCase(),
    );
    if (idx >= 0) {
      _usuariosLocais[idx] = usuario;
    } else {
      _usuariosLocais.add(usuario);
    }
  }

  // Tenta primeiro 127.0.0.1 (evita falhas de IPv6 no Windows),
  // 10.0.2.2 no Android Emulator, e localhost como alternativa.
  static List<String> get _candidateBases {
    if (kIsWeb) {
      return ['http://localhost:3000', 'http://127.0.0.1:3000'];
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        'http://10.0.2.2:3000',
        'http://127.0.0.1:3000',
        'http://localhost:3000',
      ];
    }
    return [
      'http://127.0.0.1:3000',
      'http://localhost:3000',
    ];
  }

  static const _timeout = Duration(seconds: 3);
  static const _endpoints = ['usuario', 'cadastro-usuario'];

  Future<List<Map<String, dynamic>>?> _buscarNoServidor(
    String baseUrl,
    String ep,
    String email,
  ) async {
    final uri = Uri.parse('$baseUrl/$ep')
        .replace(queryParameters: {'email': email.trim()});
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    }
    return null;
  }

  /// GET /usuario?email=..  (e também em /cadastro-usuario,
  /// com validação da senha em memória para evitar bugs de tipos em query params do json-server v1).
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    final emailNorm = email.trim().toLowerCase();
    final senhaNorm = senha.trim();

    bool conectouServidor = false;

    for (final base in _candidateBases) {
      try {
        for (final ep in _endpoints) {
          final lista = await _buscarNoServidor(base, ep, emailNorm);
          if (lista != null) {
            conectouServidor = true;
            for (final u in lista) {
              final userEmail = u['email']?.toString().trim().toLowerCase();
              final userSenha = u['senha']?.toString().trim();
              if (userEmail == emailNorm && userSenha == senhaNorm) {
                usuarioAtual = u;
                _salvarLocal(u);
                return u;
              }
            }
          }
        }

        // Se comunicou com o servidor mas não encontrou credencial,
        // verifica se é conta salva em modo local:
        final local = _usuariosLocais.where((u) =>
            u['email']?.toString().toLowerCase() == emailNorm &&
            u['senha']?.toString() == senhaNorm).firstOrNull;
        if (local != null) {
          usuarioAtual = local;
          return local;
        }
        return null;
      } catch (_) {
        continue;
      }
    }

    // Se nenhum host respondeu (servidor offline):
    // Fallback para usuário local (ex: admin@hotel.com / 123 ou usuário recém-cadastrado)
    final local = _usuariosLocais.where((u) =>
        u['email']?.toString().toLowerCase() == emailNorm &&
        u['senha']?.toString() == senhaNorm).firstOrNull;
    if (local != null) {
      usuarioAtual = local;
      return local;
    }

    // Se o e-mail existe mas a senha está errada
    final emailExisteLocal = _usuariosLocais.any(
      (u) => u['email']?.toString().toLowerCase() == emailNorm,
    );
    if (emailExisteLocal) {
      return null;
    }

    // Se não conectou e nem existe localmente
    if (!conectouServidor) {
      throw Exception('Não foi possível conectar ao servidor.');
    }

    return null;
  }

  Future<bool> emailExiste(String email) async {
    final emailNorm = email.trim().toLowerCase();
    for (final base in _candidateBases) {
      try {
        for (final ep in _endpoints) {
          final lista = await _buscarNoServidor(base, ep, emailNorm);
          if (lista != null && lista.isNotEmpty) {
            return true;
          }
        }
        break;
      } catch (_) {
        continue;
      }
    }
    return _usuariosLocais.any(
      (u) => u['email']?.toString().toLowerCase() == emailNorm,
    );
  }

  /// POST /cadastro-usuario
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNorm = email.trim().toLowerCase();
    final senhaNorm = senha.trim();

    if (await emailExiste(emailNorm)) {
      throw Exception('Este e-mail já está cadastrado');
    }

    final novoUsuario = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'nome': nome.trim(),
      'email': emailNorm,
      'senha': senhaNorm,
    };

    for (final base in _candidateBases) {
      try {
        final res = await http
            .post(
              Uri.parse('$base/cadastro-usuario'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(novoUsuario),
            )
            .timeout(_timeout);
        if (res.statusCode == 201 || res.statusCode == 200) {
          break;
        }
      } catch (_) {
        continue;
      }
    }

    // Sempre salva no cache local para redundância e disponibilidade imediata
    _salvarLocal(novoUsuario);
  }
}
