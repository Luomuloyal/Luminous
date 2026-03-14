import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/mine.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  final UserController _userController = Get.find<UserController>();

  Future<void> _onTapProfile() async {
    if (!_userController.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    ToastUtils.instance.show(context, '功能开发中');
  }

  Future<void> _onTapAction() async {
    if (!_userController.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _userController.logout();
    if (mounted) {
      ToastUtils.instance.show(context, '已退出登录');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F7FB),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Obx(
            () => MineProfileCard(
              user: _userController.user.value,
              onTapProfile: _onTapProfile,
              onTapAction: _onTapAction,
            ),
          ),
        ),
      ),
    );
  }
}
