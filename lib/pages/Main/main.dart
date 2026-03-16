import 'package:flutter/material.dart';
import 'package:luminous/pages/Album/album.dart';
import 'package:luminous/pages/Drug/drug.dart';
import 'package:luminous/pages/Home/home.dart';
import 'package:luminous/pages/Mine/mine.dart';

// 主页面：底部 Tab 容器
//
// 注意：
// - 这里用 IndexedStack 保持每个 Tab 的状态（避免切换时重复 initState）
// - 不要在这里再包 SafeArea（单页自己负责），否则容易出现双重 padding
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  /// 创建底部 Tab 主页面对应的状态对象。
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 底部导航栏配置列表。
  ///
  /// 每一项包含：
  /// - 默认图标路径；
  /// - 选中图标路径；
  /// - 展示文本。
  final List<Map<String, String>> _tablist = [
    {
      "icon": "lib/assets/home.png",
      "icon-full": "lib/assets/home-full.png",
      "text": "主页",
    },
    {
      "icon": "lib/assets/drug.png",
      "icon-full": "lib/assets/drug-full.png",
      "text": "药品",
    },
    {
      "icon": "lib/assets/picture.png",
      "icon-full": "lib/assets/picture-full.png",
      "text": "相册",
    },
    {
      "icon": "lib/assets/mine.png",
      "icon-full": "lib/assets/mine-full.png",
      "text": "我的",
    },
  ];

  /// 与底部 Tab 一一对应的页面实例列表。
  ///
  /// 使用 `const` + `IndexedStack` 组合，保证切换 Tab 时页面状态不丢失。
  final List<Widget> _children = const [
    HomeView(),
    DrugView(),
    AlbumView(),
    MineView(),
  ];

  /// 根据 `_tablist` 构建 BottomNavigationBarItem 列表。
  List<BottomNavigationBarItem> _getTabBarWidget() {
    return List.generate(_tablist.length, (index) {
      return BottomNavigationBarItem(
        icon: Image.asset(_tablist[index]["icon"]!, width: 30, height: 30),
        activeIcon: Image.asset(
          _tablist[index]["icon-full"]!,
          width: 30,
          height: 30,
        ),
        label: _tablist[index]["text"],
      );
    });
  }

  /// 当前选中的底部 Tab 下标。
  int _currentIndex = 0;

  /// 构建主页面 UI。
  ///
  /// 上半部分使用 `IndexedStack` 承载四个一级页面，
  /// 下半部分使用 `BottomNavigationBar` 负责切换。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _children),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          /// 更新当前选中的 Tab 下标。
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        items: _getTabBarWidget(),
        selectedItemColor: Colors.black,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
