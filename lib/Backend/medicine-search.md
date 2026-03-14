访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-search
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-search
用途:
- 手动搜索页: 关键词搜索药品基础信息

请求体:
- keyword: string (必填, 支持产品名称/批准文号/生产单位/上市许可持有人/药品编码 模糊查询)
- page: number (可选, 默认 1)
- pageSize: number (可选, 默认 20, 最大 50)

返回体:
- code: string
- msg: string
- result:
  - items: MedicineItem[]
  - total: number
  - page: number
  - pageSize: number

MedicineItem 字段(建议用别名返回，前端已按这些 key 对接):
- serialNo: string
- approvalNo: string
- productName: string
- dosageForm: string
- specification: string
- marketingAuthorizationHolder: string
- manufacturer: string
- drugCode: string
- drugCodeRemark: string

注意:
- MySQL 连接方式见 `d:\\25080\\Desktop\\MySQLdev.md`
- 如果云函数部署在同一集群，优先使用内网地址；否则使用外网地址
- 依赖: mysql2 (云函数依赖中需要安装，推荐版本: mysql2@3.11.0)
- 如果你看到报错：Cannot find module 'mysql2/promise'...
  - 这不是版本不兼容，通常是 mysql2 没有安装成功
  - 请先在后端平台的“依赖/Dependencies”里安装 mysql2
  - 如果安装后仍提示找不到模块，可把 import 改为 `mysql2/promise.js`（见下方代码）

```typescript
import cloud from '@lafjs/cloud'
// 注意：某些环境对 exports 子路径解析更严格，推荐使用 promise.js 写法
// 前提：你已经在依赖中安装 mysql2 (推荐 mysql2@3.11.0)
import mysql from 'mysql2/promise.js'

// 推荐: 把密码等敏感信息放到云函数环境变量中
const MYSQL_HOST = process.env.MYSQL_HOST || 'healthdev-mysql.ns-w0d0n49n.svc'
const MYSQL_PORT = Number(process.env.MYSQL_PORT || 3306)
const MYSQL_USER = process.env.MYSQL_USER || 'root'
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD || ''
const MYSQL_DATABASE = process.env.MYSQL_DATABASE || 'medicine_db'

const TABLE = `\`${MYSQL_DATABASE}\`.\`国产本位码\``

const pool = mysql.createPool({
  host: MYSQL_HOST,
  port: MYSQL_PORT,
  user: MYSQL_USER,
  password: MYSQL_PASSWORD,
  database: MYSQL_DATABASE,
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 5,
})

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  const keyword = String((ctx.body as any).keyword || '').trim()
  const page = Math.max(1, Number((ctx.body as any).page || 1))
  const pageSizeRaw = Number((ctx.body as any).pageSize || 20)
  const pageSize = Math.min(50, Math.max(1, pageSizeRaw))

  if (!keyword) {
    return fail('keyword 不能为空')
  }

  const like = `%${keyword}%`
  const where =
    'WHERE `产品名称` LIKE ? OR `批准文号` LIKE ? OR `生产单位` LIKE ? OR `上市许可持有人` LIKE ? OR `药品编码` LIKE ?'
  const params = [like, like, like, like, like]
  const offset = (page - 1) * pageSize

  try {
    const [rows] = await pool.query(
      `SELECT
        \`序号\` AS serialNo,
        \`批准文号\` AS approvalNo,
        \`产品名称\` AS productName,
        \`剂型\` AS dosageForm,
        \`规格\` AS specification,
        \`上市许可持有人\` AS marketingAuthorizationHolder,
        \`生产单位\` AS manufacturer,
        \`药品编码\` AS drugCode,
        \`药品编码备注\` AS drugCodeRemark
      FROM ${TABLE}
      ${where}
      ORDER BY \`序号\` ASC
      LIMIT ? OFFSET ?`,
      [...params, pageSize, offset],
    )

    const [countRows] = await pool.query(
      `SELECT COUNT(1) AS total FROM ${TABLE} ${where}`,
      params,
    )

    const total =
      Array.isArray(countRows) && (countRows as any[])[0]
        ? Number((countRows as any[])[0].total || 0)
        : 0

    return success({
      items: rows,
      total,
      page,
      pageSize,
    })
  } catch (e) {
    console.error('mysql query failed:', e)
    // 联调阶段建议把错误信息透传出来，方便你第一时间定位：
    // - 缺少依赖 mysql2
    // - MySQL 连接失败（地址/端口/白名单/网络策略）
    // - SQL 语法错误（中文表名/字段名是否加反引号）
    const message = String((e as any)?.message || e || '')
    if (message.includes('Cannot find module') && message.includes('mysql2')) {
      return fail('缺少依赖 mysql2：请在依赖中安装 mysql2@3.11.0 后再重试')
    }
    if (
      message.includes('ECONNREFUSED') ||
      message.includes('ETIMEDOUT') ||
      message.includes('EHOSTUNREACH')
    ) {
      return fail('MySQL 连接失败：请检查 MYSQL_HOST/MYSQL_PORT/白名单/网络策略')
    }
    return fail('查询失败，请稍后重试')
  }
}
```
