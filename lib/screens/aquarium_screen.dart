import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:virtual_aquarium/services/fish.dart';

import '../components/fish_widget.dart';

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  static const String id = "aquarium_screen";

  @override
  State<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with TickerProviderStateMixin {
  List<Fish> fishList = [];
  Color selectedColor = Colors.blue;
  double selectedSpeed = 1.0;
  late Database database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
            child: Text(
          'Virtual Aquarium',
          style:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            width: 300,
            height: 300,
            child: Stack(
              children: fishList
                  .map((fish) => FishWidget(
                        fish: fish,
                        aquariumSize: Size(300, 300),
                        // controller: AnimationController(
                        //     vsync: this,
                        //     duration:
                        //         Duration(seconds: (5 / fish.speed).round())),
                      ))
                  .toList(),
            ),
          ),
          SizedBox(height: 16.0),
          Slider(
            value: selectedSpeed,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            label: "${selectedSpeed.toStringAsFixed(1)}x Speed",
            onChanged: (value) {
              setState(() {
                selectedSpeed = value;
              });
            },
            activeColor: Colors.blueAccent,
          ),
          SizedBox(height: 16.0),
          Container(
            padding: EdgeInsets.only(left: 16.0, right: 8.0),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius:
                  BorderRadius.circular(8), // Optional: Add rounded corners
            ),
            child: DropdownButton<Color>(
              iconEnabledColor: Colors.grey,
              value: selectedColor,
              items: [
                DropdownMenuItem(
                  child: Text(
                    "Blue Color",
                    style: TextStyle(color: Colors.blue),
                  ),
                  value: Colors.blue,
                ),
                DropdownMenuItem(
                  child: Text(
                    "Red Color",
                    style: TextStyle(color: Colors.red),
                  ),
                  value: Colors.red,
                ),
                DropdownMenuItem(
                  child: Text(
                    "Green Color",
                    style: TextStyle(color: Colors.green),
                  ),
                  value: Colors.green,
                ),
              ],
              onChanged: (Color? color) {
                setState(() {
                  if (color != null) selectedColor = color;
                });
              },
              dropdownColor: CupertinoColors.lightBackgroundGray,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              backgroundColor: Colors.white,
            ),
            onPressed: _addFish,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Add Fish',
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 32.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              backgroundColor: Colors.white,
            ),
            onPressed: _resetFish,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Reset',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'aquarium.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE fish(id INTEGER PRIMARY KEY, color TEXT, speed REAL, position_x REAL, position_y REAL)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Add new columns to the existing table
        if (oldVersion < 2) {
          db.execute("ALTER TABLE fish ADD COLUMN position_x REAL");
          db.execute("ALTER TABLE fish ADD COLUMN position_y REAL");
        }
      },
      version: 2,
    );
    _loadSettings();
  }



  void _loadSettings() async {
    final List<Map<String, dynamic>> fishData = await database.query('fish');
    setState(() {
      fishList = fishData.map((fish) => Fish.fromMap(fish)).toList();  // Use fromMap
    });
  }


  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        // Add a new fish with a random starting position
        fishList.add(Fish(
          color: selectedColor,
          speed: selectedSpeed,
          position: _randomStartPosition(), // Fish starts at random position
        ));
        _saveFish(fishList.last);
      });
    }
  }

// Function to generate random start position within the aquarium bounds
  Offset _randomStartPosition() {
    final random = Random();
    return Offset(
      random.nextDouble() * 300,  // Assuming aquarium width is 300
      random.nextDouble() * 300,  // Assuming aquarium height is 300
    );
  }

  void _saveFish(Fish fish) async {
    await database.insert(
      'fish',
      fish.toMap(),  // Use the toMap() method
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void _resetFish() async {
    setState(() {
      fishList.clear();
      selectedColor = Colors.blue;
      selectedSpeed = 1.0;
    });
    await database.delete('fish'); // Clear the database
  }
}





