import 'package:flutter/material.dart';

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
