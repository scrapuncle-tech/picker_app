import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/pickup.entity.dart';
import '../../providers/current_pickup.provider.dart';
import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../common/text.component.dart';

class SubStatusDropdown extends ConsumerWidget {
  final Pickup pickup;
  final bool isDisabled;

  const SubStatusDropdown({
    super.key,
    required this.pickup,
    this.isDisabled = false,
  });

  // List of available sub-status options
  static const List<String> subStatusOptions = [
    'Call not connected',
    'DNP',
    'DND',
    'customer asked to cancel',
    'customer asked to reschedule',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    // Get the current sub-status
    String currentSubStatus = pickup.subStatus;

    // If empty, show a placeholder
    String displayText =
        currentSubStatus.isEmpty || !subStatusOptions.contains(currentSubStatus)
            ? 'Select status'
            : currentSubStatus;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorData.fontColor(.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              subStatusOptions.contains(currentSubStatus)
                  ? currentSubStatus
                  : null,
          hint: CustomText(
            text: displayText,
            size: sizeData.small,
            color: colorData.fontColor(.7),
          ),
          icon: Icon(Icons.arrow_drop_down, color: colorData.fontColor(.7)),
          isDense: true,
          isExpanded: true,
          onChanged:
              isDisabled
                  ? null
                  : (String? newValue) {
                    if (newValue != null) {
                      // check for a local pickup
                      final isCurrentPickup =
                          ref.read(currentPickupProvider).$1 != null;
                      if (isCurrentPickup) {
                        ref
                            .read(currentPickupProvider.notifier)
                            .updateSubStatus(subStatus: newValue);
                      } else {
                        ref
                            .read(currentPickupProvider.notifier)
                            .updatePickup(
                              pickup: pickup.copyWith(subStatus: newValue),
                            );
                      }
                    }
                  },
          items:
              subStatusOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: CustomText(
                    text: value,
                    size: sizeData.small,
                    color: colorData.fontColor(.9),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
