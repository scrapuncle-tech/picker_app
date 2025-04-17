import 'picker.entity.dart';

enum Status { started, loading, success, error }

class AuthProcessState {
  final Status status;
  final Picker? picker;
  final String? message;

  const AuthProcessState._({required this.status, this.picker, this.message});

  factory AuthProcessState.started() =>
      const AuthProcessState._(status: Status.started);
  factory AuthProcessState.loading() =>
      const AuthProcessState._(status: Status.loading);
  factory AuthProcessState.success(Picker picker) =>
      AuthProcessState._(status: Status.success, picker: picker);
  factory AuthProcessState.error(String message) =>
      AuthProcessState._(status: Status.error, message: message);
}
