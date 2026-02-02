import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/storage_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';

class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const AppLifecycleWrapper({super.key, required this.child});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper> with WidgetsBindingObserver {
  Timer? _inactivityTimer;


  static const _inactivityDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();


    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _inactivityTimer = Timer(_inactivityDuration, _lockAppDueToInactivity);
    }
  }


  void _lockAppDueToInactivity() async {
    final storage = context.read<StorageService>();
    final authBloc = context.read<AuthBloc>();

    if (authBloc.state is Authenticated) {
      await storage.setLockStatus(true);
      await Future.delayed(const Duration(milliseconds: 50));
      authBloc.add(AppStarted());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final storage = context.read<StorageService>();
    final authBloc = context.read<AuthBloc>();

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {

      _inactivityTimer?.cancel();
      await storage.setLockStatus(true);
    } else if (state == AppLifecycleState.resumed) {

      _resetInactivityTimer();
      authBloc.add(AppStarted());
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(

      listener: (context, state) {
        if (state is Authenticated) {
          _resetInactivityTimer();
        } else {

          _inactivityTimer?.cancel();
        }
      },
      child: Listener(
        onPointerDown: (_) => _resetInactivityTimer(),
        onPointerMove: (_) => _resetInactivityTimer(),
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}