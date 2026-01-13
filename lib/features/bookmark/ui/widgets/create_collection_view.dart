import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/add_button.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/dialog_header.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/input_label.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/styled_text_field.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';

class CreateCollectionView extends StatefulWidget {
  final String bookName;
  final String bookSlug;
  final String chapter;
  final String hadithNumber;
  final String hadithText;
  final VoidCallback onBack;

  const CreateCollectionView({
    super.key,
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
    required this.hadithText,
    required this.onBack,
  });

  @override
  State<CreateCollectionView> createState() => _CreateCollectionViewState();
}

class _CreateCollectionViewState extends State<CreateCollectionView> {
  final TextEditingController collectionNameController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    collectionNameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorsManager.primaryText,
                ),
              ),
              const Expanded(child: DialogHeader(title: "إنشاء مجموعة جديدة")),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "قم بإنشاء مجموعة جديدة لتنظيم إشاراتك المرجعية",
            textAlign: TextAlign.center,
            style: BookmarkTextStyles.sectionDescription,
          ),
          const SizedBox(height: 24),

          InputLabel("اسم المجموعة *"),
          const SizedBox(height: 8),
          StyledTextField(
            controller: collectionNameController,
            hint: "مثال: أحاديث الصلاة",
            maxLines: 1,
          ),
          const SizedBox(height: 16),

          InputLabel("ملاحظات (اختياري)"),
          const SizedBox(height: 8),
          StyledTextField(
            controller: notesController,
            hint: "أدخل ملاحظاتك هنا...",
            maxLines: 3,
          ),
          SizedBox(height: 28.h),
          AddCreationButton(
            bookName: widget.bookName,
            bookSlug: widget.bookSlug,
            chapter: widget.chapter,
            hadithNumber: widget.hadithNumber,
            hadithText: widget.hadithText,
            notesController: notesController,
            collection: collectionNameController
          ),
        ],
      ),
    );
  }
}
