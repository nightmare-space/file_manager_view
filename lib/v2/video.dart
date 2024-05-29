// import 'package:better_player/better_player.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class SerieExample extends StatefulWidget {
  const SerieExample({Key? key,required this.path}) : super(key: key);
  final String path;

  @override
  State createState() => _SerieExampleState();
}

class _SerieExampleState extends State<SerieExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: widget.path.startsWith('http')
              ? BetterPlayer.network(
                  Uri.encodeFull(widget.path),
                  betterPlayerConfiguration: const BetterPlayerConfiguration(
                    // aspectRatio: 9 / 16,
                    fullScreenByDefault: false,
                    autoPlay: true,
                    fit: BoxFit.contain,
                  ),
                )
              : BetterPlayer.file(
                  widget.path,
                  betterPlayerConfiguration: const BetterPlayerConfiguration(
                    // aspectRatio: 9 / 16,
                    fullScreenByDefault: false,
                    autoPlay: true,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
    );
  }
}
