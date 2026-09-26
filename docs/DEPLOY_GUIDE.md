# 从零开始：把自己的项目部署上线 —— 完整操作指南

> 适用对象：**没有任何编程 / 服务器基础**的新手。
> 适用项目：本仓库 VideoLinkCollector（也可以照葫芦画瓢用于其他前后端项目）。
> 最终目标：① 代码推到 GitHub；② GitHub Pages 静态演示页上线；③ 腾讯云服务器跑通真实后端；④ Cloudflare 域名解析到服务器，用 `https://你的域名` 访问完整动态项目。

本指南所有命令都给出了**可以直接复制的完整写法**。`你的用户名`、`你的公网IP`、`你的域名` 等占位内容请替换成你自己的值。

---

## 第 0 章 准备工作（先花 30 分钟注册好账号和工具）

### 0.1 注册 GitHub 账号（免费）

1. 浏览器打开 <https://github.com>，点击右上角 **Sign up**。
2. 按提示填邮箱、设置密码（建议 12 位以上混合大小写数字）、验证邮箱。
3. 完成注册后记住你的 **用户名**（登录 GitHub 后左上角显示的名字，例如 `Dreamy236`）。

### 0.2 注册腾讯云账号（购买服务器用，免费注册）

1. 打开 <https://cloud.tencent.com>，点右上角**注册/登录**（微信扫码即可）。
2. 按提示完成**实名认证**（个人实名：身份证 + 人脸识别，几分钟完成）——不实名无法购买服务器。

### 0.3 注册 Cloudflare 账号（免费域名接入）

1. 打开 <https://dash.cloudflare.com>，用邮箱注册。
2. 暂不需要其他操作，第 6 章再用。

### 0.4 安装 Git（Windows）

1. 打开 <https://git-scm.com/download/win>，下载 64-bit 安装包。
2. 双击安装，**一路点 Next**（所有选项保持默认即可）。
3. 验证安装：按 `Win 键`，输入 `powershell` 回车打开 PowerShell，输入：

```powershell
git --version
```

看到 `git version 2.x.x` 就成功了。

### 0.5 安装 Python（本机预览用，3.11 以上）

1. 打开 <https://www.python.org/downloads/>，下载 Windows installer。
2. 安装时**务必勾选**底部 "Add python.exe to PATH"。
3. 验证：

```powershell
python --version
```

### 0.6 生成 SSH 密钥并添加到 GitHub（推送代码的钥匙）

> 用 SSH 方式推送最省事（配置一次，以后不用每次输密码）。

1. 打开 PowerShell，输入（邮箱换成你自己的）：

```powershell
ssh-keygen -t ed25519 -C "你的邮箱@example.com"
```

2. 一路按回车（提示输入 passphrase 时直接回车跳过）。
3. 查看公钥内容：

```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
```

4. 全选复制输出的整行（以 `ssh-ed25519 AAAA...` 开头）。
5. 打开 GitHub → 右上角头像 → **Settings** → 左侧 **SSH and GPG keys** → 绿色按钮 **New SSH key** → Title 随便填（如 `my-pc`），Key 粘贴刚才复制的内容 → **Add SSH key**。

✅ 第 0 章完成。接下来开始推代码。

---

## 第 1 章 把项目文件推送到 GitHub（第一次）

### 1.1 在 GitHub 上创建空仓库

1. GitHub 右上角 **+** → **New repository**。
2. Repository name 填：`video_crack`（字母小写，这就是项目名）。
3. 可见性选 **Public**（GitHub Pages 免费版要求公开仓库）。
4. **不要勾选** "Add a README file"、".gitignore"、"license"（保持空仓库，避免和本地文件冲突）。
5. 点 **Create repository**。

创建后页面会显示一段命令，先别急着复制，跟着下面做。

### 1.2 配置你的 Git 身份（只需一次）

打开 PowerShell（确保当前目录是你的项目文件夹，可用 `cd E:\video_CDP\video_crack`）：

```powershell
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱@example.com"
```

### 1.3 初始化并推送

在项目文件夹的 PowerShell 里依次执行：

