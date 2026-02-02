import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/storage_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';

class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const AppLifecycleWrapper({super.key, required this.child});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Start listening to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Stop listening when the app is destroyed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final storage = context.read<StorageService>();
    final authBloc = context.read<AuthBloc>();

    // When app moves to background or is swiped away
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      await storage.setLockStatus(true);
    }
    // When app comes back to the front
    else if (state == AppLifecycleState.resumed) {
      authBloc.add(AppStarted());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}