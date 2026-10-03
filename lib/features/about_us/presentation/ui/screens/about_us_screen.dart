import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/about_us/presentation/ui/widgets/build_mishkat_inf_section.dart';
import 'package:mishkat_almasabih/features/about_us/presentation/ui/widgets/who_are_we.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body: CustomScrollView(

            slivers: [
              SliverToBoxAdapter(child: WhoAreWe()),
              BuildMishkatInfSection(),
            ],
          ),
        ),
      ),
    );
  }
}
