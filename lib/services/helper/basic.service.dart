
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

import '../../components/common/custom_snackbar.component.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'placed':
      return Colors.blue; // New order placed
    case 'scheduled':
      return Colors.orange; // Scheduled for pickup
    case 'picker assigned':
      return Colors.purple; // Picker is assigned
    case 'completed':
      return Colors.green; // Pickup completed
    case 'cancelled':
      return Colors.red; // Order cancelled
    case 'follow up':
      return Colors.amber; // Needs follow-up
    case 'reschedule':
      return Colors.teal; // Rescheduled for another time
    default:
      return Colors.grey; // Default color for unknown status
  }
}

String formatTimeAgo(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s ago';
  } else if (difference.inMinutes < 60) {
    final seconds = difference.inSeconds % 60;
    return '${difference.inMinutes}m${seconds > 0 ? ' ${seconds}s' : ''} ago';
  } else if (difference.inHours < 24) {
    final minutes = difference.inMinutes % 60;
    return '${difference.inHours}h${minutes > 0 ? ' ${minutes}m' : ''} ago';
  } else {
    final days = difference.inDays;
    return '$days day${days > 1 ? 's' : ''} ago';
  }
}

void copyToClipboard(String text) async {
  CustomSnackBar.log(
    status: SnackBarType.success,
    message: "Copied to clipboard",
  );
  await FlutterClipboard.copy(text);
}
