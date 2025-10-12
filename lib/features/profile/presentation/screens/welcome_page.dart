import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:vibration/vibration.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        AnimatedEmoji(AnimatedEmojis.smile, size: 200),
        Text(
          "You've made it!",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          "We'd like to know you better before you continue to Academia. ❤️‍🔥",
        ),
        Spacer(),
        FilledButton(
          onPressed: () async {
            if (await Vibration.hasVibrator()) {
              await Vibration.vibrate(pattern: [0, 50], intensities: [0, 128]);
            }
            onNext();
          },
          child: Text("Get Started"),
        ),
      ],
    );
  }
}