```powershell
# 1. 初始化本地仓库
git init

# 2. 把项目所有文件加入待提交状态
git add .

# 3. 提交（-m 后面是本次提交的说明文字）
git commit -m "first commit"

# 4. 把默认分支命名为 main
git branch -M main

# 5. 关联远程仓库（把地址里的 你的用户名 换成你自己的）
git remote add origin git@github.com:你的用户名/video_crack.git

# 6. 推送
git push -u origin main
```

### 1.4 验证

浏览器打开 `https://github.com/你的用户名/video_crack`，能看到项目文件就成功了。

> **第一次 push 报错排查**：
> - `Permission denied (publickey)` → 第 0.6 步的 SSH 密钥没配好，重新检查公钥是否已粘贴到 GitHub。
> - `Could not resolve host github.com` / 连接超时 → 网络问题，可换网络重试；或改用 https 方式：`git remote set-url origin https://github.com/你的用户名/video_crack.git`，push 时弹窗输入 GitHub 用户名和 Token（Token 获取见下方小贴士）。
> - 提示 `user.email` 不存在 → 回到 1.2 补配置。

> **小贴士：GitHub Token（密码）怎么拿**
> GitHub 头像 → Settings → 最底部 **Developer settings** → **Personal access tokens** → **Tokens (classic)** → **Generate new token** → 勾选 `repo` 权限 → 生成后**立刻复制**（只显示一次）。之后 https 方式 push 时，用户名填 GitHub 用户名，密码栏粘贴这个 Token。

---

## 第 2 章 以后修改代码，怎么更新推送

每次改完代码，只需要三条命令（在项目文件夹的 PowerShell 里）：

```powershell
# 1. 看改了什么（可选，确认无误）
git status

# 2. 加入并提交（可以只提交某几个文件：git add app.py README.md）
git add .
git commit -m "本次修改的说明，例如：fix: 修复B站解析失败问题"

# 3. 推送到远程
git push
```

**完整示例**：假设你修改了 `app.py` 和一个图片：

```powershell
git add app.py docs/screenshots/01.png
git commit -m "feat: 增加新功能"
git push
```

> **日常习惯建议**：
> - 每次提交说明写清楚"做了什么"，方便以后回滚（`git log --oneline` 看历史，`git reset --hard 提交号` 回退）。
> - 从 GitHub 拉取别人/远程最新代码：`git pull`（多人协作或换电脑时用）。
> - 多台电脑协作：每台电脑都要按 0.6 配置各自的 SSH 密钥并添加到 GitHub。

---

## 第 3 章 GitHub Pages 设置（让页面能在线访问）

GitHub Pages 可以免费托管**静态网页**（HTML/CSS/JS），本项目前端已内置"静态演示模式"，可以直接上线展示界面。

### 3.1 确认仓库自带发布配置

本项目根目录已有 `.github/workflows/pages.yml`，它会自动把 `frontend/` 目录发布成网站。**不需要自己写任何代码。**

### 3.2 打开 Pages 开关

1. 打开仓库页面 → **Settings**（页面上方标签）→ 左侧菜单 **Pages**。
2. **Source** 选择 **GitHub Actions**（注意：不是 "Deploy from a branch"）。
3. 保存后等 1-2 分钟。

### 3.3 触发发布（如果页面还没生成）

1. 打开仓库页面 → 上方标签 **Actions**。
2. 左侧选 **pages build and deployment** 工作流。
3. 点右侧 **Run workflow**（手动触发一次）→ 绿色对勾后完成。

### 3.4 访问你的演示页

```
https://你的用户名.github.io/video_crack/
```

打开后顶部应出现「🎬 GitHub Pages 静态演示模式」横幅，点「加载演示数据」可体验全部界面。

> **常见问题**：
> - 打开显示 README 文档而不是页面 → Actions 还没跑完，等 1 分钟刷新，或按 3.3 手动触发。
> - 页面 404 → 确认仓库是 Public，且 Settings → Pages 的 Source 是 GitHub Actions。
> - 以后每次 push 代码，Pages 会自动重新发布（无需手动操作）。
> - Pages 只能跑静态文件，**真实解析/下载功能需要连后端**：在网址后加 `?api=你的后端地址`，例如 `https://用户名.github.io/video_crack/?api=http://公网IP:8000`（注意 HTTPS 页面调 HTTP 接口会被浏览器拦截，见第 5 章用域名方案）。

