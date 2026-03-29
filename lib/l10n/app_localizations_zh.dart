// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Luminous';

  @override
  String get mainTabHome => '主页';

  @override
  String get mainTabDrug => '药品';

  @override
  String get mainTabAlbum => '相册';

  @override
  String get mainTabMine => '我的';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsGeneralTitle => '通用设置';

  @override
  String get settingsGeneralSubtitle => '可按模块进入对应设置项，后续会继续扩展更多系统偏好';

  @override
  String get settingsThemeTitle => '主题设置';

  @override
  String get settingsThemeSubtitle => '调整主题模式与主题风格，影响全局页面与组件视觉';

  @override
  String get settingsThemeEnter => '进入主题设置';

  @override
  String get settingsLanguageTitle => '语言设置';

  @override
  String get settingsLanguageSubtitle => '可自动跟随系统语言，也可手动固定应用语言';

  @override
  String get settingsLanguageEnter => '进入语言设置';

  @override
  String get languagePageTitle => '语言设置';

  @override
  String get languageSectionTitle => '应用语言';

  @override
  String get languageSectionSubtitle => '选择“跟随系统”可自动匹配设备语言，也可手动固定语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageFollowSystemSubtitle => '自动使用设备当前语言';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageChineseSubtitle => '应用文案使用中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => '应用文案使用英文';

  @override
  String get languageNote =>
      '开启“跟随系统”后，当你把系统语言从中文切到英文，应用在下次打开时会自动切换；系统在运行中变更语言时也会同步更新。';

  @override
  String get authPhoneLabel => '手机号';

  @override
  String get authEmailLabel => '邮箱';

  @override
  String get authPasswordLoginMode => '密码登录';

  @override
  String get authCodeLoginMode => '验证码登录';

  @override
  String get authPhoneRegisterMethod => '手机号注册';

  @override
  String get authEmailRegisterMethod => '邮箱注册';

  @override
  String get authSwitchToEmailLogin => '切换邮箱登录';

  @override
  String get authSwitchToPhoneLogin => '切换手机号登录';

  @override
  String get authUserAgreementTitle => '《用户协议》';

  @override
  String get authPrivacyPolicyTitle => '《隐私政策》';

  @override
  String get authLegalPrefix => '登录即代表你已阅读并同意';

  @override
  String get authLegalAnd => '和';

  @override
  String get authAgreementPrefix => '我已阅读并同意';

  @override
  String get authValidationEnterPhone => '请输入手机号';

  @override
  String get authValidationEnterEmail => '请输入邮箱';

  @override
  String get authValidationInvalidPhone => '手机号格式不正确';

  @override
  String get authValidationInvalidEmail => '邮箱格式不正确';

  @override
  String get authValidationEnterPassword => '请输入密码';

  @override
  String get authValidationPasswordRule => '密码需为6-12位字母或数字';

  @override
  String get authValidationEnterCode => '请输入验证码';

  @override
  String get authValidationCodeRule => '验证码应为6位数字';

  @override
  String get authValidationEnterConfirmPassword => '请再次输入密码';

  @override
  String get authValidationPasswordMismatch => '两次输入的密码不一致';

  @override
  String get authCodeSentSuccess => '验证码发送成功';

  @override
  String get authErrorCodeInvalid => '验证码错误，请检查后重试';

  @override
  String get authErrorCodeExpired => '验证码已过期，请重新获取';

  @override
  String get authErrorCodeRequired => '请输入验证码';

  @override
  String get authErrorIdentifierExistsLogin => '该账号已注册，请直接登录';

  @override
  String get authErrorIdentifierExistsPhoneRegistered => '手机号已经注册';

  @override
  String get authErrorIdentifierExistsEmailRegistered => '邮箱已经注册';

  @override
  String get authErrorTooFrequent => '发送过于频繁，请稍后再试';

  @override
  String get authErrorInvalidPhone => '手机号格式不正确';

  @override
  String get authErrorInvalidEmailFormat => '邮箱地址格式错误';

  @override
  String get authErrorRequestFailed => '请求失败，请稍后重试';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authPasswordHint => '6-12位字母或数字';

  @override
  String get authCodeLabel => '验证码';

  @override
  String get authCodeHint => '请输入6位验证码';

  @override
  String get authConfirmPasswordLabel => '确认密码';

  @override
  String get authConfirmPasswordHint => '请再次输入密码';

  @override
  String get authSendCode => '发送';

  @override
  String get loginHeroTitle => '健康助手';

  @override
  String loginHeroSubtitle(Object identifier, Object mode) {
    return '$identifier$mode';
  }

  @override
  String get loginForgotPasswordPending => '找回密码功能稍后补充，当前可先注册新账号或联系人工支持';

  @override
  String get loginNeedCodeForCurrentAccount => '请先获取当前账号的验证码';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get loginSuccessPartialSync => '登录成功，但部分云端数据同步失败';

  @override
  String get loginAutoRegisterTitle => '账号未注册';

  @override
  String get loginAutoRegisterPrompt => '该账号尚未注册，是否前往注册？';

  @override
  String get loginAutoRegisterCancel => '取消';

  @override
  String get loginAutoRegisterConfirm => '去注册';

  @override
  String get loginRegisterAction => '注册';

  @override
  String get loginIdentifierHintPhone => '请输入手机号';

  @override
  String get loginIdentifierHintEmail => '请输入邮箱地址';

  @override
  String get loginForgotPasswordAction => '找回密码';

  @override
  String get loginButton => '登录';

  @override
  String get loginHelperPassword => '支持手机号或邮箱搭配密码登录。';

  @override
  String get loginHelperCode => '支持手机号或邮箱验证码登录，未注册可直接去注册。';

  @override
  String get registerTopTitle => '注册';

  @override
  String get registerHeroTitle => '创建账号';

  @override
  String registerHeroSubtitle(Object identifier) {
    return '$identifier验证码注册';
  }

  @override
  String get registerNeedCodeForCurrentAccount => '请先获取当前账号的验证码';

  @override
  String get registerNeedAgreement => '请先阅读并勾选《用户协议》《隐私政策》';

  @override
  String get registerSuccess => '注册成功';

  @override
  String get registerButton => '注册';

  @override
  String get registerHelperPhone => '手机号注册只需短信验证码和密码确认。';

  @override
  String get registerHelperEmail => '邮箱注册只需邮件验证码和密码确认。';

  @override
  String get homeFeaturesTitle => '常用功能';

  @override
  String get homeFeaturesSubtitle => '快速进入核心健康服务';

  @override
  String get homeReminderTitle => '今日提醒';

  @override
  String get homeStatusSyncing => '同步中';

  @override
  String get homeStatusRelaxed => '今天较轻松';

  @override
  String get homeStatusReady => '已整理';

  @override
  String get homePillLoading => '提醒加载中...';

  @override
  String homePillCount(int count) {
    return '今日提醒 $count 条';
  }

  @override
  String get homePillTips => '健康小贴士';

  @override
  String get homeHeroTitle => '健康助手';

  @override
  String get homeHeroIntro => '今天已经为你整理好';

  @override
  String get homeSummaryTitleLoading => '正在整理提醒';

  @override
  String get homeSummaryTitleNone => '今日状态';

  @override
  String get homeSummaryTitleNext => '下一条提醒';

  @override
  String get homeSummaryDetailLoading => '正在同步今天的提醒安排，请稍等一下';

  @override
  String get homeSummaryDetailNone => '今天暂无待完成提醒，可以安心继续当前节奏';

  @override
  String get homeSummaryBadgeLoading => '同步中';

  @override
  String get homeSummaryBadgeRelaxed => '轻松日';

  @override
  String homeSummaryBadgeCount(int count) {
    return '$count 条安排';
  }

  @override
  String get homeNoReminder => '暂无提醒';

  @override
  String homeNextReminderPrefix(Object title, Object subtitle) {
    return '下一次提醒: $title · $subtitle';
  }

  @override
  String get homeFeatureDrugScanTitle => '药物识别';

  @override
  String get homeFeatureDrugScanSubtitle => '拍照识别药品';

  @override
  String get homeFeatureManualSearchTitle => '手动搜索';

  @override
  String get homeFeatureManualSearchSubtitle => '关键词查询';

  @override
  String get homeFeatureReminderTitle => '用药提醒';

  @override
  String get homeFeatureReminderSubtitle => '按时通知';

  @override
  String get homeFeatureCheckInTitle => '用药打卡';

  @override
  String get homeFeatureCheckInSubtitle => '记录服药情况';

  @override
  String get homeFeatureDrugInfoTitle => '药物信息';

  @override
  String get homeFeatureDrugInfoSubtitle => '成分与禁忌';

  @override
  String get homeFeatureSafetyTitle => '安全辅助';

  @override
  String get homeFeatureSafetySubtitle => '风险提示';

  @override
  String get homeFeatureDevelopingToast => '功能开发中';

  @override
  String get homeMedicinePickerTitle => '选择药品';

  @override
  String get homeTipsSheetTitle => '全部健康小贴士';

  @override
  String get homeTipsSheetSubtitle => '点击任意一条即可替换首页提示语';

  @override
  String get homeTip1 => '按时服药，别漏别补';

  @override
  String get homeTip2 => '饭前饭后按说明来';

  @override
  String get homeTip3 => '合并用药先问药师';

  @override
  String get homeTip4 => '漏服勿加倍，咨询放在先';

  @override
  String get homeTip5 => '出现不适，及时就医';

  @override
  String get homeTip6 => '抗生素按疗程，不要擅停';

  @override
  String get homeTip7 => '药品避光防潮，远离高温';

  @override
  String get homeTip8 => '定期清理过期药品';

  @override
  String get homeTip9 => '用药前看禁忌与相互作用';

  @override
  String get homeTip10 => '规律作息，药效更稳';

  @override
  String get homeFallbackReminder1Title => '08:30 维生素D';

  @override
  String get homeFallbackReminder1Subtitle => '早餐后服用 1 粒';

  @override
  String get homeFallbackReminder2Title => '19:30 阿莫西林';

  @override
  String get homeFallbackReminder2Subtitle => '晚餐后服用 1 粒';

  @override
  String get homeFallbackReminder3Title => '22:00 血压记录';

  @override
  String get homeFallbackReminder3Subtitle => '睡前记录并上传';

  @override
  String get reminderListTitle => '用药提醒';

  @override
  String get reminderAddButton => '新增提醒';

  @override
  String get reminderNeedLoginTitle => '请先登录';

  @override
  String get reminderNeedLoginSubtitle => '登录后可同步提醒计划，并在到点收到系统通知。';

  @override
  String get reminderNeedLoginAction => '去登录';

  @override
  String get reminderEmptyTitle => '暂无提醒';

  @override
  String get reminderEmptySubtitle => '点击右下角“新增提醒”开始设置';

  @override
  String get reminderDeleteDialogTitle => '删除提醒';

  @override
  String reminderDeleteDialogContent(Object productName, Object time) {
    return '确定要删除“$productName $time”吗？';
  }

  @override
  String get reminderDeleteCancel => '取消';

  @override
  String get reminderDeleteConfirm => '删除';

  @override
  String get reminderDeletedToast => '已删除';

  @override
  String get reminderSystemNotificationSubtitle => '系统通知提醒';

  @override
  String get reminderEditTitle => '编辑提醒';

  @override
  String get reminderCreateTitle => '新增提醒';

  @override
  String get reminderEditSectionDrugTime => '药品与时间';

  @override
  String get reminderEditSelectMedicine => '选择药品';

  @override
  String get reminderEditSelectMedicineHint => '可从“我的药品/搜索库”选择';

  @override
  String reminderEditSelectedIdentity(Object drugCode, Object approvalNo) {
    return '药品编码: $drugCode  批准文号: $approvalNo';
  }

  @override
  String reminderEditTimeTitle(Object time) {
    return '提醒时间: $time';
  }

  @override
  String get reminderEditTimeSubtitle => '每天在该时间通过系统通知提醒';

  @override
  String get reminderEditSectionContent => '提醒内容';

  @override
  String get reminderEditNameLabel => '药品名称(必填)';

  @override
  String get reminderEditSubtitleLabel => '备注(可选)';

  @override
  String get reminderEditSubtitleHint => '例如 早餐后服用 1 粒';

  @override
  String get reminderEditSectionSwitch => '开关';

  @override
  String get reminderEditEnableSwitch => '启用提醒';

  @override
  String get reminderEditSave => '保存';

  @override
  String get reminderEditTip => '提示：提醒信息仅用于辅助管理，不能替代医生处方。如有不适请及时就医。';

  @override
  String get reminderEditPickerTitle => '选择提醒药品';

  @override
  String get reminderEditNeedLogin => '请先登录';

  @override
  String get reminderEditNameRequired => '药品名称不能为空';

  @override
  String get checkInPageTitle => '用药打卡';

  @override
  String get checkInNeedLoginTitle => '请先登录';

  @override
  String get checkInNeedLoginSubtitle => '登录后可读取当前设备上的提醒计划，并在本机记录今日打卡状态。';

  @override
  String get checkInNeedLoginAction => '去登录';

  @override
  String get checkInEmptyTitle => '今日暂无提醒';

  @override
  String get checkInEmptySubtitle => '可以先到“用药提醒”里新增计划';

  @override
  String get checkInMissingIdMarkDone => '该提醒缺少 id，无法打卡';

  @override
  String get checkInMarkedDoneToast => '已记录到当前设备';

  @override
  String get checkInMissingIdMarkUndone => '该提醒缺少 id，无法切换状态';

  @override
  String get checkInUndoDialogTitle => '撤销本地打卡';

  @override
  String get checkInUndoDialogContent => '当前用药打卡只保存在本机，撤销后会立即修改当前设备显示。确定继续吗？';

  @override
  String get checkInUndoDialogCancel => '取消';

  @override
  String get checkInUndoDialogConfirm => '撤销本地打卡';

  @override
  String get checkInMarkedUndoneToast => '已改为未打卡';

  @override
  String get checkInDefaultTitle => '用药提醒';

  @override
  String get checkInCardDefaultSubtitle => '请按时完成';

  @override
  String get checkInActionDone => '取消打卡';

  @override
  String get checkInActionUndone => '打卡';

  @override
  String get mineQuickReminderTitle => '今日提醒';

  @override
  String get mineQuickReminderSubtitle => '查看计划';

  @override
  String get mineQuickSearchTitle => '手动搜索';

  @override
  String get mineQuickSearchSubtitle => '药品信息';

  @override
  String get mineQuickSettingsTitle => '设置';

  @override
  String get mineQuickSettingsSubtitle => '偏好选项';

  @override
  String get mineDevelopingToast => '功能开发中';

  @override
  String get mineLoggedInActionLabel => '设置';

  @override
  String get mineAboutLegalese => '健康助手与药品信息辅助应用';

  @override
  String get mineProfileLoginNow => '立即登录';

  @override
  String get mineProfileLoginHint => '登录后可管理账号信息与同步个人数据';

  @override
  String get mineProfileLoginAction => '去登录';

  @override
  String get mineProfileChipAccountConnected => '账号已连接';

  @override
  String get mineProfileChipLocalOnly => '当前本地体验';

  @override
  String get mineProfileChipImageLocalOnly => '原图仅本机保存';

  @override
  String get mineProfileChipSyncEnabled => '可同步轻量结果';

  @override
  String get mineProfileChipSyncAfterLogin => '登录后开启轻同步';

  @override
  String get mineQuickSectionTitle => '常用入口';

  @override
  String mineQuickSectionCount(int count) {
    return '$count 项';
  }

  @override
  String get mineQuickSectionSubtitle => '把账号、同步和设备相关入口集中到一起';

  @override
  String get mineMenuTitle => '更多设置';

  @override
  String get mineMenuSubtitle => '把浏览记录、账号安全和版本信息收拢到一个区域';

  @override
  String get mineMenuHistoryTitle => '浏览记录';

  @override
  String get mineMenuHistorySubtitle => '你最近查看过的药品';

  @override
  String get mineMenuSecurityTitle => '账号与安全';

  @override
  String get mineMenuSecuritySubtitle => '隐私设置与安全选项';

  @override
  String get mineMenuAboutTitle => '关于 Luminous';

  @override
  String get mineMenuAboutSubtitle => '版本信息与使用说明';

  @override
  String get searchTitlePicker => '选择药品';

  @override
  String get searchTitleManual => '手动搜索';

  @override
  String get searchBadgePicker => '药品库选择';

  @override
  String get searchBadgeManual => '关键词检索';

  @override
  String get searchHeaderSubtitlePicker => '从后端药品库搜索并选择';

  @override
  String get searchHeaderSubtitleManual => '支持按药品名称、批准文号、生产单位搜索';

  @override
  String get searchInputHint => '产品名称 / 批准文号 / 生产单位';

  @override
  String get searchActionSearch => '搜索';

  @override
  String get searchQuickTagsTitle => '常用搜索';

  @override
  String get searchQuickTagAmoxicillin => '阿莫西林';

  @override
  String get searchQuickTagIbuprofen => '布洛芬';

  @override
  String get searchQuickTagVitaminD => '维生素D';

  @override
  String get searchQuickTagCephalosporin => '头孢';

  @override
  String get searchQuickTagAntibiotic => '抗生素';

  @override
  String get searchQuickTagGastroMedicine => '胃药';

  @override
  String get searchHistoryTitle => '最近搜索';

  @override
  String get searchHistoryClearAction => '清空';

  @override
  String get searchHistoryEmpty => '暂无搜索历史';

  @override
  String get searchResultTitle => '搜索结果';

  @override
  String get searchGuideTitle => '搜索提示';

  @override
  String get searchGuideTipProductNameLabel => '产品名称';

  @override
  String get searchGuideTipProductNameExample => '阿莫西林胶囊、布洛芬片';

  @override
  String get searchGuideTipApprovalNoLabel => '批准文号';

  @override
  String get searchGuideTipApprovalNoExample => '国药准字 H20013191';

  @override
  String get searchGuideTipManufacturerLabel => '生产单位';

  @override
  String get searchGuideTipManufacturerExample => '石药集团、华润三九';

  @override
  String get searchGuideTipDrugCodeLabel => '药品编码';

  @override
  String get searchGuideTipDrugCodeExample => '86901000000000(本位码)';

  @override
  String get searchReadyHint => '按下\"搜索\"或回车键开始查询药品数据库';

  @override
  String get searchEmptyTitle => '暂无匹配结果';

  @override
  String get searchEmptySubtitle => '可尝试产品名称、批准文号或生产单位重新搜索';

  @override
  String get searchErrorTitle => '查询失败';

  @override
  String get searchRetryAction => '重试';

  @override
  String get searchCommitEmptyToast => '请输入产品名称、批准文号或生产单位后再搜索';

  @override
  String get searchHistoryClearedToast => '最近搜索已清空';

  @override
  String searchApprovalNoPrefix(Object approvalNo) {
    return '批准文号: $approvalNo';
  }

  @override
  String get searchAlreadyAddedToast => '该药品已在我的药品列表中';

  @override
  String get searchAddedPendingSyncToast => '已添加到我的药品，待同步到云端';

  @override
  String get searchAddedToast => '已添加到我的药品';

  @override
  String get searchAddFailedToast => '添加失败，请重试';

  @override
  String get searchResultAddedLabel => '已添加';

  @override
  String get searchResultAddActionLabel => '添加到我的药品';

  @override
  String get splashTitleMain => '智慧用药';

  @override
  String get splashTitleSubtitle => 'Luminous · 健康守护';

  @override
  String get splashBadgeScan => '扫描';

  @override
  String get splashBadgeReminder => '提醒';

  @override
  String get splashFooterBrand => 'Luminous 智慧用药助手';

  @override
  String get splashFooterSlogan => '安全 · 便捷 · 智能';

  @override
  String get scanSourceCamera => '拍摄';

  @override
  String get scanSourceGallery => '从相册选择';

  @override
  String get scanSourceCancel => '取消';

  @override
  String get scanCameraPermissionDeniedToast => '相机权限被拒绝，请允许后重试';

  @override
  String get scanReadImageFailedToast => '读取图片失败，请重试';

  @override
  String get scanPageTitleActions => '药物识别';

  @override
  String get scanPageTitleResult => '识别结果';

  @override
  String get scanPhotoPlaceholderTitle => '准备识别药物';

  @override
  String get scanHeaderSubtitleScanning => '识别中，请稍等...';

  @override
  String get scanHeaderSubtitleNoResult => '选择图片后上传，由豆包视觉模型识别药物信息';

  @override
  String scanHeaderSubtitleResultCount(int count) {
    return '共识别 $count 个候选结果';
  }

  @override
  String get scanRetakeAction => '重拍';

  @override
  String get scanInfoNoResult =>
      '选一张药盒或药品包装图片，后端会把图片交给豆包视觉模型做识别。\n如识别到多个候选，你可以先在列表里选择更接近的一项，再执行后续动作。';

  @override
  String get scanInfoNoCandidate => '未识别到有效结果，请尝试重新选择更清晰的图片。';

  @override
  String get scanResultSectionTitle => '识别结果';

  @override
  String scanApprovalNoPrefix(Object approvalNo) {
    return '批准文号: $approvalNo';
  }

  @override
  String get scanActionRescanLabel => '再次识别';

  @override
  String get scanActionRescanSubtitle => '重新选择拍摄或相册图片';

  @override
  String get scanActionSaveAlbumLabel => '添加到相册';

  @override
  String get scanActionSaveAlbumSavingSubtitle => '写入中...';

  @override
  String get scanActionSaveAlbumSubtitle => '保存到软件相册列表';

  @override
  String get scanActionSearchLabel => '搜索该药物';

  @override
  String get scanActionSearchNoKeywordSubtitle => '当前候选缺少可搜索字段';

  @override
  String get scanActionSearchSubtitle => '跳转搜索页并自动查询';

  @override
  String get scanActionCancelLabel => '取消';

  @override
  String get scanActionCancelSubtitle => '关闭当前识别页面';

  @override
  String get scanSavedToAlbumToast => '已添加到软件相册';

  @override
  String get scanSaveToAlbumFailedToast => '添加到相册失败';

  @override
  String get scanSearchMissingKeywordToast => '当前候选缺少可搜索字段';

  @override
  String get settingsDisplayTitle => '显示';

  @override
  String get settingsDisplaySubtitle => '主题模式和主题风格会同时作用到首页、药品、相册与弹层';

  @override
  String get settingsHubHeroTitle => '偏好设置';

  @override
  String get settingsHubHeroSubtitle => '从这里进入主题和语言设置，后续可继续扩展通知、隐私等模块。';

  @override
  String get settingsHeroTitle => '界面与偏好';

  @override
  String get settingsHeroMoodDark => '现在是更安静的夜间观感，页面会一起跟随当前主题节奏';

  @override
  String get settingsHeroMoodLight => '现在是更通透的浅色观感，页面会一起保持柔和层次';

  @override
  String get settingsHeroAccountLoggedIn => '账号已登录';

  @override
  String get settingsHeroAccountLoggedOut => '未登录';

  @override
  String get settingsHeroLocalMode => '本地模式';

  @override
  String get settingsHeroLoggedInHint => '你可以继续调整主题风格，账号状态会保留在这台设备上';

  @override
  String get settingsHeroLoggedOutHint => '现在也能正常使用应用，登录只会额外开启轻量同步能力';

  @override
  String get settingsThemeModeFieldTitle => '主题模式';

  @override
  String get settingsThemeModeFieldSubtitle => '支持跟随系统、固定浅色和固定深色三种方式';

  @override
  String get settingsThemeModeOptionSystem => '跟随系统';

  @override
  String get settingsThemeModeOptionLight => '浅色';

  @override
  String get settingsThemeModeOptionDark => '深色';

  @override
  String settingsThemeModeCurrentSystem(Object appearance) {
    return '当前跟随系统，系统正在使用$appearance外观';
  }

  @override
  String settingsThemeModeCurrentFixed(Object appearance) {
    return '当前固定为$appearance外观';
  }

  @override
  String get settingsThemeStyleFieldTitle => '主题风格';

  @override
  String get settingsThemeStyleFieldSubtitle =>
      '柔岚、月雾、神树、虚霭、浅砂五套配色会一起影响环境光、横幅和分区块';

  @override
  String get settingsThemeStyleInUseBadge => '当前使用';

  @override
  String get settingsThemeStyleOptionSoftGlow => '柔岚';

  @override
  String get settingsThemeStyleOptionMoonMist => '月雾';

  @override
  String get settingsThemeStyleOptionDivineTree => '神树';

  @override
  String get settingsThemeStyleOptionIllusion => '虚霭';

  @override
  String get settingsThemeStyleOptionLightSand => '浅砂';

  @override
  String get settingsThemeStyleOptionSoftGlowDesc => '淡蓝、浅紫和暖金同场，明快但不刺眼，整体更轻盈';

  @override
  String get settingsThemeStyleOptionMoonMistDesc => '主蓝色调里融入一丝紫雾，像月光下的冷蓝薄纱';

  @override
  String get settingsThemeStyleOptionDivineTreeDesc => '黄绿与柔金交错，像林荫透光，生机感更突出';

  @override
  String get settingsThemeStyleOptionIllusionDesc => '偏紫色主调，带一点点蓝光，像夜雾里的霓虹边缘';

  @override
  String get settingsThemeStyleOptionLightSandDesc =>
      '奶茶、枯粉与陶土色杂糅，温暖克制，像干燥砂岩与旧织物';

  @override
  String get medicineDetailAiNoContentToast => 'AI接口暂无返回内容';

  @override
  String get medicineDetailHeaderRefreshing => '更新中';

  @override
  String get medicineDetailHeaderRefresh => '刷新';

  @override
  String get medicineDetailLabelApprovalNo => '批准文号';

  @override
  String get medicineDetailLabelDrugCode => '药品编码';

  @override
  String get medicineDetailHeaderBadge => '药物信息';

  @override
  String get medicineDetailInfoTitle => '基础信息';

  @override
  String get medicineDetailLabelProductName => '产品名称';

  @override
  String get medicineDetailLabelDosageForm => '剂型';

  @override
  String get medicineDetailLabelSpecification => '规格';

  @override
  String get medicineDetailLabelMarketingAuthorizationHolder => '上市许可持有人';

  @override
  String get medicineDetailLabelManufacturer => '生产单位';

  @override
  String get medicineDetailLabelDrugCodeRemark => '药品编码备注';

  @override
  String get medicineDetailAiTitle => 'AI 智能解读';

  @override
  String get medicineDetailAiRefetch => '再次获取';

  @override
  String get medicineDetailAiFetch => '获取更详细信息';

  @override
  String get medicineDetailAiPlaceholder =>
      '点击\"获取更详细信息\"后，后端会调用 AI 模型补充数据库里未保存的说明书信息，例如成分、禁忌、注意事项等。';

  @override
  String get medicineDetailSafetyTitle => '安全提示';

  @override
  String get medicineDetailSafetyDisclaimer =>
      '本应用信息仅用于健康科普与辅助查询，不能替代医生诊断与处方。如有不适或正在用药，请遵医嘱并咨询专业人士。';

  @override
  String get drugLoadFailedToast => '加载我的药品失败';

  @override
  String get drugDeletedToast => '已从我的药品中移除';

  @override
  String get drugDeleteFailedToast => '删除失败';

  @override
  String get drugPickerTitle => '选择药品';

  @override
  String get drugQuickEntrySearchTitle => '手动搜索';

  @override
  String get drugQuickEntrySearchSubtitle => '名称/批准文号';

  @override
  String get drugQuickEntryScanTitle => '药物识别';

  @override
  String get drugQuickEntryScanSubtitle => '拍照识别';

  @override
  String get drugQuickEntryAiTitle => 'AI 解读';

  @override
  String get drugQuickEntryAiSubtitle => '用法禁忌';

  @override
  String get drugSearchEntryTitle => '搜索药品';

  @override
  String get drugSearchEntrySubtitle => '支持：产品名称 / 批准文号 / 生产单位';

  @override
  String get drugQuickSectionTitle => '快捷入口';

  @override
  String get drugQuickSectionSubtitle => '把高频操作收在一块，页面会更轻更顺手';

  @override
  String get drugMyMedicinesTitle => '我的药品';

  @override
  String get drugEmptyTitle => '暂无药品';

  @override
  String get drugEmptySubtitle => '通过\"手动搜索\"或\"药物识别\"\n将药品添加到这里';

  @override
  String get drugUnknownMedicineName => '未知药品';

  @override
  String get drugApprovalNoLabel => '批准文号';

  @override
  String get drugSourceScanLabel => '拍照识别';

  @override
  String get drugSourceManualLabel => '手动搜索';

  @override
  String get legalUserAgreementTitle => '用户协议';

  @override
  String get legalUserAgreementSummary =>
      '请在使用 Luminous 健康助手前，先了解账号、服务边界和使用规范。';

  @override
  String get legalUserAgreementSection1Title => '1. 协议适用范围';

  @override
  String get legalUserAgreementSection1Body =>
      '本协议适用于你使用 Luminous 健康助手应用所提供的健康记录、药品查询、AI 辅助分析、提醒管理等功能。你在注册、登录或继续使用应用时，视为已阅读并同意本协议内容。';

  @override
  String get legalUserAgreementSection2Title => '2. 服务说明';

  @override
  String get legalUserAgreementSection2Body =>
      '本应用提供的是健康信息整理与辅助参考服务，不构成诊断、处方或医疗建议。涉及用药、过敏、孕期、慢病管理等高风险事项时，请务必以医生、药师或正规说明书意见为准。';

  @override
  String get legalUserAgreementSection3Title => '3. 账号与安全';

  @override
  String get legalUserAgreementSection3Body =>
      '你应妥善保管自己的登录信息，不得借用、出租或转让账号。因你主动泄露账号信息、在不安全设备登录、或未及时退出所导致的风险，由你自行承担。';

  @override
  String get legalUserAgreementSection4Title => '4. 使用规范';

  @override
  String get legalUserAgreementSection4Body =>
      '你不得利用本应用从事违法违规行为，包括但不限于伪造身份、上传恶意内容、批量抓取接口、干扰服务稳定性、传播虚假医疗信息等。若存在异常使用行为，平台有权限制相关功能。';

  @override
  String get legalUserAgreementSection5Title => '5. AI 内容说明';

  @override
  String get legalUserAgreementSection5Body =>
      '应用中的 AI 解读、识别结果、安全辅助等内容，会受到模型能力、输入图片质量、药品信息完整度等因素影响，可能出现偏差、遗漏或不适用情形。你应结合药品说明书和专业意见独立判断。';

  @override
  String get legalUserAgreementSection6Title => '6. 免责声明';

  @override
  String get legalUserAgreementSection6Body =>
      '对于因网络中断、第三方服务异常、用户输入错误、设备兼容性问题或不可抗力导致的服务中断、结果偏差或数据延迟，我们会尽力修复，但不对由此产生的直接或间接损失承担医疗责任。';

  @override
  String get legalUserAgreementSection7Title => '7. 协议更新';

  @override
  String get legalUserAgreementSection7Body =>
      '随着功能迭代，协议内容可能调整。更新后的协议会在应用内展示；你继续使用应用即视为接受更新后的协议。如你不同意更新内容，应停止使用相关服务。';

  @override
  String get legalPrivacyPolicyTitle => '隐私政策';

  @override
  String get legalPrivacyPolicySummary => '这里说明应用会收集哪些信息、如何使用，以及你后续可以如何管理。';

  @override
  String get legalPrivacyPolicySection1Title => '1. 我们收集的信息';

  @override
  String get legalPrivacyPolicySection1Body =>
      '在你使用注册登录、药品识别、提醒计划、健康记录等功能时，我们可能收集你主动填写的手机号、邮箱、昵称、药品名称、提醒计划、扫描图片及必要的设备基础信息。';

  @override
  String get legalPrivacyPolicySection2Title => '2. 信息用途';

  @override
  String get legalPrivacyPolicySection2Body =>
      '这些信息主要用于完成账号识别、同步你的个人数据、提供药品搜索与 AI 分析、生成提醒计划、排查服务异常，以及优化产品体验。我们不会将你的个人健康数据用于与你无关的营销用途。';

  @override
  String get legalPrivacyPolicySection3Title => '3. 图片与 AI 请求';

  @override
  String get legalPrivacyPolicySection3Body =>
      '当你主动使用扫描识别、AI 药品解读或安全辅助时，相关图片、文本和结构化参数会被发送到后端与模型服务完成处理。我们建议你避免上传包含身份证、银行卡、住址等无关敏感信息的图片。';

  @override
  String get legalPrivacyPolicySection4Title => '4. 本地存储';

  @override
  String get legalPrivacyPolicySection4Body =>
      '为了减少重复登录和提升体验，应用会在本地安全地缓存部分必要信息，例如登录态、用户资料摘要、部分业务记录和主题偏好。你退出登录后，登录态相关信息会被清除。';

  @override
  String get legalPrivacyPolicySection5Title => '5. 信息共享';

  @override
  String get legalPrivacyPolicySection5Body =>
      '除法律法规要求、为完成你主动发起的服务请求，或保障系统安全所必需的情况外，我们不会向无关第三方出售或公开你的个人信息。若涉及第三方云服务，仅在提供功能所需的最小范围内处理。';

  @override
  String get legalPrivacyPolicySection6Title => '6. 你的权利';

  @override
  String get legalPrivacyPolicySection6Body =>
      '你可以通过应用内登录、退出、修改资料、删除本地数据等方式管理自己的信息。若后续接入更完整的数据管理能力，也会逐步支持导出、删除和更细粒度的授权控制。';

  @override
  String get legalPrivacyPolicySection7Title => '7. 联系与更新';

  @override
  String get legalPrivacyPolicySection7Body =>
      '如果后续隐私政策发生实质更新，我们会在应用内提供新版本说明。你继续使用相关功能，即表示你已知悉并接受更新后的内容。';

  @override
  String get safetyTitle => '安全辅助';

  @override
  String get safetyHeroSubtitle => '用更柔和的方式整理单药建议和两药相互作用提示';

  @override
  String get safetyModePair => '两药相互作用';

  @override
  String get safetyModeSingle => '单药建议';

  @override
  String get safetySelectedWaiting => '等待选择药品';

  @override
  String safetySelectedCount(int count) {
    return '已选择 $count 个药品';
  }

  @override
  String get safetyCloudWithContext => '可附带账号上下文';

  @override
  String get safetyCloudQuery => '云端AI查询';

  @override
  String get safetyModeCardTitle => '查询模式';

  @override
  String get safetyPickCardTitle => '选择药品';

  @override
  String get safetyPickPlaceholderA => '请选择药品 A';

  @override
  String get safetyPickSubtitle => '从我的药品/搜索库选择';

  @override
  String get safetyPickBadgeA => '药品 A';

  @override
  String get safetyPickPlaceholderB => '请选择药品 B';

  @override
  String get safetyPickBadgeB => '药品 B';

  @override
  String get safetyActionCardTitle => '开始查询';

  @override
  String get safetyActionQueryPair => '查询两药相互作用';

  @override
  String get safetyActionQuerySingle => '查询用药建议';

  @override
  String get safetyResultCardTitle => 'AI 结果';

  @override
  String get safetyResultPlaceholder =>
      '选择药品后点击\"开始查询\"，后端会调用 AI 模型返回用药建议或相互作用提示。';

  @override
  String get safetyPickerTitleA => '选择药品 A';

  @override
  String get safetyPickerTitleB => '选择药品 B';

  @override
  String get safetyToastSelectMedicine => '请先选择药品';

  @override
  String get safetyToastSelectSecondMedicine => '请再选择一个药品';

  @override
  String get safetyToastAiNoContent => 'AI暂无返回内容';

  @override
  String get safetyDisclaimerTitle => '安全提示';

  @override
  String get safetyDisclaimerText =>
      '本功能基于 AI 生成内容，仅用于健康科普与辅助查询，不能替代医生诊断与处方。如有不适或正在用药，请遵医嘱并咨询专业人士。';

  @override
  String get pickerLoadFailedToast => '加载我的药品失败';

  @override
  String get pickerHintLocalEmpty => '本地药品库暂时为空';

  @override
  String pickerHintLocalCount(int count) {
    return '本地已收录 $count 项';
  }

  @override
  String get pickerHintLocalPriority => '本地优先选择';

  @override
  String get pickerHintCloudFallback => '需要时再补查云端';

  @override
  String get pickerSearchBadge => '云端药品库';

  @override
  String get pickerSearchTitle => '手动搜索药品库';

  @override
  String get pickerSearchSubtitle => '从云端搜索后直接带回当前流程，适合本地还没保存时快速补查。';

  @override
  String get pickerMyMedicinesTitle => '我的药品';

  @override
  String pickerCount(int count) {
    return '共 $count 项';
  }

  @override
  String get pickerSyncing => '同步中';

  @override
  String get pickerEmptyTitle => '还没有本地药品记录';

  @override
  String get pickerEmptySubtitle => '你可以先去云端药品库补查，或者稍后再把常用药保存到这里。';

  @override
  String get albumHeaderTitle => '识别相册';

  @override
  String get albumHeaderSubtitleEmpty => '新的识别记录会自动归档到这里';

  @override
  String get albumHeaderSubtitleNonEmpty => '本地保存原图，云端仅同步缩略图和识别结果';

  @override
  String get albumHeaderChipWaitingFirstRecord => '等待第一条记录';

  @override
  String albumHeaderChipRecordCount(int count) {
    return '$count 条记录';
  }

  @override
  String get albumHeaderChipNoOriginal => '暂无原图归档';

  @override
  String albumHeaderChipOriginalCount(int count) {
    return '原图 $count 条';
  }

  @override
  String get albumHeaderChipCloudSync => '云端轻同步';

  @override
  String get albumHeaderChipLocalOnly => '当前仅本地保存';

  @override
  String get albumErrorTitle => '相册同步出了点问题';

  @override
  String get albumErrorHint => '下拉刷新后会再次尝试读取本地记录';

  @override
  String get albumEmptyTitle => '暂无记录';

  @override
  String get albumEmptySubtitle => '去\"药物识别\"拍照后会自动保存到这里';

  @override
  String get albumEmptyChipAutoArchive => '拍照后自动归档';

  @override
  String get albumEmptyChipLocalOnly => '原图仅保存在本机';

  @override
  String get albumLoginTitle => '开启轻量同步';

  @override
  String get albumLoginSubtitle => '登录后可把缩略图和识别结果同步到云端，原图继续留在本机';

  @override
  String get albumLoginChipNoUpload => '原图不上传';

  @override
  String get albumLoginChipLightweightSync => '只同步轻量结果';

  @override
  String get albumLoginActionSyncAfterLogin => '登录后同步';

  @override
  String get albumLoginActionLogin => '登录';

  @override
  String get albumCardStatusLocalOriginal => '本地原图';

  @override
  String get albumCardStatusThumbnailOnly => '仅缩略图';

  @override
  String get albumCardSubtitleTapForDetail => '点击查看识别结果与药品详情';

  @override
  String albumApprovalNoPrefix(Object approvalNo) {
    return '批准文号: $approvalNo';
  }

  @override
  String get albumCardTagRescannable => '可再次识别';

  @override
  String get albumCardTagLightRecord => '当前为轻量记录';

  @override
  String get albumPreviewNoApprovalNo => '暂无批准文号';

  @override
  String get albumPreviewTagOriginalRescannable => '本地原图可重识别';

  @override
  String get albumPreviewTagThumbnailOnly => '当前仅保存缩略图';

  @override
  String albumPreviewTagRecordedAt(Object date) {
    return '记录于 $date';
  }

  @override
  String get albumPreviewLowQualityNotice => '当前记录仅保存缩略图，无法高质量重识别。';

  @override
  String get albumPreviewOpenDetailAction => '查看药品详情';

  @override
  String get albumPreviewRescanAction => '再次识别';

  @override
  String get albumDetailMissingIdentityToast =>
      '该记录缺少 drugCode/approvalNo，无法查看详情';

  @override
  String get albumRescanThumbnailOnlyToast => '当前记录仅保存缩略图，无法高质量重识别';

  @override
  String get albumRescanReadOriginalFailedToast => '原图读取失败，无法重识别';
}
