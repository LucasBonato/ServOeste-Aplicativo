import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthClient authClient;
  final VoidCallback? onTokenRefreshFailed;

  bool _isRefreshing = false;
  final List<({DioException error, ErrorInterceptorHandler handler})>
      _pendingRequests = [];
  final Set<String> _processedRequests =
      {}; // Para evitar processar a mesma requisição múltiplas vezes

  TokenRefreshInterceptor({
    required this.dio,
    required this.authClient,
    this.onTokenRefreshFailed,
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Se for o próprio endpoint de refresh, não tenta refresh novamente
    if (err.requestOptions.path == ServerEndpoints.refreshEndpoint) {
      debugPrint('❌ Refresh endpoint falhou, não tentar novamente');
      return handler.next(err);
    }

    // Só processa erros 401/403
    if (err.response?.statusCode != 401 && err.response?.statusCode != 403) {
      return handler.next(err);
    }

    // Cria um ID único para esta requisição
    final requestId =
        '${err.requestOptions.method}:${err.requestOptions.path}:${DateTime.now().millisecondsSinceEpoch}';

    // Se já processamos esta requisição, ignora
    if (_processedRequests.contains(requestId)) {
      debugPrint('⚠️ Requisição $requestId já processada, ignorando');
      return handler.next(err);
    }

    _processedRequests.add(requestId);

    debugPrint(
        '🔐 Erro ${err.response?.statusCode} em ${err.requestOptions.path}');
    debugPrint('📌 Request ID: $requestId');

    // Se já está fazendo refresh, adiciona à fila de espera
    if (_isRefreshing) {
      debugPrint('⏳ Refresh em andamento, adicionando à fila...');
      _pendingRequests.add((error: err, handler: handler));
      return; // NÃO chama handler.next() aqui!
    }

    // Inicia o processo de refresh
    _isRefreshing = true;
    debugPrint('🔄 Iniciando refresh token...');

    try {
      // Tenta fazer refresh
      final refreshResult = await authClient.refreshToken();

      if (refreshResult.isRight()) {
        final newTokens =
            refreshResult.getOrElse(() => throw Exception('Missing token'));
        await SecureStorageService.saveTokens(
            newTokens.accessToken, newTokens.refreshToken);

        debugPrint('✅ Token refresh bem-sucedido');

        // Processa a requisição original que falhou
        await _retryRequest(err, handler);

        // Processa todas as requisições pendentes na fila
        for (final pending in _pendingRequests) {
          debugPrint(
              '↩️ Retentando requisição pendente: ${pending.error.requestOptions.path}');
          await _retryRequest(pending.error, pending.handler);
        }

        // Limpa tudo
        _pendingRequests.clear();
        _processedRequests.clear();
        _isRefreshing = false;

        return; // IMPORTANTE: já processamos, não chama handler.next()
      } else {
        debugPrint('❌ Refresh falhou (isRight false)');
        await _handleRefreshFailed(handler, err);
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exceção durante refresh: $e');
      debugPrint('Stack trace: $stackTrace');
      await _handleRefreshFailed(handler, err);
    } finally {
      if (_isRefreshing) {
        _isRefreshing = false;
      }
    }
  }

  Future<void> _retryRequest(
      DioException err, ErrorInterceptorHandler handler) async {
    try {
      // Pega o NOVO token do storage
      final newAccessToken = await SecureStorageService.getAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('⚠️ Novo token é nulo ou vazio após refresh');
        throw Exception('Token inválido após refresh');
      }

      debugPrint('🔑 Usando novo token: ${newAccessToken.substring(0, 30)}...');

      // Atualiza os headers da requisição original
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';

      // Faz uma CÓPIA das options para evitar problemas
      final requestOptions = Options(
        method: options.method,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        extra: options.extra,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType,
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        requestEncoder: options.requestEncoder,
        responseDecoder: options.responseDecoder,
        listFormat: options.listFormat,
      );

      // Executa a requisição novamente
      final response = await dio.request(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: requestOptions,
      );

      debugPrint('✅ Retry bem-sucedido: ${response.statusCode}');
      handler.resolve(response);
    } catch (e, stackTrace) {
      debugPrint('❌ Falha no retry: $e');
      debugPrint('Stack trace: $stackTrace');

      // Se falhar novamente, propaga o erro original
      handler.next(err);
    }
  }

  Future<void> _handleRefreshFailed(
      ErrorInterceptorHandler handler, DioException err) async {
    debugPrint('🚫 Refresh falhou completamente, limpando tokens...');

    _isRefreshing = false;
    _pendingRequests.clear();
    _processedRequests.clear();

    await SecureStorageService.deleteTokens();
    onTokenRefreshFailed?.call();

    // Rejeita todas as requisições pendentes
    for (final pending in _pendingRequests) {
      pending.handler.next(pending.error);
    }
    _pendingRequests.clear();

    // Propaga o erro original
    handler.next(err);
  }
}
