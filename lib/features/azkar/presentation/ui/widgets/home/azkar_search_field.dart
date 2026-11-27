import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';

/// Searches chapter titles and the azkar themselves as the reader types.
class AzkarSearchField extends StatefulWidget {
  const AzkarSearchField({super.key});

  @override
  State<AzkarSearchField> createState() => _AzkarSearchFieldState();
}

class _AzkarSearchFieldState extends State<AzkarSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = context.read<AzkarHomeCubit>().state;
    _controller = TextEditingController(
      text: current is AzkarHomeLoaded ? current.query : '',
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
      hintText: 'ابحث في الأذكار والأدعية…',
      onChanged: context.read<AzkarHomeCubit>().search,
    );
  }
}
