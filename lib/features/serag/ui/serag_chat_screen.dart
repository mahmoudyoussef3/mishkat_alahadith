import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/serag_decorations.dart';
import 'package:mishkat_almasabih/core/theming/serag_styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/ui/widgets/remaining_questions_card.dart';
import 'package:mishkat_almasabih/features/serag/ui/widgets/chat_messages_list.dart';
import 'package:mishkat_almasabih/features/serag/ui/widgets/chat_input_section.dart';

class SeragChatScreen extends StatefulWidget {
  const SeragChatScreen({super.key, required this.model});
  final SeragRequestModel model;

  @override
  State<SeragChatScreen> createState() => _SeragChatScreenState();
}

class _SeragChatScreenState extends State<SeragChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: SeragDecorations.scaffoldBackground,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    BuildHeaderAppBar(
                      title: SeragTextStyles.headerTitle,
                      description: SeragTextStyles.headerDescription,
                    ),
                    SliverToBoxAdapter(child: RemainingQuestionsCard()),
                    const ChatMessagesList(),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                  ],
                ),
              ),
              ChatInputSection(
                controller: _controller,
                scrollToBottom: _scrollToBottom,
                model: widget.model,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
