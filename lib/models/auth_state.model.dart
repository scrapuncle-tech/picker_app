import 'picker.entity.dart';

enum AuthStateStatus {
  loading,
  authenticated,
  unauthenticated,
  wrongUser,
  error,
}

class AuthState {
  final AuthStateStatus status;
  final Picker? pickerData;
  final String? error;

  AuthState({
    this.error,
    this.pickerData,
    this.status = AuthStateStatus.loading,
  });

  AuthState copyWith({
    String? error,
    Picker? pickerData,
    AuthStateStatus? status,
  }) {
    return AuthState(
      error: error ?? this.error,
      pickerData: pickerData ?? this.pickerData,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'AuthNotifier(state: $status, '
        'pickerData=${pickerData?.toFirebase()}, '
        'error=$error, '
        ')';
  }
}