---

## 第 4 章 腾讯云服务器：配置真实后端（让项目"活"起来）

Pages 只是展示壳子，真正能解析下载的是 Python 后端。下面是把它部署到腾讯云服务器的完整步骤。

### 4.1 购买一台服务器

1. 登录腾讯云 → 控制台 → 搜索 **轻量应用服务器**（新手首选，便宜简单）或 **云服务器 CVM**。
2. 点**新建/购买**：
   - 地域：选离你近的（如广州/上海）
   - 镜像：**系统镜像 → Ubuntu 22.04 LTS**
   - 套餐：2核 4GB 起（本项目够用）
   - 时长：按需（先买 1 个月体验）
3. **登录方式**选「**密钥**」：
   - 若之前没生成过密钥，选"新建密钥"，把第 0.6 步的**公钥内容**（`.pub` 文件里的整行）粘贴进去创建。
   - 绑定这个密钥到服务器（这样用本机私钥就能免密登录）。
4. 确认购买。记下服务器的**公网 IP**（控制台实例列表里显示，例如 `203.195.218.124`）。

### 4.2 放行防火墙端口（重要！）

1. 腾讯云控制台 → 你的服务器实例 → **防火墙**（轻量）或 **安全组**（CVM）。
2. 确保放行：
   - `22` 端口（SSH 连接，默认已开）
   - `8000` 端口（项目后端，需手动添加：协议 TCP，端口 8000，来源 0.0.0.0/0）
   - 后面接 Cloudflare 时再加 `80`、`443`。

### 4.3 第一次连上服务器

本机 PowerShell 执行（`公网IP` 换成你的，密钥路径换成你保存 `.pem`/私钥的位置；腾讯云密钥登录下载的密钥文件是 `.pem`）：

```powershell
ssh -i "E:\video_CDP\2g2g3m.pem" ubuntu@你的公网IP
```

> 首次连接提示 `Are you sure...` 输入 `yes` 回车。
> 连接成功会看到 `ubuntu@xxx:~$` 提示符，后面的操作都在这个服务器终端里执行。

### 4.4 服务器初始化（安装基础软件）

在服务器终端逐条执行：

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-venv python3-pip ffmpeg git
```

### 4.5 把项目代码放到服务器

**方法一（推荐，最简单）：服务器直接 clone 你的 GitHub 仓库**

```bash
cd /opt
sudo git clone https://github.com/你的用户名/video_crack.git video_link_collector
sudo chown -R $USER:$USER /opt/video_link_collector
```

> 仓库是 Public 的话 https clone 不需要密码。
> 以后更新代码：服务器上 `cd /opt/video_link_collector && git pull` 即可（配合第 5 章更新流程）。

**方法二：本机打包上传**

```powershell
# 本机 PowerShell 执行
cd E:\video_CDP\video_crack
git archive --format=tar -o E:\video_CDP\video_crack_src.tar HEAD
scp -i "E:\video_CDP\2g2g3m.pem" E:\video_CDP\video_crack_src.tar ubuntu@你的公网IP:/tmp/
```

服务器上解压：

```bash
sudo mkdir -p /opt/video_link_collector
sudo tar -xf /tmp/video_crack_src.tar -C /opt/video_link_collector
sudo chown -R $USER:$USER /opt/video_link_collector
```

### 4.6 创建虚拟环境并安装依赖

```bash
cd /opt/video_link_collector
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -r requirements.txt
```

### 4.7 安装 Playwright 浏览器（项目解析需要）

```bash
export PLAYWRIGHT_BROWSERS_PATH=$HOME/.cache/ms-playwright
.venv/bin/playwright install chromium
```

### 4.8 配置 systemd 让后端开机自启、常驻运行

创建服务配置文件：

```bash
sudo nano /etc/systemd/system/video-collector.service
```

把下面内容粘贴进去（`ubuntu` 换成你的服务器用户名，保持路径不变）：

```ini
[Unit]
Description=VideoLinkCollector backend
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/opt/video_link_collector
Environment=PLAYWRIGHT_BROWSERS_PATH=/home/ubuntu/.cache/ms-playwright
ExecStart=/opt/video_link_collector/.venv/bin/python app.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

