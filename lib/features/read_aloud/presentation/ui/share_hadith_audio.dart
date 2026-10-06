import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:share_plus/share_plus.dart';

/// Records the hadith read aloud with the reader's voice and opens the
/// share sheet with the audio file.
Future<void> shareHadithAudio(
  BuildContext context,
  HadithSpeechRequest request,
) async {
  final cubit = context.read<ReadAloudCubit>();
  if (cubit.state.exporting) return;
  final navigator = Navigator.of(context);
  final origin = shareOriginOf(context);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _RecordingDialog(),
  );
  final result = await cubit.exportAudio(request);
  navigator.pop();
  if (!context.mounted) return;

  switch (result) {
    case ApiSuccess(data: final path):
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(
                path,
                mimeType: path.endsWith('.caf') ? 'audio/x-caf' : 'audio/wav',
              ),
            ],
            text: request.title,
            sharePositionOrigin: origin,
          ),
        );
      } on PlatformException {
        if (context.mounted) {
          showErrorSnackbar(context, 'تعذر مشاركة المقطع الصوتي');
        }
      }
    case ApiFailure(:final failure):
      showErrorSnackbar(context, failure.message);
  }
}

class _RecordingDialog extends StatelessWidget {
  const _RecordingDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: ColorsManager.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 26.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: ColorsManager.primaryPurple,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جارٍ تجهيز المقطع الصوتي',
                        style: TextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'يُسجَّل الحديث بالصوت الذي اخترته',
                        style: TextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
