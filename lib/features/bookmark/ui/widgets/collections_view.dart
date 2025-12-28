import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/add_button_old.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/collection_choice_chips.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/dialog_header.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/input_label.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/styled_text_field.dart';

class CollectionsView extends StatelessWidget {
  final String bookName;
  final String bookSlug;
  final String chapter;
  final String hadithNumber;
  final String hadithText;

  final TextEditingController notesController;
  final void Function(String) onCollectionSelected;
  final String selectedCollection;
  final VoidCallback onCreateNewPressed;

  const CollectionsView({
    super.key,
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
    required this.hadithText,
    required this.notesController,
    required this.onCollectionSelected,
    required this.selectedCollection,
    required this.onCreateNewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GetCollectionsBookmarkCubit,
      GetCollectionsBookmarkState
    >(
      builder: (context, state) {
        if (state is GetCollectionsBookmarkLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetCollectionsBookmarkError) {
          return Center(child: Text("خطأ: ${state.errMessage}"));
        } else if (state is GetCollectionsBookmarkSuccess) {
          final collections = state.collectionsResponse.collections;
          final uniqueCollections =
              collections!
                  .where(
                    (c) => c.collection != null && c.collection!.isNotEmpty,
                  )
                  .map((c) => c.collection!)
                  .toSet()
                  .toList();

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DialogHeader(title: "إضافة للمفضلة"),
                const SizedBox(height: 8),
                Text(
                  "اختر مجموعة من الإشارات المرجعية",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColorsManager.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                CollectionsChoiceChips(
                  collections: uniqueCollections,
                  selectedCollection: selectedCollection,
                  onSelected: onCollectionSelected,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorsManager.primaryPurple.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: onCreateNewPressed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: ColorsManager.primaryPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "إنشاء مجموعة جديدة",
                            style: TextStyle(
                              color: ColorsManager.primaryPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputLabel("ملاحظات (اختياري)"),
                const SizedBox(height: 6),
                StyledTextField(
                  controller: notesController,
                  hint: "أدخل ملاحظاتك هنا",
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                AddButton(
                  bookName: bookName,
                  bookSlug: bookSlug,
                  chapter: chapter,
                  hadithNumber: hadithNumber,
                  hadithText: hadithText,
                  notesController: notesController,
                  collection: selectedCollection,
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
