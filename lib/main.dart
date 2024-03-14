import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const BalloonPopGame());
}

class BurstAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const BurstAnimation({Key? key, required this.onAnimationComplete})
      : super(key: key);

  @override
  _BurstAnimationState createState() => _BurstAnimationState();
}

class _BurstAnimationState extends State<BurstAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animationController.drive(Tween(begin: 1.0, end: 2.0)),
      child: const Icon(
        Icons.favorite,
        color: Colors.red,
        size: 50,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class BalloonPopGame extends StatelessWidget {
  const BalloonPopGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Pop Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int balloonsPopped = 0;
  int balloonsMissed = 0;
  int score = 0;
  int gameTimeInSeconds = 120;
  bool gameRunning = false;
  late Timer timer;
  List<Widget> balloons = [];

  @override
  void initState() {
    super.initState();
    balloons.add(Container()); // Initial balloon placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Pop Game'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Time: ${formatTime(gameTimeInSeconds)}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Balloons Popped: $balloonsPopped',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              'Balloons Missed: $balloonsMissed',
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            gameRunning
                ? Stack(
                    children: [
                      Column(
                        children: balloons,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              balloonsPopped++;
                              score += 2;
                            });
                            _showBurstAnimation();
                          },
                          child: Container(
                            height: 50,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: startGame,
                    child: const Text('Start Game'),
                  ),
          ],
        ),
      ),
    );
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      balloonsPopped = 0;
      balloonsMissed = 0;
      score = 0;
      balloons.clear();
      balloons.add(Container()); // Initial balloon placeholder
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (gameTimeInSeconds > 0) {
            gameTimeInSeconds--;
            if (gameTimeInSeconds % 4 == 0) {
              // Add new balloons every 4 seconds
              addBalloon();
            }
          } else {
            endGame();
          }
        });
      });
    });
  }

  void endGame() {
    setState(() {
      gameRunning = false;
      timer.cancel();
      // Calculate final score accounting for missed balloons
      score -= balloonsMissed;
    });
  }

  void addBalloon() {
    final rng = Random();
    final balloonKey = GlobalKey();
    final balloon = Positioned(
      key: balloonKey,
      left: rng.nextDouble() * 300,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            balloonsPopped++;
            score += 2;
            balloons.removeAt(0); // Remove popped balloon
          });
          _showBurstAnimation();
        },
        child: Image.asset('assets/balloon.png', height: 300),
      ),
    );
    setState(() {
      balloons.add(balloon);
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  void _showBurstAnimation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: BurstAnimation(
          onAnimationComplete: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
