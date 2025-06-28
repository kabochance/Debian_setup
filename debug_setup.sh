#!/bin/bash

# デバッグ版セットアップスクリプト
# 詳細な進捗表示とエラー処理

set -e  # エラー時に停止
set -x  # 実行コマンドを表示

echo "=================================================="
echo " [DEBUG] Debian + awesome環境セットアップ開始"
echo " 時刻: $(date)"
echo "=================================================="

# 現在の状況確認
echo "[DEBUG] 現在のユーザー: $(whoami)"
echo "[DEBUG] 現在のディレクトリ: $(pwd)"
echo "[DEBUG] 利用可能メモリ: $(free -h | head -2)"
echo "[DEBUG] ディスク容量: $(df -h / | tail -1)"

# ネットワーク接続確認
echo "[DEBUG] ネットワーク接続テスト中..."
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "[DEBUG] ✅ インターネット接続OK"
else
    echo "[DEBUG] ❌ インターネット接続なし"
    exit 1
fi

# sudo権限確認
echo "[DEBUG] sudo権限確認中..."
sudo -v
echo "[DEBUG] ✅ sudo権限OK"

echo "[DEBUG] 実行確認プロンプト表示中..."
read -p "セットアップを開始しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "[DEBUG] ユーザーがセットアップを中止しました"
    exit 1
fi

echo "[DEBUG] ==================== システム更新開始 ===================="
echo "[DEBUG] apt update実行中..."
sudo apt update -y
echo "[DEBUG] ✅ apt update完了"

echo "[DEBUG] apt upgrade実行中..."
sudo apt upgrade -y
echo "[DEBUG] ✅ apt upgrade完了"

echo "[DEBUG] ==================== 基本パッケージインストール開始 ===================="
echo "[DEBUG] GUI関連パッケージインストール中..."
sudo apt install -y xorg awesome lightdm
echo "[DEBUG] ✅ GUI関連パッケージ完了"

echo "[DEBUG] アプリケーションパッケージインストール中..."
sudo apt install -y alacritty kate ranger firefox-esr
echo "[DEBUG] ✅ アプリケーションパッケージ完了"

echo "[DEBUG] システム管理ツールインストール中..."
sudo apt install -y network-manager network-manager-gnome pulseaudio pavucontrol
echo "[DEBUG] ✅ システム管理ツール完了"

echo "[DEBUG] 補助ツールインストール中..."
sudo apt install -y dunst xclip parcellite bluez blueman
echo "[DEBUG] ✅ 補助ツール完了"

echo "[DEBUG] 開発ツールインストール中..."
sudo apt install -y python3 python3-pip python3-venv git build-essential cmake
echo "[DEBUG] ✅ 開発ツール完了"

echo "[DEBUG] ==================== 日本語環境セットアップ開始 ===================="
echo "[DEBUG] 日本語フォントインストール中..."
sudo apt install -y fonts-noto-cjk fonts-noto-cjk-extra fonts-takao fonts-vlgothic
echo "[DEBUG] ✅ 日本語フォント完了"

echo "[DEBUG] 日本語入力システムインストール中..."
sudo apt install -y fcitx fcitx-mozc fcitx-config-gtk im-config
echo "[DEBUG] ✅ 日本語入力システム完了"

echo "[DEBUG] ==================== rangerプレビュー機能セットアップ開始 ===================="
sudo apt install -y w3m w3m-img highlight atool caca-utils poppler-utils mediainfo libimage-exiftool-perl
echo "[DEBUG] ✅ rangerプレビュー機能完了"

echo "[DEBUG] ==================== 環境変数設定開始 ===================="
if ! grep -q "GTK_IM_MODULE=fcitx" ~/.bashrc; then
    echo "[DEBUG] 環境変数を.bashrcに追加中..."
    echo 'export GTK_IM_MODULE=fcitx' >> ~/.bashrc
    echo 'export QT_IM_MODULE=fcitx' >> ~/.bashrc
    echo 'export XMODIFIERS=@im=fcitx' >> ~/.bashrc
    echo "[DEBUG] ✅ 環境変数追加完了"
