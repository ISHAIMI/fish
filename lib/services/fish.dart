import 'package:flutter/material.dart';

class Fish {
  Color color;
  double speed;
  Offset position;

  Fish({required this.color, required this.speed, required this.position});

  // Factory constructor to create Fish from database
  factory Fish.fromMap(Map<String, dynamic> map) {
    return Fish(
      color: Color(int.parse(map['color'])),
      speed: map['speed'],
      position: Offset(map['position_x'], map['position_y']),
    );
  }

  // Method to convert Fish to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'color': color.value.toString(),
      'speed': speed,
      'position_x': position.dx,
      'position_y': position.dy,
    };
  }
}
