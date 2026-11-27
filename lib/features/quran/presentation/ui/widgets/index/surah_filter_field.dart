import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';

/// Narrows the surah list by name or number as the reader types.
class SurahFilterField extends StatefulWidget {
  const SurahFilterField({super.key});

  @override
  State<SurahFilterField> createState() => _SurahFilterFieldState();
}

class _SurahFilterFieldState extends State<SurahFilterField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = context.read<QuranIndexCubit>().state;
    _controller = TextEditingController(
      text: current is QuranIndexLoaded ? current.query : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBarWidget(
      controller: _controller,
      hintText: 'ابحث باسم السورة أو رقمها…',
      onChanged: context.read<QuranIndexCubit>().filterSurahs,
    );
  }
}
