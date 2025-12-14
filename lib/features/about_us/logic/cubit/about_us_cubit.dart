import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/about_us/data/repos/about_us_repo.dart' show AboutUsRepo;

part 'about_us_state.dart';

class AboutUsCubit extends Cubit<AboutUsState> {
  final AboutUsRepo aboutUsRepo;

  AboutUsCubit(this.aboutUsRepo) : super(AboutUsInitial());
}
