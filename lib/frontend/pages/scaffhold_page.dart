import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/pages/tree_view_page.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/single_node_view.dart';
import 'package:mqtt_browser/frontend/widgets/sidebar_widget.dart';
import 'package:mqtt_browser/main.dart';
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
  final SidebarXController sidebarController =
      SidebarXController(selectedIndex: 0, extended: true);
  final sideBarScaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabController;
  int tabLength = 1;

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
    final length = ref.watch(tabLengthProvider);
    tabController = TabController(length: length, vsync: this, initialIndex: 0);
    return Consumer(builder: (context, ref, child) {
      tabLength = ref.watch(tabLengthProvider);
      final tabList = ref.watch(tabListProvider);
      final root = ref.watch(rootProvider);
      return Scaffold(
        key: sideBarScaffoldKey,
        appBar: AppBar(
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
            onTap: (value) {
              ref.read(currentRootProvider.notifier).state = tabList[value];
            },
            isScrollable: true,
            tabs: [
              for (final tab in tabList)
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
            for (final tab in tabList)
              tab.label == root.label ? TreeViewPage() : Singlenodeview(),
          ],
        ),
        drawer: Sidebarwidget(controller: sidebarController),
      );
    });
  }
}
