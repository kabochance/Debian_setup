#!/bin/bash

# Debian Awesome WM Environment Setup Script
# Usage: wget -O - https://raw.githubusercontent.com/YOUR_USERNAME/debian-awesome-setup/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script as root. Run as a regular user with sudo privileges."
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    error "sudo is required but not installed. Please install sudo first."
fi

# Check if running on Debian
if ! grep -q "Debian" /etc/os-release; then
    warn "This script is designed for Debian. Other distributions may not work correctly."
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

log "Starting Debian Awesome WM environment setup..."

# Update system
log "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install basic packages
log "Installing basic packages..."
sudo apt install -y curl wget git build-essential

# Install X Window System and awesome WM
log "Installing X Window System and awesome WM..."
sudo apt install -y xorg lightdm awesome

# Install Japanese fonts
log "Installing Japanese fonts..."
sudo apt install -y fonts-noto-cjk fonts-noto-cjk-extra fonts-takao fonts-liberation fonts-noto-color-emoji

# Configure Japanese locale
log "Configuring Japanese locale..."
sudo apt install -y locales
echo "ja_JP.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
sudo locale-gen

# Install fcitx5 for Japanese input
log "Installing fcitx5 for Japanese input..."
sudo apt install -y fcitx5 fcitx5-mozc fcitx5-config-qt fcitx5-frontend-gtk2 fcitx5-frontend-gtk3 fcitx5-frontend-qt5

# Install applications
log "Installing applications..."
sudo apt install -y alacritty kate krusader kio-extras firefox-esr

# Install system management tools
log "Installing system management tools..."
sudo apt install -y network-manager network-manager-gnome pulseaudio pavucontrol volumeicon-alsa dunst clipit bluetooth bluez bluez-tools blueman acpi acpi-support laptop-mode-tools udisks2 udiskie pcmanfm

# Install additional useful tools
log "Installing additional tools..."
sudo apt install -y htop neofetch scrot feh

# Create awesome configuration directory
log "Setting up awesome WM configuration..."
mkdir -p ~/.config/awesome
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/

# Create alacritty configuration
log "Setting up alacritty configuration..."
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'EOF'
window:
  opacity: 0.9
  
font:
  normal:
    family: Noto Sans Mono CJK JP
  size: 12

colors:
  primary:
    background: '0x1e1e1e'
    foreground: '0xffffff'
EOF

# Create dunst configuration
log "Setting up dunst configuration..."
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'EOF'
[global]
    font = Noto Sans CJK JP 10
    allow_markup = yes
    format = "%s\n%b"
    sort = yes
    indicate_hidden = yes
    alignment = left
    bounce_freq = 0
    show_age_threshold = 60
    word_wrap = yes
    ignore_newline = no
    geometry = "300x5-30+20"
    shrink = no
    transparency = 0
    idle_threshold = 120
    monitor = 0
    follow = mouse
    sticky_history = yes
    history_length = 20
    show_indicators = yes
    line_height = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    separator_color = frame
    startup_notification = false
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox
    icon_position = left
    max_icon_size = 32

[urgency_low]
    background = "#222222"
    foreground = "#888888"
    timeout = 10

[urgency_normal]
    background = "#285577"
    foreground = "#ffffff"
    timeout = 10

[urgency_critical]
    background = "#900000"
    foreground = "#ffffff"
    timeout = 0
EOF

# Set up environment variables for fcitx5
log "Setting up fcitx5 environment variables..."
{
    echo 'export GTK_IM_MODULE=fcitx5'
    echo 'export QT_IM_MODULE=fcitx5'
    echo 'export XMODIFIERS=@im=fcitx5'
    echo 'export DefaultIMModule=fcitx5'
} >> ~/.bashrc

# Create awesome WM configuration with auto-start applications
log "Configuring awesome WM with auto-start applications..."
cat >> ~/.config/awesome/rc.lua << 'EOF'

-- Auto-start applications
awful.spawn.with_shell("nm-applet")
awful.spawn.with_shell("volumeicon")
awful.spawn.with_shell("clipit")
awful.spawn.with_shell("blueman-applet")
awful.spawn.with_shell("udiskie --tray")
awful.spawn.with_shell("dunst")
awful.spawn.with_shell("fcitx5")

-- Application key bindings
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "Return", function () awful.spawn("alacritty") end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey }, "e", function () awful.spawn("kate") end,
              {description = "open kate", group = "launcher"}),
    awful.key({ modkey }, "f", function () awful.spawn("krusader") end,
              {description = "open krusader", group = "launcher"}),
    awful.key({ modkey }, "w", function () awful.spawn("firefox") end,
              {description = "open firefox", group = "launcher"})
)

-- Battery widget
battery_widget = wibox.widget.textbox()
battery_widget:set_text("Battery: N/A")

-- Volume widget
volume_widget = wibox.widget.textbox()
volume_widget:set_text("Vol: N/A")

-- Update timer for system info
gears.timer {
    timeout = 30,
    call_now = true,
    autostart = true,
    callback = function()
        awful.spawn.easy_async("acpi -b", function(stdout)
            if stdout ~= "" then
                local battery_info = stdout:match("(%d+%%)")
                if battery_info then
                    battery_widget:set_text("🔋 " .. battery_info)
                end
            end
        end)
        
        awful.spawn.easy_async("amixer get Master", function(stdout)
            local volume = stdout:match("(%d+)%%")
            if volume then
                volume_widget:set_text("🔊 " .. volume .. "%")
            end
        end)
    end
}

-- Add widgets to the wibar (you may need to modify this based on your wibar setup)
-- s.mywibox:setup {
--     layout = wibox.layout.align.horizontal,
--     { -- Left widgets
--         layout = wibox.layout.fixed.horizontal,
--         mylauncher,
--         s.mytaglist,
--         s.mypromptbox,
--     },
--     s.mytasklist, -- Middle widget
--     { -- Right widgets
--         layout = wibox.layout.fixed.horizontal,
--         battery_widget,
--         volume_widget,
--         mykeyboardlayout,
--         wibox.widget.systray(),
--         mytextclock,
--         s.mylayoutbox,
--     },
-- }
EOF

# Set up services
log "Configuring system services..."
sudo usermod -a -G audio $USER
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# Create post-installation instructions
log "Creating post-installation instructions..."
cat > ~/awesome-setup-complete.txt << 'EOF'
Debian Awesome WM Environment Setup Complete!

Next steps:
1. Reboot your system: sudo reboot
2. At the login screen, select "awesome" as your session
3. After login, configure fcitx5:
   - Open terminal: Mod4 + Return
   - Run: fcitx5-config-qt
   - In "Input Method" tab, click "+" and add "Mozc"
   - Use Ctrl+Space to toggle Japanese input

Key bindings:
- Mod4 + Return: Open alacritty (terminal)
- Mod4 + e: Open kate (editor)
- Mod4 + f: Open krusader (file manager)
- Mod4 + w: Open firefox (web browser)
- Ctrl + Space: Toggle Japanese input

System tray should show:
- Network Manager
- Volume control
- Clipboard manager
- Bluetooth manager
- Auto-mount notifications

If you encounter any issues, check:
- Japanese input: killall fcitx5 && fcitx5 &
- Audio: pulseaudio -k && pulseaudio --start
- Network: sudo systemctl restart NetworkManager

Enjoy your new Debian Awesome WM environment!
EOF

log "Setup completed successfully!"
log "Please read ~/awesome-setup-complete.txt for next steps."
log "You need to reboot to complete the installation."

read -p "Do you want to reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting..."
    sudo reboot
else
    log "Please reboot manually when ready."
fi
