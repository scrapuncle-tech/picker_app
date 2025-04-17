import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_sync_status.entity.dart';
import '../../providers/sync_status.provider.dart';
import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../common/text.component.dart';

class TimeAgoText extends ConsumerStatefulWidget {
  const TimeAgoText({super.key});

  @override
  ConsumerState<TimeAgoText> createState() => _TimeAgoTextState();
}

class _TimeAgoTextState extends ConsumerState<TimeAgoText> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    SyncStatus? syncStatus = ref.watch(syncStatusProvider);

    return CustomText(
      text:
          syncStatus?.lastSyncTime != null
              ? formatTimeAgo(syncStatus!.lastSyncTime)
              : "Not yet synced",
      size: sizeData.subHeader,
      color: colorData.fontColor(.7),
      weight: FontWeight.w900,
    );
  }
}
