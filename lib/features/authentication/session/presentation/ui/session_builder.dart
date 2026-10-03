import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/session_cubit.dart';

class SessionBuilder extends StatelessWidget {
  const SessionBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, bool isSignedIn) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SessionCubit, SessionState, bool>(
      selector: (state) => state is SessionSignedIn,
      builder: builder,
    );
  }
}
