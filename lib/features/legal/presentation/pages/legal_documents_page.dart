import 'package:flutter/material.dart';
import 'package:luminous/l10n/app_localizations.dart';

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

List<_LegalSection> _buildUserAgreementSections(AppLocalizations? l10n) {
  return [
    _LegalSection(
      title: l10n?.legalUserAgreementSection1Title ?? '1. 协议适用范围',
      body:
          l10n?.legalUserAgreementSection1Body ??
          '本协议适用于你使用 Luminous 健康助手应用所提供的健康记录、药品查询、AI 辅助分析、提醒管理等功能。你在注册、登录或继续使用应用时，视为已阅读并同意本协议内容。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection2Title ?? '2. 服务说明',
      body:
          l10n?.legalUserAgreementSection2Body ??
          '本应用提供的是健康信息整理与辅助参考服务，不构成诊断、处方或医疗建议。涉及用药、过敏、孕期、慢病管理等高风险事项时，请务必以医生、药师或正规说明书意见为准。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection3Title ?? '3. 账号与安全',
      body:
          l10n?.legalUserAgreementSection3Body ??
          '你应妥善保管自己的登录信息，不得借用、出租或转让账号。因你主动泄露账号信息、在不安全设备登录、或未及时退出所导致的风险，由你自行承担。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection4Title ?? '4. 使用规范',
      body:
          l10n?.legalUserAgreementSection4Body ??
          '你不得利用本应用从事违法违规行为，包括但不限于伪造身份、上传恶意内容、批量抓取接口、干扰服务稳定性、传播虚假医疗信息等。若存在异常使用行为，平台有权限制相关功能。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection5Title ?? '5. AI 内容说明',
      body:
          l10n?.legalUserAgreementSection5Body ??
          '应用中的 AI 解读、识别结果、安全辅助等内容，会受到模型能力、输入图片质量、药品信息完整度等因素影响，可能出现偏差、遗漏或不适用情形。你应结合药品说明书和专业意见独立判断。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection6Title ?? '6. 免责声明',
      body:
          l10n?.legalUserAgreementSection6Body ??
          '对于因网络中断、第三方服务异常、用户输入错误、设备兼容性问题或不可抗力导致的服务中断、结果偏差或数据延迟，我们会尽力修复，但不对由此产生的直接或间接损失承担医疗责任。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection7Title ?? '7. 协议更新',
      body:
          l10n?.legalUserAgreementSection7Body ??
          '随着功能迭代，协议内容可能调整。更新后的协议会在应用内展示；你继续使用应用即视为接受更新后的协议。如你不同意更新内容，应停止使用相关服务。',
    ),
  ];
}

