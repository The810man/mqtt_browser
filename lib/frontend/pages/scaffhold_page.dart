import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/pages/tree_view_page.dart';
import 'package:mqtt_browser/frontend/responsive.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/single_node_view.dart';
import 'package:mqtt_browser/frontend/widgets/sidebar_widget.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/tree_tab_widget.dart';

class ScaffoldPage extends HookConsumerWidget {
  const ScaffoldPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabList = ref.watch(tabListProvider);
    final root = ref.watch(rootProvider);
    final tabIndex = ref.watch(tabIndexProvider);
    final effectiveTabs = tabList.isEmpty ? [root] : tabList;
    final mobile = isMobile(context);

    final tabController = useTabController(
      initialLength: effectiveTabs.length,
      initialIndex: min(tabIndex, max(0, effectiveTabs.length - 1)),
      keys: [effectiveTabs.length],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (tabController.index != tabIndex &&
            tabIndex < effectiveTabs.length) {
          tabController.animateTo(tabIndex, duration: Duration.zero);
        }
      });
      return null;
    }, [tabIndex, tabController]);

    final sidebarController = useMemoized(
      () => SidebarXController(selectedIndex: 0, extended: true),
    );
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    void resetProviders() {
      ref.read(tabListProvider.notifier).set([]);
      ref.read(tabLengthProvider.notifier).set(1);
      ref.read(tabIndexProvider.notifier).set(0);
      ref.read(rootProvider.notifier).set(TreeNode(label: 'root'));
      ref.read(currentRootProvider.notifier).set(ref.read(rootProvider));
      ref.read(tabDataProvider.notifier).set({});
      ref.read(treeNodesProvider.notifier).set({});
      ref.read(selectedItemProvider.notifier).set({});
    }

    final tabBar = TabBar(
      controller: tabController,
      enableFeedback: true,
      indicatorColor: Theme.of(context).colorScheme.onPrimary,
      labelColor: Theme.of(context).colorScheme.onPrimary,
      unselectedLabelColor:
          Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
      onTap: (value) {
        ref.read(tabIndexProvider.notifier).set(value);
        ref.read(currentRootProvider.notifier).set(effectiveTabs[value]);
      },
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        for (final tab in effectiveTabs)
          Treetabwidget(
            tab: tab,
            unSelectedIcon: const Icon(Icons.account_tree_rounded),
            selectedWidget: const SizedBox(),
            text: tab.label,
          ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: mobile ? 52 : 60,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.95),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Tree settings',
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: mobile
            ? Text(
                effectiveTabs.isNotEmpty ? effectiveTabs[tabIndex < effectiveTabs.length ? tabIndex : 0].label : 'MQTT Browser',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              )
            : tabBar,
        actions: [
          if (mobile)
            IconButton(
              icon: const Icon(Icons.tab),
              tooltip: 'Switch tab',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => _TabSwitcher(
                    tabs: effectiveTabs,
                    currentIndex: tabIndex,
                    tabController: tabController,
                    onSelect: (i) {
                      ref.read(tabIndexProvider.notifier).set(i);
                      ref.read(currentRootProvider.notifier).set(effectiveTabs[i]);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 8 : 16,
                vertical: mobile ? 4 : 8,
              ),
            ),
            onPressed: () async {
              await ref.read(mqttClientProvider.notifier).disconnect();
              resetProviders();
              ref.read(routerProvider).pushNamed('setUpPage');
            },
            child: Text(
              mobile ? 'Quit' : 'Disconnect',
              style: TextStyle(fontSize: mobile ? 12 : 14),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: mobile ? null : null,
      ),
      body: Column(
        children: [
          if (mobile)
            Material(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
              child: tabBar,
            ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final tab in effectiveTabs)
                  tab.label == root.label ? const TreeViewPage() : Singlenodeview(),
              ],
            ),
          ),
        ],
      ),
      drawer: Sidebarwidget(controller: sidebarController),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({
    required this.tabs,
    required this.currentIndex,
    required this.tabController,
    required this.onSelect,
  });

  final List<TreeNode> tabs;
  final int currentIndex;
  final TabController tabController;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Open Tabs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tabs.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.account_tree_rounded),
                title: Text(tabs[i].label),
                selected: i == currentIndex,
                onTap: () => onSelect(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
