import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/position.dart';
import '../../../../shared/models/table_type.dart';
import '../../../../shared/widgets/poker_table_view.dart';

/// いま席を割り当てている相手。
enum SeatRole {
  hero('あなた', AppColors.accent),
  villain('相手', AppColors.info);

  const SeatRole(this.label, this.color);

  final String label;
  final Color color;
}

/// テーブルの図から自分と相手の席を選ぶ。
///
/// チップを並べるより、円卓のどこに座るかをそのままタップできたほうが
/// ポジション同士の位置関係が分かりやすい。
class PositionPicker extends StatefulWidget {
  const PositionPicker({
    super.key,
    required this.tableType,
    required this.heroPosition,
    required this.villainPosition,
    required this.onHeroChanged,
    required this.onVillainChanged,
  });

  final TableType tableType;
  final Position heroPosition;
  final Position villainPosition;
  final ValueChanged<Position> onHeroChanged;
  final ValueChanged<Position> onVillainChanged;

  @override
  State<PositionPicker> createState() => _PositionPickerState();
}

class _PositionPickerState extends State<PositionPicker> {
  SeatRole _role = SeatRole.hero;

  void _handleSeatTap(Position position) {
    if (_role == SeatRole.hero) {
      if (position == widget.villainPosition) return;
      widget.onHeroChanged(position);
      // 自分を置いたら、続けて相手を選べるように切り替える。
      setState(() => _role = SeatRole.villain);
    } else {
      if (position == widget.heroPosition) return;
      widget.onVillainChanged(position);
      setState(() => _role = SeatRole.hero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<SeatRole>(
          segments: [
            for (final role in SeatRole.values)
              ButtonSegment(
                value: role,
                label: Text(
                  role == SeatRole.hero
                      ? '${role.label}: ${widget.heroPosition.label}'
                      : '${role.label}: ${widget.villainPosition.label}',
                ),
              ),
          ],
          selected: {_role},
          onSelectionChanged: (selection) =>
              setState(() => _role = selection.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 14, color: _role.color),
            const SizedBox(width: AppSpacing.xs),
            // 端末幅が狭いと折り返せずに溢れるため Expanded で包む。
            Expanded(
              child: Text(
                '席をタップして「${_role.label}」の位置を決めてください',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _role.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        PokerTableView(
          tableType: widget.tableType,
          heroPosition: widget.heroPosition,
          villainPosition: widget.villainPosition,
          onSeatTap: _handleSeatTap,
          // 選択中に席が動くと分かりづらいので、並びは固定する。
          rotateHeroToBottom: false,
          height: widget.tableType == TableType.nineMax ? 200 : 168,
        ),
      ],
    );
  }
}
