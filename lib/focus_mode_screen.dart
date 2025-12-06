import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'theme.dart';

class FocusModeScreen extends StatefulWidget {
  final String taskTitle;
  final DateTime deadline;

  const FocusModeScreen({
    super.key,
    required this.taskTitle,
    required this.deadline,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> with WidgetsBindingObserver {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isPaused = false;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _isMinimized = true;
        _isPaused = true;
      });
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _isMinimized = false;
      });
      if (!_isPaused) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isMinimized) {
        setState(() {
          _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Focus Mode',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Task Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        widget.taskTitle,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deadline: ${widget.deadline.toString().substring(0, 16)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Timer Display
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryYellow,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  _formatDuration(_elapsed),
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Warning if minimized
            if (_isMinimized)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: AppTheme.danger.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: AppTheme.danger),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Timer paused - App was minimized',
                            style: GoogleFonts.inter(
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isPaused = !_isPaused;
                      });
                      if (_isPaused) {
                        _timer?.cancel();
                      } else {
                        _startTimer();
                      }
                    },
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'Resume' : 'Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

