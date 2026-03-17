import 'package:flutter/material.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

// 药品详情页
//
// 页面职责：
// - 展示基础信息（来自 MySQL 查询）
// - 预留 AI 详细信息 UI：点击“获取详细信息”调用后端 /medicine-ai-detail
//
// 设计注意：
// - 详情与 AI 是两个请求：detail 用于补齐基础信息，ai-detail 用于后续扩展
// - AI 内容是高风险区域：后续接入时应加免责声明、过滤与超时策略（后端更关键）
/// 药品详情页。
///
/// 用于展示基础药品信息，并在用户需要时进一步拉取 AI 解读内容。
class MedicineDetailPage extends StatefulWidget {
  /// 创建药品详情页，并指定初始药品对象。
  ///
  /// 初始对象可能来自列表点击，字段不一定完整，页面会在 `initState` 再拉取一次详情补齐。
  const MedicineDetailPage({super.key, required this.initialItem});

  /// 详情页的初始药品对象。
  ///
  /// 通常来自列表页/搜索页的点击结果，字段可能不完整，页面会再调用详情接口补齐。
  final MedicineItem initialItem;

  /// 创建详情页对应的状态对象。
  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

/// 药品详情页状态对象。
///
/// 同时维护“基础详情”与“AI 解读”两条独立请求链路，避免二者互相阻塞。
class _MedicineDetailPageState extends State<MedicineDetailPage> {
  /// 当前展示的药品对象。
  ///
  /// 初始值来自 `widget.initialItem`，当详情接口返回更完整的数据后会覆盖更新。
  late MedicineItem _item;

  /// 是否正在加载基础详情数据。
  bool _loadingDetail = false;

  /// AI 解读接口返回的结果。
  MedicineAiDetailResult? _aiResult;

  /// 是否正在请求 AI 解读内容。
  bool _loadingAi = false;

  /// 初始化时设置初始药品对象，并尝试加载基础详情。
  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    _loadDetail();
  }

  /// 加载药品基础详情信息。
  ///
  /// - 如果当前药品不具备身份字段（drugCode/approvalNo），则不发起请求；
  /// - 请求成功后会用返回值覆盖 `_item`，补齐字段。
  Future<void> _loadDetail() async {
    if (_loadingDetail || !_item.hasIdentity) {
      return;
    }
    setState(() {
      _loadingDetail = true;
    });
    try {
      final response = await MedicineApi.fetchDetail(
        drugCode: _item.drugCode,
        approvalNo: _item.approvalNo,
      );
      if (!mounted) {
        return;
      }
      if (response.result.productName.isNotEmpty) {
        setState(() {
          _item = response.result;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _loadingDetail = false;
        });
      }
    }
  }

  /// 加载药品的 AI 解读内容。
  ///
  /// 该请求独立于基础详情请求，用户点击按钮时才触发。
  Future<void> _loadAiDetail() async {
    if (_loadingAi || !_item.hasIdentity) {
      return;
    }
    setState(() {
      _loadingAi = true;
    });
    try {
      final response = await MedicineApi.fetchAiDetail(
        drugCode: _item.drugCode,
        approvalNo: _item.approvalNo,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _aiResult = response.result;
      });
      if (!_aiResult!.hasText) {
        ToastUtils.instance.show(context, 'AI接口暂无返回内容');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _loadingAi = false;
        });
      }
    }
  }

  /// 构建药品详情页 UI。
  @override
  Widget build(BuildContext context) {
    /// AppBar 使用的标题文案。
    final title = _item.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _HeaderCard(
            item: _item,
            loading: _loadingDetail,
            onRefresh: _loadDetail,
          ),
          const SizedBox(height: 12),
          _InfoCard(item: _item),
          const SizedBox(height: 12),
          _AiCard(
            hasIdentity: _item.hasIdentity,
            loading: _loadingAi,
            result: _aiResult,
            onFetch: _loadAiDetail,
          ),
          const SizedBox(height: 12),
          const _DisclaimerCard(),
        ],
      ),
    );
  }
}

/// 详情页顶部基础信息卡片。
///
/// 展示药品名称、规格信息与关键身份字段（批准文号/药品编码），并提供“刷新”按钮。
class _HeaderCard extends StatelessWidget {
  /// 创建详情页顶部基础信息卡片。
  const _HeaderCard({
    required this.item,
    required this.loading,
    required this.onRefresh,
  });

