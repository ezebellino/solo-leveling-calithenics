import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/system_backdrop.dart';

class AppShellFrame extends StatelessWidget {
  const AppShellFrame({
    required this.selectedTabIndex,
    required this.previousTabIndex,
    required this.currentTab,
    required this.bottomNavigationBar,
    super.key,
  });

  final int selectedTabIndex;
  final int previousTabIndex;
  final Widget currentTab;
  final Widget bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SystemBackdrop(mode: selectedTabIndex),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              transitionBuilder: (child, animation) {
                final key = child.key;
                final isIncoming = key == ValueKey('tab-$selectedTabIndex');
                final fromRight = selectedTabIndex >= previousTabIndex;
                final begin = isIncoming
                    ? Offset(fromRight ? 0.10 : -0.10, 0)
                    : Offset(fromRight ? -0.06 : 0.06, 0);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: begin,
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey('tab-$selectedTabIndex'),
                child: currentTab,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
