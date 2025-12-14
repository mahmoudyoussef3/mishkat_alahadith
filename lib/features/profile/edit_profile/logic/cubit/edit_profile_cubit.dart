import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:mishkat_almasabih/features/profile/edit_profile/data/repos/edit_profile_repo.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final EditProfileRepo editProfileRepo;
  EditProfileCubit(this.editProfileRepo) : super(EditProfileInitial());

  Future<void> updateProfile({
    required String username,
    File? avatarFile,
  }) async {
    emit(EditProfileLoading());

    final result = await editProfileRepo.updateProfile(
      username: username,
      imageFile: avatarFile, // 👈 File مباشرة
    );

    result.fold(
      (failure) => emit(EditProfileFailure(
          failure.getAllErrorMessages())),
      (updatedUser) => emit(EditProfileSuccess(updatedUser)),
    );
  }
}
