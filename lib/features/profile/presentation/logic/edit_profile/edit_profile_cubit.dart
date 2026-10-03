import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/profile/domain/entities/user_profile.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/update_profile_use_case.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase _updateProfile;
  EditProfileCubit(this._updateProfile) : super(EditProfileInitial());

  Future<void> updateProfile({
    required String username,
    File? avatarFile,
  }) async {
    emit(EditProfileLoading());

    final result = await _updateProfile(
      username: username,
      avatarPath: avatarFile?.path,
    );

    result.when(
      success: (updatedUser) => emit(EditProfileSuccess(updatedUser)),
      failure: (failure) => emit(EditProfileFailure(failure.message)),
    );
  }
}
