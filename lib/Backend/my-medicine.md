访问地址: https://wty10hv6az.sealosbja.site

函数路径:
- POST /my-medicine-upsert
- POST /my-medicine-delete
- POST /my-medicine-list

公网访问路径:
- https://wty10hv6az.sealosbja.site/my-medicine-upsert
- https://wty10hv6az.sealosbja.site/my-medicine-delete
- https://wty10hv6az.sealosbja.site/my-medicine-list

用途:
- “我的药品”云端同步: 登录后按用户维度拉取药品列表，并支持新增/删除

MyMedicineRecord 字段:
- id: string
- userId: string
- identityKey: string
- drugCode: string
- approvalNo: string
- productName: string
- dosageForm: string
- specification: string
- manufacturer: string
- source: string
- createdAt: number

请求体: POST /my-medicine-upsert
- userId: string (必填)
- id: string (可选，传则更新，不传则按 userId + identityKey 幂等写入)
- identityKey: string (必填，前端按用户维度生成唯一 key)
- drugCode: string (可选)
- approvalNo: string (可选)
- productName: string (必填)
- dosageForm: string (可选)
- specification: string (可选)
- manufacturer: string (可选)
- source: string (可选，默认 search)

返回体: POST /my-medicine-upsert
- code: string
- msg: string
- result: MyMedicineRecord

请求体: POST /my-medicine-delete
- userId: string (必填)
- id: string (可选)
- identityKey: string (可选，与 id 二选一即可)

返回体: POST /my-medicine-delete
- code: string
- msg: string
- result: boolean

请求体: POST /my-medicine-list
- userId: string (必填)

返回体: POST /my-medicine-list
- code: string
- msg: string
- result: { items: MyMedicineRecord[] }

示例代码（Laf 云函数）
```typescript
import cloud from '@lafjs/cloud'

const db = cloud.database()
const COL = 'user_medicines'

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

export async function main(ctx: FunctionContext) {
  const fn = String(ctx.__function_name || '').trim()
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  if (fn.includes('my-medicine-upsert')) {
    const userId = String((ctx.body as any).userId || '').trim()
    const id = String((ctx.body as any).id || '').trim()
    const identityKey = String((ctx.body as any).identityKey || '').trim()
    const productName = String((ctx.body as any).productName || '').trim()
    if (!userId) return fail('userId 不能为空')
    if (!identityKey) return fail('identityKey 不能为空')
    if (!productName) return fail('productName 不能为空')

    const drugCode = String((ctx.body as any).drugCode || '').trim()
    const approvalNo = String((ctx.body as any).approvalNo || '').trim()
    const dosageForm = String((ctx.body as any).dosageForm || '').trim()
    const specification = String((ctx.body as any).specification || '').trim()
    const manufacturer = String((ctx.body as any).manufacturer || '').trim()
    const source = String((ctx.body as any).source || 'search').trim() || 'search'

    let remoteId = id
    let createdAt = Date.now()

    if (remoteId) {
      const current = await db.collection(COL).where({ _id: remoteId, userId }).getOne()
      createdAt = Number(current.data?.createdAt || createdAt)
      await db.collection(COL).where({ _id: remoteId, userId }).update({
        identityKey,
        drugCode,
        approvalNo,
        productName,
        dosageForm,
        specification,
        manufacturer,
        source,
        updatedAt: Date.now(),
      })
    } else {
      const existed = await db.collection(COL).where({ userId, identityKey }).getOne()
      if (existed.data?._id) {
        remoteId = existed.data._id
        createdAt = Number(existed.data.createdAt || createdAt)
        await db.collection(COL).where({ _id: remoteId, userId }).update({
          drugCode,
          approvalNo,
          productName,
          dosageForm,
          specification,
          manufacturer,
          source,
          updatedAt: Date.now(),
        })
      } else {
        const result = await db.collection(COL).add({
          userId,
          identityKey,
          drugCode,
          approvalNo,
          productName,
          dosageForm,
          specification,
          manufacturer,
          source,
          createdAt,
          updatedAt: Date.now(),
        })
        remoteId = result.id
      }
    }

    return success({
      id: remoteId,
      userId,
      identityKey,
      drugCode,
      approvalNo,
      productName,
      dosageForm,
      specification,
      manufacturer,
      source,
      createdAt,
    })
  }

  if (fn.includes('my-medicine-delete')) {
    const userId = String((ctx.body as any).userId || '').trim()
    const id = String((ctx.body as any).id || '').trim()
    const identityKey = String((ctx.body as any).identityKey || '').trim()
    if (!userId) return fail('userId 不能为空')
    if (!id && !identityKey) return fail('id 或 identityKey 至少传一个')

    const where = id ? { _id: id, userId } : { userId, identityKey }
    const { deleted } = await db.collection(COL).where(where).remove()
    return success(deleted >= 1)
  }

  if (fn.includes('my-medicine-list')) {
    const userId = String((ctx.body as any).userId || '').trim()
    if (!userId) return fail('userId 不能为空')

    const { data } = await db
      .collection(COL)
      .where({ userId })
      .orderBy('createdAt', 'desc')
      .get()

    const items = (data || []).map((row: any) => ({
      id: row._id,
      userId: row.userId,
      identityKey: row.identityKey || '',
      drugCode: row.drugCode || '',
      approvalNo: row.approvalNo || '',
      productName: row.productName || '',
      dosageForm: row.dosageForm || '',
      specification: row.specification || '',
      manufacturer: row.manufacturer || '',
      source: row.source || 'search',
      createdAt: Number(row.createdAt || 0),
    }))
    return success({ items })
  }

  return fail('未知函数')
}
```
