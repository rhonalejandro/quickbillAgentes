import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AgentViewerStatus { loading, loaded, error }

class AgentViewerState {
  const AgentViewerState({
    this.status = AgentViewerStatus.loading,
    this.httpErrorCode,
  });

  final AgentViewerStatus status;
  final int? httpErrorCode;

  AgentViewerState copyWith({AgentViewerStatus? status, int? httpErrorCode}) {
    return AgentViewerState(
      status: status ?? this.status,
      httpErrorCode: httpErrorCode ?? this.httpErrorCode,
    );
  }
}

class AgentViewerNotifier extends StateNotifier<AgentViewerState> {
  AgentViewerNotifier() : super(const AgentViewerState());

  bool _hadError = false;

  void onPageStarted() {
    _hadError = false;
    state = const AgentViewerState(status: AgentViewerStatus.loading);
  }

  void onPageFinished() {
    if (_hadError) return;
    state = const AgentViewerState(status: AgentViewerStatus.loaded);
  }

  void onHttpError(int? code) {
    _hadError = true;
    state = AgentViewerState(status: AgentViewerStatus.error, httpErrorCode: code);
  }

  void onNetworkError() {
    _hadError = true;
    state = const AgentViewerState(status: AgentViewerStatus.error);
  }
}

final agentViewerProvider =
    StateNotifierProvider.autoDispose<AgentViewerNotifier, AgentViewerState>(
  (ref) => AgentViewerNotifier(),
);
