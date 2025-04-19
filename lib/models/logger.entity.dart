import 'package:objectbox/objectbox.dart';

import '../components/common/custom_snackbar.component.dart';


@Entity()
class Logger {
  @Id()
  int id;

  /// Store enum as int
  int? statusIndex;

  /// Message text
  String? message;

  Logger({this.id = 0, SnackBarType? status, this.message})
    : statusIndex = status?.index;

  /// Use this getter to access the SnackBarType enum
  SnackBarType? get status =>
      statusIndex != null ? SnackBarType.values[statusIndex!] : null;

  /// Use this setter to update the enum
  set status(SnackBarType? value) => statusIndex = value?.index;

  Logger copyWith({SnackBarType? status, String? message}) {
    return Logger(
      id: id,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'Logger{id: $id, status: $status, message: $message}';
  }
}
