import 'package:flutter/material.dart';

class AnimatedContainerRowWidget extends StatefulWidget {
  @override
  _AnimatedContainerRowWidgetState createState() =>
      _AnimatedContainerRowWidgetState();
}

class _AnimatedContainerRowWidgetState extends State<AnimatedContainerRowWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(4),
            curve: Curves.easeInOut,
            width: _isExpanded ? 200.0 : 100.0,
            height: 100.0,
            color: Colors.blue,
          ),
          const SizedBox(width: 16.0), // Adjust as needed
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _isExpanded ? 200.0 : 100.0,
            height: 100.0,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
