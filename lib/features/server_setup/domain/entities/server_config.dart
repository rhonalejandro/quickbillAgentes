import 'package:equatable/equatable.dart';

import '../../../../core/constants/agent_security.dart';

class ServerConfig extends Equatable {
  const ServerConfig({
    required this.host,
    this.headerName,
    this.headerValue,
    this.userAgent,
  });

  final String host;
  final String? headerName;
  final String? headerValue;
  final String? userAgent;

  String get agentUrl => 'https://$host/agente-venta/login';

  String get effectiveHeaderName =>
      (headerName?.trim().isNotEmpty ?? false) ? headerName! : AgentSecurity.defaultHeaderName;

  String get effectiveHeaderValue =>
      (headerValue?.trim().isNotEmpty ?? false) ? headerValue! : AgentSecurity.defaultHeaderValue;

  String get effectiveUserAgent =>
      (userAgent?.trim().isNotEmpty ?? false) ? userAgent! : AgentSecurity.defaultUserAgent;

  @override
  List<Object?> get props => [host, headerName, headerValue, userAgent];
}
