import 'dart:math';

import 'package:flutter/material.dart';
import '../services/fish.dart';

class FishWidget extends StatefulWidget {
  final Fish fish;
  final Size aquariumSize;

  FishWidget({
    required this.fish,
    required this.aquariumSize,
  });

  @override
  _FishWidgetState createState() => _FishWidgetState();
}

class _FishWidgetState extends State<FishWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for each fish
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (10 / widget.fish.speed).round()),
    );

    // Start the fish at a random position and animate it to another random position
    _animation = Tween<Offset>(
      begin: _randomPosition(),
      end: _randomPosition(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Start the animation and continuously change the fish's end position
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Update the animation to continue moving the fish to a new random position
          _animation = Tween<Offset>(
            begin: _animation.value, // Start from the current position
            end: _randomPosition(), // Move to a new random position
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
          _controller.forward(from: 0); // Restart animation
        });
      }
    });
  }

  Offset _randomPosition() {
    final random = Random();
    // Ensure fish can move across the full width and height of the container
    // The fish's size is subtracted only to keep the fish fully visible within bounds
    double fishSize = 20.0;
    return Offset(
      random.nextDouble() * (widget.aquariumSize.width - fishSize),
      // Adjust for fish size
      random.nextDouble() * (widget.aquariumSize.height - fishSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.fish.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
