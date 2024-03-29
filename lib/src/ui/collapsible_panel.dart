import 'package:flutter/material.dart';

class CollapsiblePanel extends StatefulWidget {
  final Widget child;
  final bool collapsed;
  const CollapsiblePanel(
      {super.key, this.collapsed = true, required this.child});

  @override
  State<CollapsiblePanel> createState() => _CollapsiblePanelState();
}

class _CollapsiblePanelState extends State<CollapsiblePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.collapsed) {
      expandController.reverse();
    } else {
      expandController.forward();
    }
  }

  @override
  void didUpdateWidget(CollapsiblePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: widget.child,
    );
  }
}