List<_LegalSection> _buildPrivacyPolicySections(AppLocalizations? l10n) {
  return [
    _LegalSection(
      title: '1. 政策说明与适用范围',
      body:
          '欢迎您访问我们的产品。Luminous 是由落幕 Loyal 开发并运营的免费服务。'
          '\n\n'
          '确保用户的数据安全和隐私保护是我们的首要任务。本隐私政策载明了您访问和使用产品与服务时所收集的数据及其处理方式。'
          '\n\n'
          '请您在继续使用产品前，认真阅读并确认充分理解本隐私政策全部规则和要点。一旦您选择使用，即视为您同意本隐私政策的全部内容；如您不同意相关协议或其中任何条款，应停止使用我们的产品和服务。'
          '\n\n'
          '本隐私政策主要帮助您了解以下内容：'
          '\n'
          '• 我们如何收集和使用您的个人信息；'
          '\n'
          '• 我们如何存储和保护您的个人信息；'
          '\n'
          '• 我们如何共享、转让、公开披露您的个人信息。',
    ),
    _LegalSection(
      title: '2. 我们如何收集和使用您的个人信息',
      body:
          '个人信息是指以电子或者其他方式记录的，能够单独或者与其他信息结合识别特定自然人身份或者反映特定自然人活动情况的各种信息。'
          '\n\n'
          '我们根据《中华人民共和国网络安全法》《信息安全技术个人信息安全规范》（GB/T 35273-2017）以及其他相关法律法规要求，严格遵循正当、合法、必要原则，在您使用我们提供的服务或产品过程中，收集和使用您的个人信息，包括但不限于邮箱等。'
          '\n\n'
          '您所提供的相关信息，均来自您本人在注册、登录或使用产品时主动提供的数据。',
    ),
    _LegalSection(
      title: '3. 我们如何存储和保护您的个人信息',
      body:
          '作为一般规则，我们仅在实现信息收集目的所需的时间内保留您的个人信息。出于遵守法律义务、证明某项权利，或满足适用诉讼时效要求等目的，我们可能需要在上述期限届满后继续保留相关信息，并且无法完全按您的要求立即删除。'
          '\n\n'
          '当您的个人信息对于我们的法定义务、法定时效或档案目的不再必要时，我们会确保将其完全删除或匿名化。若您确认不再使用产品和服务，并按照要求主动注销账户，所有相关信息将被完全删除。'
          '\n\n'
          '我们使用符合业界标准的安全防护措施保护您提供的个人信息，并对关键数据进行加密，防止其遭到未经授权访问、公开披露、使用、修改、损坏或丢失。我们会使用受信赖的保护机制防止数据遭到恶意攻击。'
          '\n\n'
          '为了进一步加强隐私保护，我们在部分数据收集时已进行了脱敏处理，即使在内部数据库中，也不会以明文形式存储具有关联性的隐私数据。',
    ),
    _LegalSection(
      title: '4. 您的权利（GDPR / CCPA）',
      body:
          '根据您所在的司法管辖区，您可能享有以下权利：'
          '\n'
          '• 访问我们持有的关于您的个人信息；'
          '\n'
          '• 请求更正或删除您的数据；'
          '\n'
          '• 反对某些类型的处理。',
    ),
    _LegalSection(
      title: '5. 我们如何共享、转让、公开披露您的个人信息',
      body:
          '在管理日常业务活动、并为更好服务客户所必需时，我们会在合法、合规、适当的范围内使用您的个人信息。基于业务和产品服务的综合考虑，我们原则上仅在自身范围内使用这些数据，不与无关第三方分享。'
          '\n\n'
          '我们也可能依据法律法规规定，或按政府主管部门的强制性要求，对外共享您的个人信息。在符合法律法规的前提下，当我们收到此类请求时，会要求对方提供相应的法律文件，如传票、调查函等。'
          '\n\n'
          '在以下情形中，共享、转让、公开披露您的个人信息无需事先征得您的授权同意：'
          '\n'
          '• 与国家安全、国防安全直接相关的；'
          '\n'
          '• 与犯罪侦查、起诉、审判和判决执行等直接相关的；'
          '\n'
          '• 出于维护您或其他个人的生命、财产等重大合法权益但又很难得到本人同意的；'
          '\n'
          '• 您自行向社会公众公开的个人信息；'
          '\n'
          '• 从合法公开披露的信息中收集的个人信息，例如合法新闻报道、政府信息公开等渠道；'
          '\n'
          '• 根据个人信息主体要求签订和履行合同所必需的；'
          '\n'
          '• 用于维护所提供产品或服务的安全稳定运行所必需的，例如发现、处置故障；'
          '\n'
          '• 法律法规规定的其他情形。',
    ),
    _LegalSection(
      title: '6. 本隐私政策的变更',
      body:
          '我们可能会不时更新本隐私政策。建议您定期查看本页面，以了解是否有变更。'
          '\n\n'
          '如有任何更新，我们会在本页面公布新的隐私政策。'
          '\n\n'
          '该政策自 2026 年 4 月 16 日起生效。',
    ),
    _LegalSection(
      title: '7. 联系我们',
      body:
          '如您在阅读过程中对本政策有任何疑问，可通过客服或产品中的反馈方式与我们联系。'
          '\n\n'
          '联系邮箱：Luo2508015296@outlook.com'
          '\n\n'
          '我们会尽力在合理时间内回复并解决您的问题。',
    ),
  ];
}

/// 用户协议页面。
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalDocumentPage(
      title: l10n?.legalUserAgreementTitle ?? '用户协议',
      summary:
          l10n?.legalUserAgreementSummary ??
          '请在使用 Luminous 健康助手前，先了解账号、服务边界和使用规范。',
      sections: _buildUserAgreementSections(l10n),
    );
  }
}

/// 隐私政策页面。
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalDocumentPage(
      title: l10n?.legalPrivacyPolicyTitle ?? '隐私政策',
      summary: '本页面依据项目根目录中的隐私政策文本整理，供注册、登录与关于页面统一查看。',
      sections: _buildPrivacyPolicySections(l10n),
    );
  }
}

class _LegalDocumentPage extends StatelessWidget {
  const _LegalDocumentPage({
    required this.title,
    required this.summary,
    required this.sections,
  });

  final String title;
  final String summary;
  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162033) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              summary,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162033) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.body,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