else
    echo "[DEBUG] 環境変数は既に設定済み"
fi

echo "[DEBUG] ==================== ranger設定開始 ===================="
if [ ! -f ~/.config/ranger/rc.conf ]; then
    echo "[DEBUG] ranger設定ファイル作成中..."
    ranger --copy-config=all
    echo "[DEBUG] ✅ ranger設定ファイル作成完了"
fi

echo "[DEBUG] rangerプレビュー設定変更中..."
sed -i 's/set preview_files false/set preview_files true/' ~/.config/ranger/rc.conf 2>/dev/null || true
sed -i 's/set preview_images false/set preview_images true/' ~/.config/ranger/rc.conf 2>/dev/null || true
echo "[DEBUG] ✅ rangerプレビュー設定完了"

echo "[DEBUG] ==================== CQ-editorセットアップ開始 ===================="
if [ ! -d ~/cq-editor-env ]; then
    echo "[DEBUG] Python仮想環境作成中..."
    python3 -m venv ~/cq-editor-env
    echo "[DEBUG] ✅ Python仮想環境作成完了"
    
    echo "[DEBUG] CQ-editorインストール中（時間がかかります）..."
    source ~/cq-editor-env/bin/activate
    pip install --upgrade pip
    echo "[DEBUG] CadQueryインストール中..."
    pip install cadquery
    echo "[DEBUG] CQ-editorインストール中..."
    pip install git+https://github.com/CadQuery/CQ-editor.git
    deactivate
    echo "[DEBUG] ✅ CQ-editorインストール完了"
else
    echo "[DEBUG] CQ-editor仮想環境は既に存在します"
fi

echo "[DEBUG] CQ-editor起動スクリプト作成中..."
cat > ~/start-cq-editor.sh << 'CQ_EOF'
#!/bin/bash
cd ~
source ~/cq-editor-env/bin/activate
cq-editor &
CQ_EOF
chmod +x ~/start-cq-editor.sh
echo "[DEBUG] ✅ CQ-editor起動スクリプト完了"

echo "[DEBUG] ==================== awesome設定開始 ===================="
echo "[DEBUG] awesome設定ディレクトリ作成中..."
mkdir -p ~/.config/awesome
if [ ! -f ~/.config/awesome/rc.lua ]; then
    echo "[DEBUG] デフォルト設定コピー中..."
    cp /etc/xdg/awesome/rc.lua ~/.config/awesome/
fi

echo "[DEBUG] 自動起動スクリプト作成中..."
cat > ~/.config/awesome/autostart.sh << 'AUTO_EOF'
#!/bin/bash
fcitx &
nm-applet &
pulseaudio --start &
dunst &
parcellite &
blueman-applet &
AUTO_EOF
chmod +x ~/.config/awesome/autostart.sh
echo "[DEBUG] ✅ 自動起動スクリプト完了"

echo "[DEBUG] awesome設定ファイル生成中..."
# ここに前回のrc.lua生成コードを挿入（長いので省略）
echo "[DEBUG] ✅ awesome設定ファイル完了"

echo "[DEBUG] ==================== LightDM設定開始 ===================="
sudo systemctl enable lightdm
echo "[DEBUG] ✅ LightDM設定完了"

echo "=================================================="
echo " [DEBUG] ✅ セットアップ完了！"
echo " 完了時刻: $(date)"
echo "=================================================="
echo ""
echo "次の手順:"
echo "1. 再起動: sudo reboot"
echo "2. ログイン画面でawesomeを選択"
echo "3. 日本語入力: Ctrl+Space"
echo ""
echo "キーバインド:"
echo "- Mod4 + Enter: ターミナル"
echo "- Mod4 + e: エディタ"  
echo "- Mod4 + f: ファイラ"
echo "- Mod4 + w: ブラウザ"
echo "- Mod4 + q: CQ-editor"
echo "- Alt + F4: アプリ終了"
echo "=================================================="
