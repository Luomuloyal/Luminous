# Luminous Ubuntu 服务器部署手册（一步一步）

更新时间：2026-04-03

这份文档只讲一件事：
把你的项目上传到 Ubuntu 服务器并跑起来。

你的本地目录是：
- D:\25080\Documents\AndroidStudioProjects\Luminous
- D:\25080\Documents\AndroidStudioProjects\LuminousWebsite
- D:\25080\Documents\AndroidStudioProjects\LuminousPPT

## 0. 先准备好这 3 个信息

- 服务器 IP（例：1.2.3.4）
- 服务器登录用户（例：ubuntu）
- 你的主域名（个人网站，例如 `your-domain.com`）
- 你的 luminous 子域名（例如 `luminous.your-domain.com`）

后面的命令把这些值替换成你的真实值。

你要的目标架构可以实现，推荐这样分工：
- `your-domain.com`：继续是你的个人网站入口（不动）
- `luminous.your-domain.com`：Luminous 网站 + App API + 下载资源
- `luminous.your-domain.com/api/*`：App 后端接口

当前 Nginx 路由规则是：
- `/api/site-manifest` 转发到网站后端（site-backend）
- `/downloads/*`、`/media/*` 转发到网站后端（site-backend）
- 其他 `/api/*` 转发到 App 后端（app-backend）

---

## 1. 服务器先安装 Docker（只做一次）

先登录服务器：

```bash
ssh ubuntu@your.server.ip
```

安装 Docker：

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg unzip
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

执行后重新登录一次服务器（让 docker 用户组生效）。

---

## 2. 本地打包（只用于上传，不是本地运行）

在 Windows PowerShell 执行：

```powershell
cd D:\25080\Documents\AndroidStudioProjects\Luminous
powershell -ExecutionPolicy Bypass -File .\deploy\prepare_upload.ps1
```

会生成：
- D:\25080\Documents\AndroidStudioProjects\_luminous_upload.zip

---

## 3. 上传到服务器并解压到固定位置

### 3.1 上传 zip

```powershell
scp D:\25080\Documents\AndroidStudioProjects\_luminous_upload.zip ubuntu@your.server.ip:/tmp/luminous_upload.zip
```

### 3.2 在服务器解压

```bash
ssh ubuntu@your.server.ip
sudo mkdir -p /opt/luminous
sudo chown -R $USER:$USER /opt/luminous
cd /opt/luminous
unzip -o /tmp/luminous_upload.zip
```

解压后目录应是：

```text
/opt/luminous/
	docker-compose.prod.yml
	backend/
	site-backend/
	site-frontend/dist/
	ppt/
	deploy/nginx/luminous.conf
	deploy/env/.env.app-backend.production.example
	deploy/env/.env.site-backend.production.example
```

---

## 4. 必须编辑的 3 个文件

### 4.1 Nginx 域名文件

编辑：

```bash
nano /opt/luminous/deploy/nginx/luminous.conf
```

把占位符换成你的 luminous 子域名：
- `luminous.your-domain.com`

### 4.2 App 后端环境变量

```bash
cp /opt/luminous/deploy/env/.env.app-backend.production.example /opt/luminous/deploy/env/.env.app-backend.production
nano /opt/luminous/deploy/env/.env.app-backend.production
```

至少要改这些字段：
- `CORS_ORIGIN`
- `MYSQL_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `DOUBAO_API_KEY`

注意：`MYSQL_HOST`、`REDIS_URL`、`MONGODB_URI` 保持容器服务名写法，不要改成 127.0.0.1。

### 4.3 网站后端环境变量

```bash
cp /opt/luminous/deploy/env/.env.site-backend.production.example /opt/luminous/deploy/env/.env.site-backend.production
nano /opt/luminous/deploy/env/.env.site-backend.production
```

至少确认：
- `PORT=3030`
- `CORS_ORIGIN=https://luminous.你的主域名`

---

## 5. 上传 SSL 证书到指定位置

服务器必须有这两个文件：
- /opt/luminous/deploy/certs/fullchain.pem
- /opt/luminous/deploy/certs/privkey.pem

如果证书在你本地 Windows（示例路径）：

```powershell
scp C:\path\to\fullchain.pem ubuntu@your.server.ip:/opt/luminous/deploy/certs/fullchain.pem
scp C:\path\to\privkey.pem ubuntu@your.server.ip:/opt/luminous/deploy/certs/privkey.pem
```

---

## 6. 运行服务（真正上线）

在服务器执行：

```bash
cd /opt/luminous
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml ps
```

如果看到 `nginx`、`app-backend`、`site-backend`、`mongodb`、`redis`、`mysql` 都是 Up，就说明启动成功。

---

## 7. 访问验证（只测这 4 个地址）

- https://luminous.your-domain.com/
- https://luminous.your-domain.com/api/site-manifest
- https://luminous.your-domain.com/ppt/
- https://luminous.your-domain.com/health

4 个都正常，就是上线完成。

---

## 8. 如果失败，按这个顺序排查

先看容器状态：

```bash
docker compose -f /opt/luminous/docker-compose.prod.yml ps
```

再看日志：

```bash
docker compose -f /opt/luminous/docker-compose.prod.yml logs -f nginx
docker compose -f /opt/luminous/docker-compose.prod.yml logs -f app-backend
docker compose -f /opt/luminous/docker-compose.prod.yml logs -f site-backend
```

最常见问题：
- 域名没有解析到服务器 IP
- 主域名和 luminous 子域名 DNS 记录配错
- 证书文件路径不对
- env 里的密钥或数据库密码未填
- 改完配置后忘了重新 `up -d --build`

---

## 9. 每次更新版本怎么做

1. 本地重新运行：`deploy/prepare_upload.ps1`
2. 重新上传 `_luminous_upload.zip`
3. 服务器重新解压到 `/opt/luminous`
4. 执行：

```bash
cd /opt/luminous
docker compose -f docker-compose.prod.yml up -d --build
```

---

## 10. 上线前最低检查

- [ ] 密钥已更换（JWT、数据库、DOUBAO）
- [ ] 仓库里没有真实生产 env
- [ ] 域名解析已生效
- [ ] 证书已放到 `/opt/luminous/deploy/certs`

完整检查见 [PRE_RELEASE_CHECKLIST.md](PRE_RELEASE_CHECKLIST.md)。
