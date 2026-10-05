import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_settings_cubit.dart';

/// Marks a screen that can read hadiths aloud and owns what it reads.
///
/// A reading started under it stops when the screen closes, and pauses
/// when another page opens over it (sheets and dialogs do not count) or,
/// on iOS, when the app goes to the background, where iOS would cut it
/// off. Messages about the reading are shown here.
class ReadAloudHost extends StatefulWidget {
  const ReadAloudHost({super.key, required this.child});

  final Widget child;

  /// The owner token of the nearest host, or null outside one.
  static Object? maybeOwnerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ReadAloudOwner>()?.owner;

  static Object ownerOf(BuildContext context) {
    final owner = maybeOwnerOf(context);
    assert(owner != null, 'No ReadAloudHost above this widget.');
    return owner!;
  }

  @override
  State<ReadAloudHost> createState() => _ReadAloudHostState();
}

class _ReadAloudHostState extends State<ReadAloudHost>
    with WidgetsBindingObserver {
  final Object _owner = Object();
  late final ReadAloudCubit _cubit;
  Animation<double>? _coverAnimation;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ReadAloudCubit>();
    context.read<ReadAloudSettingsCubit>().load();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A page pushed over this route drives its secondary animation.
    final animation = ModalRoute.of(context)?.secondaryAnimation;
    if (animation != _coverAnimation) {
      _coverAnimation?.removeStatusListener(_onCoverChanged);
      _coverAnimation = animation?..addStatusListener(_onCoverChanged);
    }
  }

  void _onCoverChanged(AnimationStatus status) {
    if (status == AnimationStatus.forward) _cubit.interrupt(_owner);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      _cubit.interrupt(_owner);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _coverAnimation?.removeStatusListener(_onCoverChanged);
    _cubit.release(_owner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ReadAloudOwner(
      owner: _owner,
      child: BlocListener<ReadAloudCubit, ReadAloudState>(
        listenWhen:
            (previous, current) =>
                current.notice != null &&
                current.notice != previous.notice &&
                identical(current.notice!.owner, _owner),
        listener:
            (context, state) => showErrorSnackbar(context, state.notice!.message),
        child: widget.child,
      ),
    );
  }
}

class _ReadAloudOwner extends InheritedWidget {
  const _ReadAloudOwner({required this.owner, required super.child});

  final Object owner;

  @override
  bool updateShouldNotify(_ReadAloudOwner oldWidget) =>
      !identical(owner, oldWidget.owner);
}
