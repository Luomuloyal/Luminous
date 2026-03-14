/*
  Luminous 功能开发 Playbook（更细的“照着做”步骤）

  这份文件的目标：
  - 你以后要加任何一个新功能（新页面/新接口/新组件），都能按固定步骤落地
  - 把“应该放哪、怎么命名、怎么对接、怎么测试”一次讲透

  ---------------------------------------------------------------------------
  1) 新增一个后端接口 + 前端对接（推荐标准流程）

  Step 0: 先把接口“写成契约”
  - 约定统一返回：{ code, msg, result }
  - 明确请求体字段、字段类型、可选项、边界值（pageSize 上限等）
  - 明确 result 的 JSON 结构（是对象还是数组）
  - 在 lib/Backend 下新增 md（作为部署依据）

  Step 1: 前端新增路径常量（避免魔法字符串）
  - 文件：lib/constants/constants.dart
  - 在 HttpConstants 中新增：
      static const String XXX = '/xxx';

  Step 2: 定义 viewmodels（把 JSON 结构固化成强类型）
  - 文件：lib/viewmodels/xxx.dart
  - 给每个对象写 fromJson：
    - 字段缺省值要明确（空字符串/0/false）
    - 如后端可能返回 _id/id 两种命名，fromJson 里要兼容

  Step 3: API 层封装（页面不要直接写 dioRequest）
  - 文件：lib/api/xxx_api.dart
  - 统一返回 ApiResult<T>
  - 使用 dioRequest.post<T>(..., decoder: ...)
  - decoder 内调用 T.fromJson，把 dynamic result 变成强类型

  Step 4: 页面接入（页面只做状态/交互/编排）
  - 文件：lib/pages/SomePage/some_page.dart
  - UI 状态：loading/error/empty/data
  - 请求逻辑：try/catch ApiException，把 msg toast 出来
  - 不要在页面里解析 Map，不要在页面里拼路径字符串

  Step 5: 复用组件（只在值得复用时抽）
  - 未来至少 2 个页面要用，或者拆出去能显著提升可读性 -> 抽到 lib/components
  - 否则留在页面（避免“文件跳转过多”的维护成本）

  Step 6: 验证
  - dart format lib test
  - flutter analyze
  - flutter test

  ---------------------------------------------------------------------------
  2) 示例：medicine-search 是怎么按流程落地的

  后端契约（lib/Backend/medicine-search.md）
  - 请求：keyword/page/pageSize
  - 返回：items/total/page/pageSize

  前端路径常量
  - HttpConstants.MEDICINE_SEARCH

  viewmodels
  - MedicineItem/MedicineSearchResult（lib/viewmodels/medicine.dart）

  API
  - MedicineApi.search（lib/api/medicine_api.dart）

  页面
  - SearchView（lib/pages/Search/search.dart）
    - _draftKeyword：输入态
    - _keyword：提交态（触发请求）
    - _results/_page/_hasMore：分页状态

  ---------------------------------------------------------------------------
  3) 接入 AI 的推荐后端流程（以后你实现时按这个走）

  为什么 AI 放后端？
  - 模型 key/配额/安全控制都应在服务端
  - 可以做缓存、限流、审计、内容过滤

  建议实现步骤：
  1) 前端点击“获取详细信息” -> POST /medicine-ai-detail（drugCode/approvalNo）
  2) 后端：先查 MySQL 详情（补齐产品名称/剂型/规格/厂家等）
  3) 后端：拼 prompt（包含基础信息 + 你期望输出的结构）
  4) 后端：调用模型（超时/重试/降级）
  5) 后端：做内容过滤与免责声明拼接
  6) 返回：{ code:'1', msg:'', result:{ text:'...' } }

  输出建议（便于前端展示）：
  - 直接返回一段 text（现在我们就是这个方式）
  - 或者未来升级成结构化 JSON（例如 sections 数组），前端更好做排版

*/
