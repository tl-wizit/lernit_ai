import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSControls extends StatefulWidget {
  final String text;
  final String language;
  final TextStyle? highlightStyle;
  final TextStyle? normalStyle;

  const TTSControls({
    Key? key,
    required this.text,
    required this.language,
    this.highlightStyle,
    this.normalStyle,
  }) : super(key: key);

  @override
  State<TTSControls> createState() => _TTSControlsState();
}

class _TTSControlsState extends State<TTSControls> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  int? _currentStart;
  int? _currentEnd;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage(widget.language);
    _tts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentStart = null;
        _currentEnd = null;
      });
    });
    _tts.setProgressHandler((String text, int start, int end, String word) {
      setState(() {
        _currentStart = start;
        _currentEnd = end;
      });
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _play() async {
    await _tts.setLanguage(widget.language);
    await _tts.speak(widget.text);
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  Future<void> _pause() async {
    await _tts.pause();
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
  }

  Future<void> _stop() async {
    await _tts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _currentStart = null;
      _currentEnd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final highlightStyle = widget.highlightStyle ??
        const TextStyle(backgroundColor: Colors.yellow);
    final normalStyle =
        widget.normalStyle ?? DefaultTextStyle.of(context).style;
    Widget textWidget;
    if (_currentStart != null &&
        _currentEnd != null &&
        _currentStart! < _currentEnd!) {
      textWidget = RichText(
        text: TextSpan(
          style: normalStyle,
          children: [
            TextSpan(text: text.substring(0, _currentStart!)),
            TextSpan(
                text: text.substring(_currentStart!, _currentEnd!),
                style: highlightStyle),
            TextSpan(text: text.substring(_currentEnd!)),
          ],
        ),
      );
    } else {
      textWidget = Text(text, style: normalStyle);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _isPlaying ? _pause : _play,
              tooltip: _isPlaying ? 'Pause' : 'Play',
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: _stop,
              tooltip: 'Restart',
            ),
          ],
        ),
      ],
    );
  }
}
