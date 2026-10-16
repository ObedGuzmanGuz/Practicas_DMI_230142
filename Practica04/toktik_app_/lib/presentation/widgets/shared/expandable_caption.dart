import 'package:flutter/material.dart';

/// Muestra una descripción breve y permite abrir un área con scroll vertical.
class ExpandableCaption extends StatefulWidget {
  final String text;
  final ValueChanged<bool>? onExpandedChanged;

  const ExpandableCaption({super.key, required this.text, this.onExpandedChanged});

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  static const int _previewCharacters = 95;
  static const double _expandedHeight = 112;
  bool _expanded = false;

  bool get _isLong => widget.text.trim().length > _previewCharacters;

  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim();
    if (text.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: _expanded && _isLong ? _expandedHeight : null,
          constraints: BoxConstraints(
            maxHeight: _expanded && _isLong ? _expandedHeight : 51,
          ),
          child: SingleChildScrollView(
            physics: _expanded ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            child: Text(
              text,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                height: 1.25,
              ),
            ),
          ),
        ),
        if (_isLong)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => _expanded = !_expanded);
              widget.onExpandedChanged?.call(_expanded);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 1),
              child: Text(
                _expanded ? 'menos' : '... más',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
