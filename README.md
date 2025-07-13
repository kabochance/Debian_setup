# Debian Awesome WM Environment Setup

Debian最小構成からawesome WM環境を自動構築するスクリプトです。

## 機能

- **Window Manager**: awesome WM
- **日本語入力**: fcitx + Mozc
- **日本語フォント**: Noto CJK フォント
- **ターミナル**: alacritty
- **エディタ**: kate
- **ファイルマネージャ**: 
- **ウェブブラウザ**: Firefox ESR
- **システム管理**:
  - NetworkManager (ネットワーク管理)
  - PulseAudio + pavucontrol (音量調整)
  - dunst (通知システム)
  - Diodon (クリップボード管理)
  - blueman (Bluetooth管理)
  - udiskie (自動マウント)
  - 電源管理ツール

## 使用方法

### ワンライナーでインストール

```bash
wget -O - https://raw.githubusercontent.com/kabochance/Debian_setup/main/setup.sh | bash
```

### または手動でダウンロード

```bash
wget https://raw.githubusercontent.com/kabochance/Debian_setup/main/setup.sh
chmod +x install.sh
./install.sh
```

## 前提条件

- Debian系OS
- sudoが使用可能なユーザー
- インターネット接続

## インストール後の設定

1. **再起動**
   ```bash
   sudo reboot
   ```

2. **ログイン画面でawesome WMを選択**

3. **fcitxの設定**
   - ターミナルを開く: `Mod4 + Return`
   - 設定ツールを起動: `fcitx-config-gtk3`
   - 「Input Method」タブで「+」をクリック
   - 「Only Show Current Language」のチェックを外す
   - 「Mozc」を検索して追加

## キーバインド

- `Mod4 + Return`: alacritty起動
- `Mod4 + e`: kate起動
- `Mod4 + f`: ファイラ起動
- `Mod4 + w`: firefox起動
- `Ctrl + Space`: 日本語入力切り替え

## トラブルシューティング

### 日本語入力が動作しない

```bash
# fcitxの再起動
killall fcitx && fcitx &

# 環境変数の確認
echo $GTK_IM_MODULE
```

### 音が出ない

```bash
# PulseAudioの再起動
pulseaudio -k && pulseaudio --start

# 音量確認
alsamixer
```

### ネットワークが接続できない

```bash
# NetworkManagerの再起動
sudo systemctl restart NetworkManager

# 状態確認
systemctl status NetworkManager
```

## カスタマイズ

### awesome WM設定

設定ファイル: `~/.config/awesome/rc.lua`

### alacritty設定

設定ファイル: `~/.config/alacritty/alacritty.yml`

### dunst通知設定

設定ファイル: `~/.config/dunst/dunstrc`

## やること

CAD-Query,CQ-editorのインストール
sudo apt update
sudo apt upgrade -y
sudo apt install python3-pip
sudo apt install python3-dev python3-venv libffi-dev libssl-dev build-essential
python3 -m venv cadquery-env
source cadquery-env/bin/activate
pip install cadquery cq-editor PySide2 spyder-kernels
python -m cq_editor

ショートカットで仮想環境作成とCQ-editor起動の割当

スライサー
ROCm
Ollama
StableD


## 更新履歴

- v1.0.0: 初回リリース
