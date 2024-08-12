//import 'package:compass_app/compass_view_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'compass_view_painter.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? direction;
  double? previousDirection;

  double headingToDegrees(double heading) {
    return heading < 0 ? 360 - heading.abs() : heading;
  }

  double adjustDirection(double oldDirection, double newDirection) {
    double diff = newDirection - oldDirection;

    // Ensure the direction wraps around at 360 degrees
    if (diff > 180) {
      newDirection -= 360;
    } else if (diff < -180) {
      newDirection += 360;
    }

    // Wrap around the angle to stay within 0-360 degrees
    newDirection = newDirection % 360;
    if (newDirection < 0) {
      newDirection += 360;
    }

    return newDirection;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error reading the data');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          direction = snapshot.data!.heading;
          if (direction == null) {
            return const Text('Device does not have sensors');
          } else {
            double adjustedDirection = headingToDegrees(direction!);
            if (previousDirection != null) {
              adjustedDirection =
                  adjustDirection(previousDirection!, adjustedDirection);
            }
            previousDirection = adjustedDirection;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating Compass
                        Transform.rotate(
                          angle: adjustedDirection * (3.141592653589793 / 180) * -1,
                          child: CustomPaint(
                            size: Size.square(size.width * 0.8),
                            painter: CompassViewPainter(color: Colors.grey),
                          ),
                        ),
                        // Magnetic Compass Image with Increased Height
                        Image.asset(
                          'assets/compass_needle.png',
                          width: size.width * 0.3,
                          height: size.width * 0.3, // Increased height
                        ),
                      ],
                    ),
                  ),
                  DisplayMeter(direction: headingToDegrees(adjustedDirection)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class DisplayMeter extends StatelessWidget {
  const DisplayMeter({required this.direction, super.key});

  final double direction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${direction.toInt().toString().padLeft(3, '')}°',
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20.0,),
        Text(
          getCompassAngles(direction),
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * 0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String getCompassAngles(double direction) {
    if (direction >= 337.5 || direction < 22.5) {
      return "North";
    } else if (direction >= 22.5 && direction < 67.5) {
      return "North-East";
    } else if (direction >= 67.5 && direction < 112.5) {
      return "East";
    } else if (direction >= 112.5 && direction < 157.5) {
      return "South-East";
    } else if (direction >= 157.5 && direction < 202.5) {
      return "South";
    } else if (direction >= 202.5 && direction < 247.5) {
      return "South-West";
    } else if (direction >= 247.5 && direction < 292) {
      return "West";
    } else if (direction >= 292.5 && direction < 337.5) {
      return "North-West";
    } else {
      return "North";
    }
  }
}
