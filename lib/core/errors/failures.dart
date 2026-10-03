sealed class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType($message)';
}

final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure([
    super.message = FailureMessages.server,
    this.statusCode,
  ]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = FailureMessages.noConnection]);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = FailureMessages.unauthorized]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = FailureMessages.unexpected]);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = FailureMessages.unexpected]);
}

abstract final class FailureMessages {
  static const String server =
      'عذراً، لم نتمكن من جلب البيانات الآن. نرجو المحاولة لاحقاً.';
  static const String noConnection = 'لا يوجد اتصال بالإنترنت';
  static const String unauthorized = 'يرجى تسجيل الدخول أولاً';
  static const String unexpected = 'حدث خطأ غير متوقع';
}
