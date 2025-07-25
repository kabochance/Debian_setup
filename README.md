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
- **CADQuery+gears
- **git
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
sudo dhclient
wget -O - https://raw.githubusercontent.com/kabochance/Debian_setup/main/setup.sh | bash
```

### または手動でダウンロード

```bash
sudo dhclient

wget https://raw.githubusercontent.com/kabochance/Debian_setup/main/setup.sh
chmod +x install.sh
./install.sh
```

## インストール後の設定

1. **再起動**

2. **Flatpakの導入**
  sudo apt install flatpak
  sudo apt install gnome-software-plugin-flatpak # Software centerにFlatpakを追加します（必須ではありません）
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

3. **PrusaSlicerのインストール**
   flatpak install flathub com.prusa3d.PrusaSlicer
   flatpak run com.prusa3d.PrusaSlicer #起動
   ショートカットキーとしてWin+p
   
4. **alacrittyの設定**
   テーマいれるとかマウスの設定とか透過処理とか

5. **ROCmのインストール**

6. **ollama**
   
## キーバインド

- `Mod4 + Return`: alacritty起動
- `Mod4 + e`: kate起動
- `Mod4 + f`: ファイラ起動
- `Mod4 + w`: firefox起動
- `Ctrl + Space`: 日本語入力切り替え

## カスタマイズ

### awesome WM設定

設定ファイル: `~/.config/awesome/rc.lua`

### alacritty設定

設定ファイル: `~/.config/alacritty/alacritty.yml`

### dunst通知設定

設定ファイル: `~/.config/dunst/dunstrc`


## 更新履歴

- v1.0.0: 初回リリース
