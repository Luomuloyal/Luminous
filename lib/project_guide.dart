/*
  Luminous 开发讲解（从空项目到当前版本）

  这份文件是“项目内的注释文档”，只写给开发者看：
  - 不参与业务逻辑
  - 不会被 import
  - 目的：把从 0 到 1 的思路、设计、演进过程、踩坑点一次讲清楚

  建议阅读方式：
  1) 先看第 0 节的时间线（你会知道我们做了哪些里程碑）
  2) 再看第 2~7 节（你会知道工程分层怎么跑起来）
  3) 最后看第 9~14 节（你会知道药品查询、AI 预留、联调、排错怎么做）

  关联文件快速索引（建议配合 IDE 打开）：
  - lib/main.dart                     入口初始化（GetX 注入顺序的关键）
  - lib/constants/constants.dart      全局常量、接口路径常量
  - lib/utils/DioRequest.dart         统一网络层（code/msg/result）
  - lib/api/                          API 封装层（强类型返回）
  - lib/viewmodels/                   数据模型与 fromJson（强类型）
  - lib/stores/user_controller.dart   全局用户态（GetX + SharedPreferences）
  - lib/pages/                        页面（状态/交互/编排）
  - lib/components/                   可复用组件（只抽值得复用的）
  - lib/Backend/                      后端接口文档与示例代码（你部署用）

  ---------------------------------------------------------------------------
  0. 时间线/里程碑（从空项目到现在做了什么）

  这里按“先搭骨架 -> 再统一协议 -> 再补功能 -> 再优化 UI”的顺序复盘：

  A) 空项目阶段（骨架必须先稳定）
  - 建立 lib 目录下基本分层：pages/components/utils/constants/api/viewmodels/stores/routes
  - 配置依赖：dio/shared_preferences/get/flutter_svg/sqflite（pubspec.yaml）
  - AndroidManifest.xml 加网络权限（INTERNET），否则真机请求会失败
  - 路由：MaterialApp + routes map（lib/routes/routes.dart）

  B) 认证阶段（最先打通“用户能登录注册”，以便后续功能基于登录态扩展）
  - 后端 3 个接口：send-code / register-user / login-user
  - 前端页面：Login/Register
  - 重点：手机号/邮箱双栈、验证码登录、注册 SVG 校验、自动注册跳转、Loading/Toast + 错误展示

  C) 协议统一阶段（工程可维护性拐点：把不稳定性压到“最少的地方”）
  - 后端返回结构统一为 code/msg/result
  - 前端 DioRequest 只写一次解析逻辑
  - API 层统一 decoder 强类型解析，页面不碰 Map/dynamic

  D) 全局用户态（让“我的”页、首页等可以共享登录态，避免各页面重复读写本地）
  - UserController（GetX）
  - SharedPreferences 本地持久化 safeUser
  - main() 中只保留 Get.put；本地恢复与预热任务改到首帧后异步执行

  E) 药品服务（核心业务：手动搜索 + 详情页 + AI 预留）
  - 后端：MySQL 查询（healthdev/medicine_db/国产本位码）
  - 前端：Search 对接 medicine-search，结果点击进详情页
  - 详情页：基础信息 + “AI 智能解读”预留（先占位文案 + 预留接口）

  F) UI 优化（你截图的问题：卡片撑满整屏、信息密度不合理）
  - Mine 页改为 ListView 分区（profile + quick actions + menu）
  - Drug 页改为“入口页”，让用户知道怎么进入搜索/AI
  - Search 页加入“输入中/待搜索/加载中/空结果”状态提示

  ---------------------------------------------------------------------------
  1. 目标与边界（从 0 到 1 的第一性原则）

  我们追求的不是“把页面写出来”，而是“可持续迭代的骨架”：

  目标
  - UI：代码可读（页面只做编排），可复用组件抽取适度，交互清晰
  - 网络：统一协议、统一错误、统一超时、统一日志
  - 数据：强类型 fromJson，避免 dynamic 满天飞
  - 状态：跨页面共享通过 store；页面只读/触发动作
  - 未来：AI 可插拔；接口契约先稳定，后续换实现不动前端结构

  边界（当前阶段刻意不做）
  - 不接 token 鉴权（只保留 token_manager 的骨架）
  - 不做复杂 Domain/UseCase 层（业务还不够复杂，先别过度设计）
  - 今日提醒先 demo（接口先定，后面落库不会破坏前端）

  ---------------------------------------------------------------------------
  2. 目录结构设计（为什么这样分层）

  分层的核心不是“好看”，而是把变化隔离开：
  - 后端协议变化：只影响 DioRequest + API + Viewmodels
  - UI 改版：只影响 components/pages，不影响网络层
  - 新增接口：按固定套路“constants -> viewmodels -> api -> pages”

  目录职责再次强调（强约束）：
  - constants：常量与路径（全大写，集中管理）
  - utils：基础设施（网络/Loading/Toast）
  - api：接口封装（固定路径 + 固定请求体 + decoder）
  - viewmodels：数据结构（fromJson/toJson/少量 display helper）
  - stores：全局状态（GetX/持久化）
  - components：可复用 UI（不要把页面碎逻辑塞进来）
  - pages：页面（状态/交互/编排）
  - Backend：后端接口文档与示例代码（你部署时“照着写/照着改”）

  ---------------------------------------------------------------------------
  3. 后端接口规范（统一返回格式的原因）

  统一返回结构：
    {
      "code": "1",
      "msg": "提示信息",
      "result": ...
    }

  为什么它是“工程拐点”？
  - 你不统一，前端每个接口都要写一套解析/错误判断，维护成本会指数级增长
  - 你统一之后，DioRequest 可以成为“唯一解析点”，后续所有页面都轻

  需要注意的细节：
  - code 推荐字符串（避免 1/"1" 混用）
  - msg 是面向用户的可读信息
  - result 是业务数据，失败时可以为 null 或 {}，但不要让前端靠 result 形状判断成功

  ---------------------------------------------------------------------------
  4. 网络层封装（DioRequest）的思路与坑点

  文件：lib/utils/DioRequest.dart

  我们做了什么：
  - BaseOptions 统一 baseUrl/timeout（constants）
  - InterceptorsWrapper 统一日志 + Loading show/hide
  - _request 统一解析 code/msg/result
  - decoder 强类型解码：把 result 转换为业务对象（T）

  为什么不让页面直接写 Dio？
  - 页面会被业务驱动快速膨胀；如果每个页面都自己处理超时/错误/解析，后期几乎不可控

  常见坑点：
  - response.data 的类型不稳定：Map / String(JSON) 都可能出现
  - error.response.data 有时是 HTML / string，必须兜底
  - Loading 的 show/hide 要避免“弹窗残留”（我们在 LoadingUtils 做了状态管理）

  什么时候用全屏 Loading（弹窗）？
  - 登录/注册这种“关键动作、阻塞型操作”适合
  - 搜索分页这种“非阻塞、局部刷新”不适合，建议用局部 loading（我们已这么做）

  ---------------------------------------------------------------------------
  5. API 层封装（lib/api）

  API 层是“协议集中地”，它的价值是：
  - 页面不写接口路径字符串
  - 页面不关心字段名、channel/scene/loginMode 这些协议细节
  - 页面拿到的是强类型对象，不碰 Map

  例如 medicine-search：
  - constants.dart 定义 HttpConstants.MEDICINE_SEARCH
  - viewmodels/medicine.dart 定义 MedicineSearchResult/MedicineItem
  - api/medicine_api.dart 定义 MedicineApi.search 并 decoder result
  - pages/Search/search.dart 只调用 MedicineApi.search 并渲染

  ---------------------------------------------------------------------------
  6. ViewModels（lib/viewmodels）

  这里主要解决两件事：
  1) JSON -> Dart 类型（fromJson）
  2) 一些“展示友好”的衍生字段（displayName/displaySubtitle）

  注意：
  - viewmodels 不要 import Flutter Widget（避免层次反转）
  - fromJson 尽量容错（例如后端字段可能叫 _id 或 id）
  - 如果后端返回中文字段名，也要能兼容（我们在 MedicineItem.fromJson 做了兼容）

  ---------------------------------------------------------------------------
  7. Store（GetX + 本地持久化）

  为什么要 UserController？
  - 多页面共享用户信息（Mine、后续收藏/历史/提醒等）
  - 登录成功只写一次，其他页面自动响应

  注入顺序（非常关键）：
  - main() 必须在 runApp 之前完成 Get.put(UserController)
  - 否则页面构造时 Get.find 会抛异常：Controller not found

  测试注意：
  - widget test 不会走 main()，所以 test 里要：
    - SharedPreferences.setMockInitialValues
    - Get.testMode = true
    - Get.put(UserController) 并在需要时手动调用 init()

  ---------------------------------------------------------------------------
  8. 页面与组件拆分（复用优先，不机械拆分）

  你给的要求是“只下沉可复用组件”：
  - 我们遵守：components/auth.dart 承担登录/注册复用 UI
  - Home/Search/Mine 只抽了能明显提高清晰度的块

  判断一个组件该不该下沉的标准（建议一直用）：
  - 未来 2 个以上页面会用到：下沉
  - 单页很复杂，抽出来能让页面 build 结构清晰：下沉
  - 只在单页出现、又很碎：留在页面

  ---------------------------------------------------------------------------
  9. 药品数据库与接口设计（MySQL -> 后端 -> 前端）

  数据库结构（你提供）：
  - db: healthdev
  - schema: medicine_db
  - table: 国产本位码（中文表名，SQL 必须用反引号）
  - 字段：序号、批准文号、产品名称、剂型、规格、上市许可持有人、生产单位、药品编码、药品编码备注

  我们设计了三套接口：
  1) medicine-search：关键词搜索 + 分页
     - 关键词支持：产品名称/批准文号/生产单位/上市许可持有人/药品编码
     - pageSize 限制最大 50，防止一次拉太多

  2) medicine-detail：详情查询（drugCode/approvalNo 精确匹配）
     - 详情页先用列表项做 initialItem，再请求 detail 补齐字段

  3) medicine-ai-detail：AI 预留
     - 先返回占位 text，保证前端联调与 UI 完整
     - 后续接 AI：建议后端先查基础信息，再拼 prompt 调模型

  MySQL 安全与性能注意点（必须看）：
  - 绝对不要把 root 密码写死在代码里：用环境变量（process.env）
  - 外网连接尽量白名单/限流，避免被扫库
  - LIKE 模糊查询对大表可能慢：后续建议加索引或全文索引（MySQL FULLTEXT）
  - 查询必须 LIMIT/OFFSET，避免一次返回 1000+ 行
  - 中文表/字段名一定要用反引号包裹，避免语法错误

  ---------------------------------------------------------------------------
  10. 今日提醒（today-reminders）

  为什么要单独一个接口？
  - 你未来要做“用户提醒计划”，一定要落库
  - 把接口协议先定住，前端先对接，后面你把 demo 改成真实查询不会影响前端

  当前策略：
  - Home 页面启动时请求 today-reminders
  - 如果失败，回退到本地 fallback 数据（保证 UI 不空、不抖）

  ---------------------------------------------------------------------------
  11. UI/交互设计注意事项（从你截图出发）

  你截图的 Mine 页问题本质是：
  - 一个大卡片在竖屏里占满视野，信息密度太低，用户不知道下一步干什么

  我们的解决思路：
  - 改为 ListView 分区：ProfileCard（身份） + QuickActions（下一步） + Menu（功能列表）
  - 背景加轻量装饰圆形（不影响可读性，但让画面更“有层次”）

  Search 的交互注意：
  - 输入不等于搜索：否则每打一个字就请求后端，成本高、体验也差
  - 所以分离 _draftKeyword（输入态）和 _keyword（提交态）

  ---------------------------------------------------------------------------
  12. 质量门槛（为什么每次都跑 analyze/test/format）

  我们保持每次结构调整都能稳住工程：
  - dart format：减少 diff 噪音
  - flutter analyze：静态问题 0
  - flutter test：至少保住现有 widget test（登录页）

  ---------------------------------------------------------------------------
  13. 部署/联调清单（你部署后端时照这个检查）

  认证接口（你已更新）：
  - /send-code /register-user /login-user：必须返回 code/msg/result
  - 手机验证码固定走阿里云“短信认证”

  药品接口（新增）：
  - /medicine-search /medicine-detail /medicine-ai-detail
  - /today-reminders

  部署前必查：
  - 环境变量：MYSQL_HOST/PORT/USER/PASSWORD/DATABASE
  - 认证环境变量：邮箱发送配置 + 阿里云短信认证 AccessKey / Endpoint / Scene
  - mysql2 依赖是否安装
  - BASE_URL 是否更新到 constants.dart
  - 云函数路径与前端 HttpConstants 是否一致

  ---------------------------------------------------------------------------
  14. 常见故障排查（遇到问题先看这里）

  1) 前端报 “接口不存在(404)”：
  - 检查 HttpConstants 路径是否拼错（有没有漏掉前面的 /）
  - 检查云函数名称是否和路径一致

  2) 前端提示 “响应格式异常”：
  - 后端是否按 code/msg/result 返回
  - 网关/平台是否返回了 HTML 或文本（例如 Function Not Found）

  3) GetX 报 “UserController not found”：
  - main() 是否在 runApp 前 Get.put(UserController)
  - widget test 是否注入了 controller

  4) MySQL 查询慢/超时：
  - pageSize 是否太大
  - LIKE 查询是否无索引
  - 外网连接是否抖动（建议内网连接）

  ---------------------------------------------------------------------------
  15. 下一步演进路线（建议顺序）

  - token 鉴权：login-user 返回 token；DioRequest 自动加 Authorization
  - 提醒落库：today-reminders 改为 userId/date 查询
  - 搜索增强：防抖、建议词、历史持久化、收藏/浏览历史
  - AI：后端做超时/重试/缓存；前端支持流式展示与引用来源

  ---------------------------------------------------------------------------
  16. 文件逐个讲解（你打开代码时应该怎么读）

  读代码建议顺序：
  1) 先看入口与协议：main.dart + constants.dart + DioRequest.dart
  2) 再看 API 与类型：lib/api + lib/viewmodels
  3) 最后看页面：lib/pages（UI 只是消费前两层）

  (1) lib/main.dart
  - 做的事只有一件：在 runApp 之前准备“真正不可缺少的轻量依赖”
  - 关键点：Get.put(UserController) 必须先于页面构造，否则 Get.find 会报错
  - SharedPreferences/数据库/通知 SDK/云同步都应在首帧之后异步 warm-up

  (2) lib/constants/constants.dart
  - GlobalConstants：BASE_URL/TIME_OUT/SUCCESS_CODE/本地存储 key
  - HttpConstants：所有接口路径常量
  - 注意：你部署后端换域名，只需要改 BASE_URL

  (3) lib/utils/DioRequest.dart
  - ApiResult<T>：统一承载 code/msg/result
  - ApiException：页面只捕获这一种异常即可
  - get/post：统一入口，必须提供 decoder
  - Interceptor：统一日志 + Loading（showLoading/loadingText）
  - _coerceToMap：把 Map/String(JSON) 都变成 Map<String,dynamic>
  - _extractServerMessage：尽量从服务端返回里提取可读错误信息

  (4) lib/utils/loading_utils.dart
  - 用全局 navigatorKey 打开/关闭 Loading 弹窗
  - 用计数避免并发请求导致 hide 过早（或弹窗残留）

  (5) lib/utils/toast_utils.dart
  - 统一使用 SnackBar 展示轻提示
  - 注意：Toast 是 UI 层提示，不应该承担“业务状态判断”

  (6) lib/api/auth_api.dart
  - fetchSvgCode / sendEmailCode / registerWithEmail / registerWithSvg
  - loginWithEmail / loginWithSvg
  - 这些方法把“接口字段细节”集中在一起，页面不用记 channel/scene/loginMode 等细节

  (7) lib/viewmodels/auth.dart
  - SvgCodeResult / EmailCodeResult / RegisterResult / UserSafe
  - UserSafe.toJson 用于本地持久化；fromJson 兼容 _id/id

  (8) lib/stores/user_controller.dart
  - user: Rxn<UserSafe>
  - init：启动恢复；setUser：登录写入；logout：清理
  - 注意：测试里要手动注入 controller（因为测试不走 main）

  (9) lib/api/medicine_api.dart + lib/viewmodels/medicine.dart
  - MedicineItem.fromJson 同时兼容“别名字段”和“中文字段名”
  - MedicineApi.search：分页搜索（不弹全屏 Loading，页面局部展示）
  - MedicineApi.fetchDetail：详情补齐
  - MedicineApi.fetchAiDetail：AI 预留（先占位）

  (10) lib/pages/Search/search.dart
  - _draftKeyword：输入框实时内容
  - _keyword：已提交搜索词（真正触发请求）
  - _results/_page/_hasMore：分页状态
  - 滚动接近底部自动加载更多

  (11) lib/pages/Drug/medicine_detail.dart
  - 基础信息卡 + AI 预留卡 + 免责声明
  - detail 与 ai 两个请求分离，便于后续独立演进

  (12) lib/pages/Mine/mine.dart + lib/components/mine.dart
  - MineProfileCard 只负责展示（可复用）
  - 页面负责布局与交互（退出登录确认框、快捷入口等）

  (13) lib/Backend/
  - 这里是“你部署后端的依据”，每新增一个接口都建议写一份 md
  - md 要包含：路径、请求体、返回体、示例代码、注意事项（依赖、env、安全）

  ---------------------------------------------------------------------------
  17. 新增功能 checklist（简版）

  你以后加任何一个“前后端联动功能”，建议按这个顺序：
  1) 先写后端 md（接口契约先定住）
  2) constants.dart 加路径常量
  3) viewmodels 写 fromJson（强类型）
  4) api 写方法 + decoder（页面不碰 Map）
  5) pages 接入（状态/交互/编排）
  6) 可复用 UI 再抽到 components（不要机械拆）
  7) 跑 dart format / flutter analyze / flutter test

  更详细的“照着做”版本见：lib/feature_playbook.dart

*/
