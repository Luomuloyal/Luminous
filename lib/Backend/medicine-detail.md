访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-detail
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-detail

用途:
- 药品详情页: 查询某个药品的基础信息(来自 MySQL)

请求体(二选一即可，推荐 drugCode):
- drugCode: string (药品编码)
- approvalNo: string (批准文号)

返回体:
- code: string
- msg: string
- result: MedicineItem

MedicineItem 字段:
- serialNo: string
- approvalNo: string
- productName: string
- dosageForm: string
- specification: string
- marketingAuthorizationHolder: string
- manufacturer: string
- drugCode: string
- drugCodeRemark: string

依赖:
- mysql2 (云函数依赖中需要安装)

```typescript
import cloud from '@lafjs/cloud'
import mysql from 'mysql2/promise'

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

  const drugCode = String((ctx.body as any).drugCode || '').trim()
  const approvalNo = String((ctx.body as any).approvalNo || '').trim()

  if (!drugCode && !approvalNo) {
    return fail('drugCode 或 approvalNo 不能为空')
  }

  const where = drugCode ? '`药品编码` = ?' : '`批准文号` = ?'
  const value = drugCode || approvalNo

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
      WHERE ${where}
      LIMIT 1`,
      [value],
    )

    const item = Array.isArray(rows) ? (rows as any[])[0] : null
    if (!item) {
      return fail('未找到该药品信息')
    }

    return success(item)
  } catch (e) {
    console.error('mysql query failed:', e)
    return fail('查询失败，请稍后重试')
  }
}
```
