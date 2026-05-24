import 'package:get/get.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';

/// 全局用户态控制器（仅作向后兼容的只读层）。
///
/// 保留该类仅为了未迁移至 Riverpod 的历史页面通过 `Get.find<UserController>()` 获取 userId。
/// 所有修改用户状态的操作已移交给 `AuthService` 处理。
class UserController extends GetxController {
  UserController();

  /// 当前登录用户的响应式容器。
  final Rxn<UserSafe> user = Rxn<UserSafe>();
  final RxBool sessionReady = true.obs;

  /// 当前是否处于登录状态。
  bool get isLoggedIn => user.value?.hasData ?? false;

  /// 标记当前会话仍在恢复中。
  void markSessionPending() {
    sessionReady.value = false;
  }
}
