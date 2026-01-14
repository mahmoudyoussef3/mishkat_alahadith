import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:mishkat_almasabih/features/profile/edit_profile/logic/cubit/edit_profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final UserResponseModel userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.userData.username ?? "",
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedImageFile = File(image.path));
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "غير محدد";
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}/${date.month}/${date.day}";
    } catch (_) {
      return "غير محدد";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: ProfileDecorations.editProfileBackground,
          child: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
              if (state is EditProfileSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: ProfileDecorations.successSnackbarBehavior,
                    backgroundColor:
                        ProfileDecorations.successSnackbarBackground,
                    content: Text(
                      "تم تحديث الملف الشخصي بنجاح",
                      style: ProfileTextStyles.successSnackbarText,
                    ),
                  ),
                );
                Navigator.pop(context, state.updatedUser);
              } else if (state is EditProfileFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("فشل التحديث: ${state.errorMessage}"),
                    backgroundColor: ProfileDecorations.errorSnackbarBackground,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "تعديل الملف الشخصي",
                            textAlign: TextAlign.center,
                            style: ProfileTextStyles.editProfileTitle,
                          ),
                        ),
                        SizedBox(width: 48.w), // space balance
                      ],
                    ),
                    SizedBox(height: 30.h),

                    // ===== Avatar Section =====
                    AvatarSection(
                      selectedImageFile: _selectedImageFile,
                      avatarUrl: getAvatarUrl(widget.userData),
                      onPickImage: _pickImage,
                    ),
                    SizedBox(height: 32.h),

                    // ===== Username =====
                    UsernameSection(controller: _usernameController),
                    SizedBox(height: 24.h),

                    // ===== InfoCard =====
                    InfoCard(
                      email: widget.userData.email,
                      createdAt: _formatDate(widget.userData.createdAt),
                      achievements: widget.userData.weeklyAchievementCount ?? 0,
                    ),
                    SizedBox(height: 40.h),

                    // ===== Save Button =====
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primaryPurple,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 6,
                        ),
                        onPressed:
                            state is EditProfileLoading
                                ? null
                                : () {
                                  context
                                      .read<EditProfileCubit>()
                                      .updateProfile(
                                        username:
                                            _usernameController.text.trim(),
                                        avatarFile: _selectedImageFile,
                                      );
                                },
                        child:
                            state is EditProfileLoading
                                ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  "حفظ",
                                  style: ProfileTextStyles.saveButtonText,
                                ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String getAvatarUrl(UserResponseModel? user) {
    const String defaultAvatar =
        "https://api.hadith-shareef.com/api/uploads/avatars/default-avatar.jpg";
    if (user == null) {
      return defaultAvatar;
    }

    final String? url = user.avatarUrl;

    if (url != null && url.isNotEmpty) {
      if (url.startsWith("http")) {
        return url;
      } else if (url.startsWith("/uploads/avatars")) {
        final String baseUrl = "https://api.hadith-shareef.com/";
        return '$baseUrl/api$url';
      }
    }

    return defaultAvatar;
  }
}

class AvatarSection extends StatelessWidget {
  final File? selectedImageFile;
  final String? avatarUrl;
  final Future<void> Function(ImageSource source) onPickImage;

  const AvatarSection({
    super.key,
    required this.selectedImageFile,
    required this.avatarUrl,
    required this.onPickImage,
  });

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(onPickImage: onPickImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (selectedImageFile != null) {
      imageProvider = FileImage(selectedImageFile!);
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(avatarUrl!);
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: ProfileDecorations.avatarShadow(),
          ),
          child: CircleAvatar(
            radius: 60.r,
            backgroundImage: imageProvider,
            backgroundColor: Colors.grey[200],
            child:
                imageProvider == null
                    ? Icon(Icons.person, size: 60.r, color: Colors.grey)
                    : null,
          ),
        ),
        SizedBox(height: 12.h),
        IconButton(
          onPressed: () => _openPicker(context),
          icon: const Icon(Icons.camera_alt),
          color: Colors.white,
          iconSize: 26.sp,
        ),
      ],
    );
  }
}

class AvatarPickerSheet extends StatelessWidget {
  final Future<void> Function(ImageSource source) onPickImage;

  const AvatarPickerSheet({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: ProfileDecorations.avatarPickerSheet(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOption(
            context,
            FontAwesomeIcons.camera,
            "التقاط صورة",
            () => onPickImage(ImageSource.camera),
          ),
          _buildOption(
            context,
            FontAwesomeIcons.image,
            "من المعرض",
            () => onPickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ColorsManager.primaryPurple, size: 28.sp),
          SizedBox(height: 8.h),
          Text(text, style: ProfileTextStyles.avatarPickerOption),
        ],
      ),
    );
  }
}

class UsernameSection extends StatelessWidget {
  final TextEditingController controller;

  const UsernameSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: ProfileTextStyles.usernameFieldText,
      decoration: ProfileDecorations.usernameFieldDecoration(),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String? email;
  final String createdAt;
  final int achievements;

  const InfoCard({
    super.key,
    this.email,
    required this.createdAt,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("البريد الإلكتروني", email ?? "غير محدد"),
            Divider(height: 20.h),
            _buildInfoRow("تاريخ الإنشاء", createdAt),
            Divider(height: 20.h),
            _buildInfoRow("الإنجازات الأسبوعية", achievements.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Icon(Icons.info, size: 18.sp, color: ColorsManager.primaryPurple),
        SizedBox(width: 8.w),
        Expanded(
          child: Text("$title: $value", style: ProfileTextStyles.infoCardText),
        ),
      ],
    );
  }
}
