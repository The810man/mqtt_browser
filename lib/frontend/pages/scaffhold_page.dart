import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/pages/tree_view_page.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/single_node_view.dart';
import 'package:mqtt_browser/frontend/widgets/sidebar_widget.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/tree_tab_widget.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart';

class ScaffoldPage extends ConsumerStatefulWidget {
  const ScaffoldPage({super.key});

  @override
  ConsumerState<ScaffoldPage> createState() => _ScaffholdPageState();
}

class _ScaffholdPageState extends ConsumerState<ScaffoldPage>
    with TickerProviderStateMixin {
  final SidebarXController sidebarController = SidebarXController(
    selectedIndex: 0,
    extended: true,
  );
  final sideBarScaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabController;
  int tabLength = 1;

  void resetProviders() {
    ref.read(tabListProvider.notifier).state = [];
    ref.read(tabLengthProvider.notifier).state = 1;
    ref.read(tabIndexProvider.notifier).state = 0;
    ref.read(rootProvider.notifier).state = TreeNode(label: 'root');
    ref.read(currentRootProvider.notifier).state = ref.read(rootProvider);
    ref.read(tabDataProvider.notifier).state = {};
    ref.read(treeNodesProvider.notifier).state = {};
    ref.read(selectedItemProvider.notifier).state = {};
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(tabLengthProvider.notifier);
      notifier.state = notifier.state.toInt();

      tabController = TabController(length: notifier.state, vsync: this);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        tabLength = ref.watch(tabLengthProvider);
        final tabList = ref.watch(tabListProvider);
        final root = ref.watch(rootProvider);
        final effectiveTabList = tabList.isEmpty ? [root] : tabList;
        final effectiveLength = effectiveTabList.length;
        if (tabController.length != effectiveLength) {
          tabController.dispose();
          tabController = TabController(
            length: effectiveLength,
            vsync: this,
            initialIndex: 0,
          );
        }
        if (tabList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(tabListProvider.notifier).state = effectiveTabList;
            ref.read(tabLengthProvider.notifier).state =
                effectiveTabList.length;
            ref.read(currentRootProvider.notifier).state = root;
          });
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          key: sideBarScaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.95),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                sideBarScaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  disconnectClient(ref.watch(clientProvider));
                  ref.read(mqttClientProvider.notifier).state =
                      MqttConnectionState.disconnected;
                  ref.read(isConnectedProvider.notifier).state = false;
                  ref.read(clientProvider.notifier).state = null;
                  resetProviders();
                  ref.watch(routerProvider).refresh();
                  ref.watch(routerProvider).pushNamed("setUpPage");
                },
                child: const Text("Disconnect"),
              ),
            ],
            title: TabBar(
              controller: tabController,
              enableFeedback: true,
              indicatorColor: Theme.of(context).colorScheme.onPrimary,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.7),
              onTap: (value) {
                ref.read(currentRootProvider.notifier).state =
                    effectiveTabList[value];
              },
              isScrollable: true,
              tabs: [
                for (final tab in effectiveTabList)
                  Treetabwidget(
                    tab: tab,
                    unSelectedIcon: const Icon(Icons.account_tree_rounded),
                    selectedWidget: const SizedBox(),
                    text: tab.label.toString(),
                  ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final tab in effectiveTabList)
                tab.label == root.label ? TreeViewPage() : Singlenodeview(),
            ],
          ),
          drawer: Sidebarwidget(controller: sidebarController),
        );
      },
    );
  }
}
