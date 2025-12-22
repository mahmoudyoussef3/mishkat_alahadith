import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  PrayerTimesCubit() : super(PrayerTimesInitial());
}
