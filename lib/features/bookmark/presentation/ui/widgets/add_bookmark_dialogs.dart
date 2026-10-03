import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/collections_view.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/create_collection_view.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';

class AddToFavoritesDialog extends StatefulWidget {
  const AddToFavoritesDialog({
    super.key,
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
    required this.hadithText,
    required this.id,
  });

  final String bookName;
  final String chapter;
  final String hadithNumber;
  final String hadithText;
  final String bookSlug;
  final String id;

  @override
  State<AddToFavoritesDialog> createState() => _AddToFavoritesDialogState();
}

class _AddToFavoritesDialogState extends State<AddToFavoritesDialog> {
  bool showCreateNew = false;
  String? selectedCollection; 
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GetCollectionsBookmarkCubit>().getBookMarkCollections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final dialogWidth = maxWidth > 400 ? 400.0 : maxWidth;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: ColorsManager.secondaryBackground,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          width: dialogWidth,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: showCreateNew
                      ? const Offset(1.0, 0.0)
                      : const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: child,
              );
            },
            child: showCreateNew
                ? CreateCollectionView(
                    key: const ValueKey('create'),
                    bookName: widget.bookName,
                    bookSlug: widget.bookSlug,
                    chapter: widget.chapter,
                    hadithNumber: widget.hadithNumber,
                    hadithText: widget.hadithText,
                    onBack: () {
                      setState(() {
                        showCreateNew = false;
                      });
                    },
                  )
                : CollectionsView(
                    key: const ValueKey('collections'),
                    bookName: widget.bookName,
                    bookSlug: widget.bookSlug,
                    chapter: widget.chapter,
                    hadithNumber: widget.hadithNumber,
                    hadithText: widget.hadithText,
                    notesController: notesController,
                    selectedCollection: selectedCollection ?? "",
                    onCollectionSelected: (value) =>
                        setState(() => selectedCollection = value),
                    onCreateNewPressed: () {
                      setState(() {
                        showCreateNew = true;
                      });
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  
}

}