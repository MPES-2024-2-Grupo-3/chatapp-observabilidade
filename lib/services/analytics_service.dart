import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  // Screen view events with Portuguese names
  static Future<void> logTelaLogin() async {
    await _analytics.logScreenView(screenName: 'tela_login');
  }

  static Future<void> logTelaInicio() async {
    await _analytics.logScreenView(screenName: 'tela_inicio');
  }

  static Future<void> logTelaConfiguracoes() async {
    await _analytics.logScreenView(screenName: 'tela_configuracoes');
  }

  static Future<void> logTelaChat() async {
    await _analytics.logScreenView(screenName: 'tela_chat');
  }

  static Future<void> logTelaUsuarios() async {
    await _analytics.logScreenView(screenName: 'tela_usuarios');
  }

  // Custom events with Portuguese names
  static Future<void> logLogin(String metodo) async {
    await _analytics.logLogin(loginMethod: metodo);
  }

  // Login attempt tracking events
  static Future<void> logTentativaLogin(String metodo) async {
    await _analytics.logEvent(
      name: 'tentativa_login',
      parameters: {
        'metodo': metodo,
        'data_hora': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logLoginSucesso(String metodo, String userId) async {
    await _analytics.logEvent(
      name: 'login_sucesso',
      parameters: {
        'metodo': metodo,
        'user_id': userId,
        'data_hora': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logLoginFalha(String metodo, String erro) async {
    await _analytics.logEvent(
      name: 'login_falha',
      parameters: {
        'metodo': metodo,
        'erro': erro,
        'data_hora': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSair() async {
    await _analytics.logEvent(
      name: 'sair_aplicativo',
      parameters: {'data_hora': DateTime.now().toIso8601String()},
    );
  }

  static Future<void> logEnviarMensagem() async {
    await _analytics.logEvent(
      name: 'enviar_mensagem',
      parameters: {'data_hora': DateTime.now().toIso8601String()},
    );
  }

  static Future<void> logTestarCrashlytics() async {
    await _analytics.logEvent(
      name: 'testar_crashlytics',
      parameters: {'data_hora': DateTime.now().toIso8601String()},
    );
  }

  // Set user properties
  static Future<void> setUsuarioId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  static Future<void> setPropriedadeUsuario(String nome, String valor) async {
    await _analytics.setUserProperty(name: nome, value: valor);
  }
}
