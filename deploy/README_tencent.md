# 腾讯云部署指引（VideoLinkCollector）

本项目采用「GitHub Pages 静态演示 + 腾讯云 CVM 真实后端」的组合部署：

- **GitHub Pages**：托管 `frontend/`，页面开箱即显示（静态演示模式，可加载演示数据）。
- **腾讯云 CVM**：运行完整 Python 后端，提供真实的链接解析 / 下载 / Cookie 登录。

---

## 一、购买服务器（腾讯云控制台）

| 项 | 建议值 | 说明 |
|---|---|---|
| 产品 | 轻量应用服务器 / CVM | 轻量服务器性价比高，个人使用足够 |
| 地域 | 离你最近（如广州/上海） | 影响访问速度 |
| 镜像 | **Ubuntu 24.04 LTS** | 部署脚本针对 Ubuntu 编写 |
| 规格 | **2C4G** 起步 | 跑 yt-dlp 合并转码不卡 |
| 带宽 | 3-5Mbps 按量或固定 | 下载文件走浏览器端，服务端带宽需求不高 |
| 登录 | 密钥 / 密码均可 | 推荐密钥登录 |

> ⚠️ 若使用**按量计费**：用完请关机（停止计费）或销毁实例，避免持续扣费。

购买后记录：**公网 IP**、**登录方式（密码或密钥）**。

## 二、安全组 / 防火墙放行端口

腾讯云控制台 → 该实例 → **防火墙 / 安全组** → 添加入站规则：

- `TCP 22`（SSH，一般默认已开）
- `TCP 8000`（Web 服务；若部署脚本用了 `PORT=8080` 则放行 8080）
- 若配置了 nginx + HTTPS：`TCP 80`、`TCP 443`

## 三、执行一键部署

**方式 A：直接在本机（Windows）用 SSH 上传执行**

```powershell
# 1) 把部署包传到服务器
scp -r E:\video_CDP\video_crack\deploy root@<公网IP>:/root/deploy

# 2) SSH 登录
ssh root@<公网IP>

# 3) 服务器上执行（会自动 clone 最新代码到 /opt/video_link_collector）
bash /root/deploy/deploy_cvm.sh
```

**方式 B：服务器上直接拉取仓库执行**

```bash
apt-get install -y git
git clone https://github.com/Dreamy236/video_crack.git /opt/video_link_collector
bash /opt/video_link_collector/deploy/deploy_cvm.sh
```

脚本会自动完成：装依赖（Python/ffmpeg/yt-dlp/playwright）→ clone 代码 → 建虚拟环境 → 装 Chromium → 配置 systemd 常驻服务 → 自检。

## 四、验证

```bash
curl http://127.0.0.1:8000/api/health
# 期望：{"ok": true, "playwright": true/false, "results_dir": "..."}

# 外网验证（在你自己的电脑浏览器打开）
http://<公网IP>:8000/
```

看到完整界面即部署成功。管理命令：

```bash
systemctl status video-collector    # 查看状态
systemctl restart video-collector   # 重启（改代码后）
systemctl stop video-collector      # 停止
journalctl -u video-collector -f    # 看日志
```

## 五、进阶：nginx 反代 + HTTPS（推荐）

目的：①隐藏端口号、用域名访问；②GitHub Pages（HTTPS）页面才能通过 `?api=` 跨域连接后端（浏览器会拦截对 `http://` 的混合内容请求）。

1. 域名解析：在腾讯云 DNSPod 把域名 A 记录指向 CVM 公网 IP。
2. 申请免费证书：腾讯云 SSL 证书控制台 → 免费证书（DV）→ 验证后下载 Nginx 版。
3. 安装 nginx 并配置：

```bash
apt-get install -y nginx
```

写入 `/etc/nginx/sites-available/video-collector`：

```nginx
server {
    listen 80;
    server_name 你的域名;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name 你的域名;

    ssl_certificate     /etc/nginx/ssl/你的证书.crt;
    ssl_certificate_key /etc/nginx/ssl/你的证书.key;

    client_max_body_size 500m;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_buffering off;   # SSE 实时进度必需
    }
}
```

```bash
ln -s /etc/nginx/sites-available/video-collector /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

之后：
- 直接访问：`https://你的域名/`（完整功能）
- GitHub Pages 页面带后端地址：`https://<用户名>.github.io/video_crack/?api=https://你的域名`

## 六、安全与合规提醒

- 服务无登录鉴权，公网开放仅供个人使用；不要公开分享你的服务器地址。
- 视频下载请仅下载你有权下载的内容，遵守各平台服务条款与当地法律法规。
- Cookie 等同账号凭据，仅存于服务器 `cookies/` 目录，勿外传；服务器请开启密钥登录并关闭密码登录。
