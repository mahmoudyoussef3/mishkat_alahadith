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

/// The device's text-to-speech engine could not do what was asked.
final class SpeechFailure extends Failure {
  const SpeechFailure([super.message = FailureMessages.speech]);
}

/// The device has no Arabic text-to-speech voice to read with.
final class ArabicVoiceUnavailableFailure extends Failure {
  const ArabicVoiceUnavailableFailure([
    super.message = FailureMessages.arabicVoiceUnavailable,
  ]);
}

abstract final class FailureMessages {
  static const String server =
      'عذراً، لم نتمكن من جلب البيانات الآن. نرجو المحاولة لاحقاً.';
  static const String noConnection = 'لا يوجد اتصال بالإنترنت';
  static const String unauthorized = 'يرجى تسجيل الدخول أولاً';
  static const String unexpected = 'حدث خطأ غير متوقع';
  static const String speech = 'تعذر تشغيل القراءة الصوتية، حاول مرة أخرى';
  static const String arabicVoiceUnavailable =
      'لا يتوفر صوت عربي على جهازك. ثبّت اللغة العربية من إعدادات '
      'تحويل النص إلى كلام ثم أعد المحاولة.';
  static const String speechTooLong =
      'نص الحديث أطول من أن يُحفظ في ملف صوتي واحد';
}