  /// 当前药品对象。
  final MedicineItem item;

  /// 是否正在加载基础详情（用于禁用刷新并展示进度）。
  final bool loading;

  /// 点击刷新回调。
  final VoidCallback onRefresh;

  /// 构建顶部基础信息卡片 UI。
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0EA5E9),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.displaySubtitle,
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (item.approvalNo.isNotEmpty)
                      _pill(label: '批准文号', value: item.approvalNo),
                    if (item.drugCode.isNotEmpty)
                      _pill(label: '药品编码', value: item.drugCode),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: loading ? null : onRefresh,
            icon: loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('刷新'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              foregroundColor: Colors.white,
              minimumSize: const Size(86, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 渲染顶部卡片中的信息 pill（例如批准文号/药品编码）。
  Widget _pill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 详情页“基础信息”卡片。
class _InfoCard extends StatelessWidget {
  /// 创建详情页“基础信息”卡片。
  const _InfoCard({required this.item});

  /// 当前药品对象。
  final MedicineItem item;

  /// 构建基础信息卡片 UI。
  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      title: '基础信息',
      child: Column(
        children: [
          _InfoRow(label: '产品名称', value: item.productName),
          _InfoRow(label: '剂型', value: item.dosageForm),
          _InfoRow(label: '规格', value: item.specification),
          _InfoRow(label: '批准文号', value: item.approvalNo),
          _InfoRow(label: '上市许可持有人', value: item.marketingAuthorizationHolder),
          _InfoRow(label: '生产单位', value: item.manufacturer),
          _InfoRow(label: '药品编码', value: item.drugCode),
          _InfoRow(label: '药品编码备注', value: item.drugCodeRemark),
        ],
      ),
    );
  }
}

/// 详情页“AI 智能解读”卡片。
class _AiCard extends StatelessWidget {
  /// 创建详情页“AI 智能解读”卡片。
  const _AiCard({
    required this.hasIdentity,
    required this.loading,
    required this.result,
    required this.onFetch,
  });

  /// 是否具备身份字段（用于决定按钮是否可点击）。
  final bool hasIdentity;

  /// 是否正在加载 AI 解读内容。
  final bool loading;

  /// AI 解读结果。
  final MedicineAiDetailResult? result;

  /// 点击“获取详细信息”回调。
  final VoidCallback onFetch;

  /// 构建 AI 解读卡片 UI。
  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      title: 'AI 智能解读',
      trailing: FilledButton(
        onPressed: !hasIdentity || loading ? null : onFetch,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          foregroundColor: Colors.white,
          minimumSize: const Size(110, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('获取详细信息'),
      ),
      child: result == null || !result!.hasText
          ? const Text(
              '点击“获取详细信息”后将由后端调用腾讯云智能问药能力，返回更详细的用法用量、禁忌、相互作用等内容。',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              result!.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// 详情页底部免责声明卡片。
class _DisclaimerCard extends StatelessWidget {
  /// 创建详情页底部免责声明卡片。
  const _DisclaimerCard();

  /// 构建免责声明卡片 UI。
  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      title: '安全提示',
      child: const Text(
        '本应用信息仅用于健康科普与辅助查询，不能替代医生诊断与处方。'
        '如有不适或正在用药，请遵医嘱并咨询专业人士。',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.55,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 详情页统一使用的白色表面卡片容器。
///
/// 用于保持“基础信息/AI 解读/免责声明”等区域的视觉一致性。
class _SurfaceCard extends StatelessWidget {
  /// 创建详情页统一使用的白色表面卡片容器。
  const _SurfaceCard({required this.title, required this.child, this.trailing});

  /// 卡片标题。
  final String title;

  /// 卡片主体内容。
  final Widget child;

  /// 右上角 trailing 区域（可选），例如按钮。
  final Widget? trailing;

  /// 构建表面卡片 UI。
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                ...?(trailing == null ? null : <Widget>[trailing!]),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// “基础信息”卡片中的一行字段展示。
class _InfoRow extends StatelessWidget {
  /// 创建“基础信息”卡片中的单行字段展示。
  const _InfoRow({required this.label, required this.value});

  /// 字段名称。
  final String label;

  /// 字段值。
  final String value;

  /// 构建字段行 UI。
  @override
  Widget build(BuildContext context) {
    /// 经过兜底处理的展示文本。
    final text = value.trim().isEmpty ? '-' : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
