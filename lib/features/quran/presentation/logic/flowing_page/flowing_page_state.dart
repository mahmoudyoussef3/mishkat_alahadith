part of 'flowing_page_cubit.dart';

@immutable
sealed class FlowingPageState {
  const FlowingPageState();
}

final class FlowingPageLoading extends FlowingPageState {
  const FlowingPageLoading();
}

final class FlowingPageReady extends FlowingPageState {
  final QuranFlowingPage page;

  const FlowingPageReady(this.page);
}

final class FlowingPageFailure extends FlowingPageState {
  final String message;

  const FlowingPageFailure(this.message);
}
