import 'package:flutter/material.dart';

class CustomExpansionPanel extends StatefulWidget {
  final Widget header;
  final Widget body;
  final LinearGradient gradient;

  const CustomExpansionPanel({
    super.key,
    required this.header,
    required this.body,
    required this.gradient,
  });

  @override
  State<CustomExpansionPanel> createState() => _CustomExpansionPanelState();
}

class _CustomExpansionPanelState extends State<CustomExpansionPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Expanded(child: widget.header),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
          if (_isExpanded) widget.body,
        ],
      ),
    );
  }
}