> `nano` 编辑器操作：粘贴后按 `Ctrl+O` 回车保存，`Ctrl+X` 退出。
> 不会用 nano 也可以：`sudo tee /etc/systemd/system/video-collector.service <<'EOF' ... EOF`（PowerShell 用户建议直接在本机写好文件再 scp 上去）。

启用并启动：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now video-collector
sudo systemctl status video-collector
```

看到 `active (running)` 即成功。**确保 cookies/downloads/results 目录属主是你的用户**（root 会导致写文件报错）：

```bash
sudo chown -R ubuntu:ubuntu /opt/video_link_collector/cookies /opt/video_link_collector/downloads /opt/video_link_collector/results
```

### 4.9 验证后端健康

```bash
curl http://127.0.0.1:8000/api/health
```

返回 `{"ok": true, ...}` 就正常了。

### 4.10 本机浏览器访问

打开浏览器访问 `http://你的公网IP:8000`，页面能打开并操作解析/下载，**动态项目就上线了**。

> **日常运维命令**（服务器上执行）：
> - 看日志：`journalctl -u video-collector -f`
> - 重启：`sudo systemctl restart video-collector`
> - 停止：`sudo systemctl stop video-collector`
> - 改完代码更新流程：`cd /opt/video_link_collector && git pull` → `sudo systemctl restart video-collector`

> **注意**：`http://IP:8000` 是无加密、无鉴权的服务，**不要把这个地址公开传播**。正式对外请按第 6 章用 Cloudflare 域名 + HTTPS。

---

## 第 5 章 上线动态项目：三种形态怎么选

| 形态 | 怎么访问 | 适合谁 |
|---|---|---|
| **A. 纯 GitHub Pages 演示** | `https://用户名.github.io/video_crack/` | 展示界面、无真实功能 |
| **B. 服务器独立访问** | `http://公网IP:8000` | 自己用、测试 |
| **C. Pages 前端 + 服务器后端（前后端分离）** | `https://用户名.github.io/video_crack/?api=你的后端地址` | 想要好看域名+真实功能 |

**推荐形态 C**：前端静态页放 Pages（免费、快），后端放服务器。但要注意 **HTTPS 页面不能调用 HTTP 接口**（浏览器混合内容拦截）。所以后端地址也要是 HTTPS —— 这正是第 6 章 Cloudflare 要解决的问题。

**本项目实际推荐的最优方案**：直接用 Cloudflare 域名访问服务器一体化页面（第 6 章做完后访问 `https://你的域名` 即可），无需前后端分离，剪贴板等功能在 HTTPS 下也完全正常。

---

## 第 6 章 Cloudflare 域名链接到服务器（正式对外上线）

Cloudflare 免费提供：域名 DNS 管理 + HTTPS 加密 + CDN 加速 + 隐藏服务器真实 IP。

### 6.1 购买域名（任选一家，一年约 30-100 元）

- 国内：腾讯云域名、阿里云万网
- 国外：Namesilo、Namecheap
- 买一个你喜欢的域名，例如 `mytool.com`。

### 6.2 把域名接入 Cloudflare

1. 登录 <https://dash.cloudflare.com> → **Add a site**。
2. 输入你的域名（如 `mytool.com`）→ **Continue**。
3. 选择 **Free** 免费计划 → Continue。
4. Cloudflare 会给你**两个 NS 地址**（形如 `xxx.ns.cloudflare.com`、`yyy.ns.cloudflare.com`），复制保存。
5. 回到**域名注册商**的控制台，找到"DNS 服务器 / Nameservers"设置，把原来的 NS 改成 Cloudflare 给的两个（删除旧的，添加新的）。
6. 保存后回 Cloudflare 点 **Done, check nameservers**。等待生效（几分钟到 24 小时，通常 10 分钟内）。

### 6.3 添加 DNS 记录指向服务器

1. Cloudflare → 你的站点 → **DNS → Records** → **Add record**。
2. 添加一条：

