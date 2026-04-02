import 'package:flutter/material.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

// 药品详情页
//
// 页面职责：
// - 展示基础信息（来自 MySQL 查询）
// - 按需获取 AI 详细信息：点击“获取更详细信息”调用后端 /medicine-ai-detail
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
        final l10n = AppLocalizations.of(context);
        ToastUtils.instance.show(
          context,
          l10n?.medicineDetailAiNoContentToast ?? 'AI接口暂无返回内容',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      if (_isLikelyNetworkFailure(e)) {
        ToastUtils.instance.showError(
          context,
          e,
          fallback:
              l10n?.medicineDetailAiNetworkErrorToast ?? '网络访问失败，请检查网络后重试',
        );
      } else {
        ToastUtils.instance.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingAi = false;
        });
      }
    }
  }

  bool _isLikelyNetworkFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('timeout') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('network') ||
        text.contains('xmlhttprequest') ||
        text.contains('failed host lookup');
  }

  /// 构建药品详情页 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AppCanvasPageScaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        title: Text(
          l10n?.medicineDetailPageTitle ?? '药品详情',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      appBarSpacing: 36,
      accentColor: scheme.primary,
      secondaryAccentColor: Color.lerp(
        scheme.secondary,
        scheme.tertiary,
        0.55,
      )!,
      child: RefreshIndicator(
        onRefresh: _loadDetail,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: scheme.primary,
      secondaryColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!,
      ornamentKey: 'medicine.header.compact',
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: loading ? null : onRefresh,
              icon: loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                loading
                    ? (l10n?.medicineDetailHeaderRefreshing ?? '更新中')
                    : (l10n?.medicineDetailHeaderRefresh ?? '刷新'),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(92, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      title: l10n?.medicineDetailInfoTitle ?? '基础信息',
      accentColor: Theme.of(context).colorScheme.primary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'medicine.info',
      child: Column(
        children: [
          _InfoRow(
            label: l10n?.medicineDetailLabelProductName ?? '产品名称',
            value: item.productName,
          ),
          _InfoRow(
            label: l10n?.medicineDetailLabelDosageForm ?? '剂型',
            value: item.dosageForm,
          ),
          _InfoRow(
            label: l10n?.medicineDetailLabelSpecification ?? '规格',
            value: item.specification,
          ),
          _InfoRow(
            label: l10n?.medicineDetailLabelApprovalNo ?? '批准文号',
            value: item.approvalNo,
          ),
          _InfoRow(
            label:
                l10n?.medicineDetailLabelMarketingAuthorizationHolder ??
                '上市许可持有人',
            value: item.marketingAuthorizationHolder,
          ),
          _InfoRow(
            label: l10n?.medicineDetailLabelManufacturer ?? '生产单位',
            value: item.manufacturer,
          ),
          _InfoRow(
            label: l10n?.medicineDetailLabelDrugCode ?? '药品编码',
            value: item.drugCode,
          ),
          _InfoRow(
            label: l10n?.medicineDetailLabelDrugCodeRemark ?? '药品编码备注',
            value: item.drugCodeRemark,
          ),
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

  /// 点击“获取更详细信息”回调。
  final VoidCallback onFetch;

  /// 构建 AI 解读卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasFetched = result != null;
    final scheme = Theme.of(context).colorScheme;

    return _SurfaceCard(
      title: l10n?.medicineDetailAiTitle ?? 'AI 智能解读',
      accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.5)!,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'medicine.ai',
      trailing: FilledButton(
        onPressed: !hasIdentity || loading ? null : onFetch,
        style: FilledButton.styleFrom(
          minimumSize: const Size(110, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.onPrimary,
                ),
              )
            : Text(
                hasFetched
                    ? (l10n?.medicineDetailAiRefetch ?? '再次获取')
                    : (l10n?.medicineDetailAiFetch ?? '获取更详细信息'),
              ),
      ),
      child: result == null || !result!.hasText
          ? Text(
              l10n?.medicineDetailAiPlaceholder ??
                  '点击“获取更详细信息”后，后端会调用 AI 模型补充数据库里未保存的说明书信息，例如成分、禁忌、注意事项等。',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              result!.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: scheme.onSurface,
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
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      title: l10n?.medicineDetailSafetyTitle ?? '安全提示',
      accentColor: Theme.of(context).colorScheme.tertiary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'medicine.disclaimer',
      child: Text(
        l10n?.medicineDetailSafetyDisclaimer ??
            AppI18nText.pick(
              zh: '本应用信息仅用于健康科普与辅助查询，不能替代医生诊断与处方。如有不适或正在用药，请遵医嘱并咨询专业人士。',
              en: 'This app provides health education and supportive lookup only, and does not replace diagnosis or prescriptions. If you feel unwell or are taking medication, follow medical advice and consult professionals.',
            ),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.55,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  const _SurfaceCard({
    required this.title,
    required this.child,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
    this.trailing,
  });

  /// 卡片标题。
  final String title;

  /// 卡片主体内容。
  final Widget child;

  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;

  /// 右上角 trailing 区域（可选），例如按钮。
  final Widget? trailing;

  /// 构建表面卡片 UI。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeader =
                trailing != null && constraints.maxWidth < 420;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compactHeader) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  trailing!,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ],
                    ],
                  ),
                const SizedBox(height: 10),
                child,
              ],
            );
          },
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
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 320;
        if (compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.2,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 116,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
