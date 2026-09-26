#!/usr/bin/env bash
# ============================================================
# VideoLinkCollector —— 腾讯云 CVM 一键部署脚本
# 适用系统：Ubuntu 22.04 / 24.04（腾讯云公共镜像默认支持）
# 实例建议：2C4G 及以上（按量计费记得用完关机/销毁，避免持续扣费）
# 用法：以 root 执行  sudo bash deploy_cvm.sh
# 效果：systemd 常驻服务监听 0.0.0.0:8000，开机自启，支持自动重启
# 可调参数：PORT=8080 bash deploy_cvm.sh   （换端口）
# ============================================================
set -euo pipefail

APP_DIR=/opt/video_link_collector
SERVICE=video-collector
PORT=${PORT:-8000}
REPO_URL=${REPO_URL:-https://github.com/Dreamy236/video_crack.git}

log(){ echo -e "\033[1;36m[deploy]\033[0m $*"; }
die(){ echo -e "\033[1;31m[deploy][ERROR]\033[0m $*"; exit 1; }

[ "$(id -u)" = 0 ] || die "请用 root 执行：sudo bash deploy_cvm.sh"

log "1/6 更新系统并安装基础依赖（python3 / ffmpeg / git 等）"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python3 python3-venv python3-pip ffmpeg git curl ca-certificates gnupg || die "apt 安装失败"

log "2/6 准备项目代码 -> $APP_DIR"
if [ "${SKIP_CLONE:-0}" = "1" ]; then
  log "SKIP_CLONE=1：使用已上传到 $APP_DIR 的代码（本机 scp 上传场景）"
  [ -f "$APP_DIR/app.py" ] || die "$APP_DIR/app.py 不存在，请先上传代码"
elif [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" pull --ff-only || log "pull 失败，继续使用现有代码"
else
  git clone --depth 1 "$REPO_URL" "$APP_DIR" || die "git clone 失败"
fi

log "3/6 创建虚拟环境并安装 Python 依赖（yt-dlp / playwright / requests / websockets）"
python3 -m venv "$APP_DIR/.venv"
"$APP_DIR/.venv/bin/pip" install --upgrade pip -q
"$APP_DIR/.venv/bin/pip" install -r "$APP_DIR/requirements.txt" -q || die "pip 安装失败"

log "4/6 安装 Playwright Chromium（含系统依赖，约 1-3 分钟；失败仅影响浏览器通道）"
"$APP_DIR/.venv/bin/playwright" install --with-deps chromium || log "Chromium 安装警告：浏览器登录/抖音直连通道将不可用，其余功能不受影响"

log "5/6 配置 systemd 常驻服务（开机自启 + 崩溃自动重启）"
mkdir -p "$APP_DIR/cookies" "$APP_DIR/downloads" "$APP_DIR/results"
cat > /etc/systemd/system/${SERVICE}.service <<EOF
[Unit]
Description=VideoLinkCollector (多平台视频链接采集与下载)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=$APP_DIR
Environment=HOST=0.0.0.0
Environment=PORT=$PORT
ExecStart=$APP_DIR/.venv/bin/python $APP_DIR/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable ${SERVICE} >/dev/null 2>&1
systemctl restart ${SERVICE}
sleep 3

log "6/6 服务状态检查"
systemctl --no-pager status ${SERVICE} | head -n 8 || true
HEALTH=$(curl -s --max-time 5 "http://127.0.0.1:${PORT}/api/health" || echo "服务未响应")
IP=$(curl -s4 --max-time 5 https://api.ipify.org 2>/dev/null || echo "<本机公网IP>")

echo ""
echo "============================================================"
echo "部署完成！"
echo "  - 本机自检：curl http://127.0.0.1:${PORT}/api/health"
echo "    -> $HEALTH"
echo "  - 公网访问：http://${IP}:${PORT}/"
echo "  - 下一步（重要）："
echo "    1) 腾讯云控制台 -> 轻量服务器/CVM -> 防火墙/安全组，放行 TCP ${PORT} 端口入站；"
echo "    2) 建议配置 nginx 反向代理 + HTTPS（详见 deploy/README_tencent.md）；"
echo "    3) 管理命令：systemctl {status|restart|stop} ${SERVICE}"
echo "============================================================"