| Type | Name | Content | Proxy status |
|---|---|---|---|
| A | `@`（或 `www`） | 你的服务器公网IP | 橙色云朵（Proxied，开启代理） |

3. 保存。

### 6.4 服务器开放 80/443 并配置反向代理

Cloudflare 只把 80/443 端口的请求转发给服务器，而项目跑在 8000 端口，所以要在服务器装 **nginx** 做转发。

服务器上执行：

```bash
sudo apt install -y nginx
```

创建站点配置：

```bash
sudo nano /etc/nginx/sites-available/video-crack
```

粘贴以下内容（`mytool.com` 换成你的域名）：

```nginx
server {
    listen 80;
    server_name mytool.com www.mytool.com;

    client_max_body_size 50m;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 300s;
    }
}
```

启用并重启：

```bash
sudo ln -s /etc/nginx/sites-available/video-crack /etc/nginx/sites-enabled/
sudo nginx -t          # 测试配置，输出 syntax is ok 即通过
sudo systemctl restart nginx
```

### 6.5 设置 SSL 加密方式

Cloudflare 控制台 → 你的站点 → **SSL/TLS** → **Overview**：

- 加密模式选 **Flexible**（免费方案最简单：用户到 Cloudflare 是 HTTPS，Cloudflare 到服务器用 HTTP 8000 —— 与上面 nginx 配置匹配）。
- 开启 **Always Use HTTPS**（强制跳转 https）。

> 想要更高级的"Full (strict)"（端到端加密）需要服务器装证书，新手先用 Flexible 即可满足 HTTPS 访问需求。

### 6.6 验证上线

1. 浏览器打开 `https://你的域名`。
2. 能看到项目页面、有锁图标（HTTPS 生效）→ **部署成功**。
3. 顺手测试：复制链接、解析视频、下载——HTTPS 下剪贴板等功能全部正常。

> **常见问题排查**：
> - **502 Bad Gateway** → nginx 连不上 8000：服务器上 `curl 127.0.0.1:8000/api/health` 是否通？不通就 `systemctl restart video-collector`；通了检查 nginx 配置里的 `proxy_pass` 端口。
> - **访问很慢 / 一直转圈** → 防火墙没放行 80/443：回到腾讯云控制台放行。
> - **打开是 nginx 默认页** → 站点配置没生效：检查 `sites-enabled` 软链接、`nginx -t`。
> - **DNS 没生效** → 等待并刷新；可用在线工具（如 whatsmydns.net）查域名解析状态。
> - **想隐藏 8000 端口**：在腾讯云防火墙里把 8000 端口删掉（只留 22/80/443），外部就只能走域名访问，更安全。

---

## 附录 A：日常更新项目到线上（全流程速查）

| 场景 | 操作 |
|---|---|
| 本机改完代码 | `git add .` → `git commit -m "说明"` → `git push` |
| 更新服务器代码 | `ssh 服务器` → `cd /opt/video_link_collector && git pull` → `sudo systemctl restart video-collector` |
| 更新 GitHub Pages | 推送代码后自动发布（无需手动） |
| 看服务器日志 | `journalctl -u video-collector -f` |
| 本机预览前端 | `cd frontend && python -m http.server 8080` → 打开 `http://127.0.0.1:8080/` |

## 附录 B：常用命令速查

```bash
# 本机
git status                        # 查看改动
git log --oneline                 # 查看提交历史
git reset --hard 提交号           # 回滚到某次提交（慎用）

# 服务器
ssh -i "密钥.pem" ubuntu@IP       # 连接
journalctl -u video-collector -f  # 实时日志
systemctl status video-collector  # 服务状态
curl http://127.0.0.1:8000/api/health   # 健康检查
```

## 附录 C：各平台账号清单（建议保存）

| 平台 | 账号 | 作用 | 网址 |
|---|---|---|---|
| GitHub | | 代码托管 + Pages | github.com |
| 腾讯云 | | 服务器 | cloud.tencent.com |
| Cloudflare | | 域名 + HTTPS | dash.cloudflare.com |
| 域名注册商 | | 域名购买 | 按你购买处 |
