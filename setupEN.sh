#!/bin/bash

# Debian 12 setup script (English version)
# Execute with: bash setup.sh

set -e

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
   exit 1
fi

# Check if running on Debian
if ! grep -q "Debian" /etc/os-release; then
    error "This script is designed for Debian systems only"
    exit 1
fi

log "Starting Debian 12 setup..."

# Update system
log "Updating package list..."
sudo apt update

log "Upgrading system packages..."
sudo apt upgrade -y

# Install essential packages
log "Installing essential packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    unzip \
    zip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install multimedia codecs
log "Installing multimedia codecs..."
sudo apt install -y \
    ubuntu-restricted-extras \
    ffmpeg \
    vlc \
    gimp \
    audacity 2>/dev/null || {
    warning "Some multimedia packages failed to install. This is normal on some systems."
}

# Install development tools
log "Installing development tools..."
sudo apt install -y \
    python3 \
    python3-pip \
    nodejs \
    npm \
    default-jdk \
    gcc \
    g++ \
    make \
    cmake

# Install Docker
log "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    log "Docker installed. Please logout and login again to use Docker without sudo."
else
    info "Docker is already installed"
fi

# Install Visual Studio Code
log "Installing Visual Studio Code..."
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
else
    info "Visual Studio Code is already installed"
fi

# Install Google Chrome
log "Installing Google Chrome..."
if ! command -v google-chrome &> /dev/null; then
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt update
    sudo apt install -y google-chrome-stable
else
    info "Google Chrome is already installed"
fi

# Install additional useful tools
log "Installing additional useful tools..."
sudo apt install -y \
    neofetch \
    screenfetch \
    zsh \
    fish \
    tmux \
    screen \
    ncdu \
    duf \
    bat \
    exa \
    ripgrep \
    fd-find \
    fzf

# Install Oh My Zsh (optional)
read -p "Do you want to install Oh My Zsh? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Change shell to zsh
    chsh -s $(which zsh)
    log "Shell changed to zsh. Please logout and login again to use zsh."
fi

# Install Flatpak
log "Installing Flatpak..."
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Clean up
log "Cleaning up package cache..."
sudo apt autoremove -y
sudo apt autoclean

# Setup firewall
log "Setting up UFW firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Install and configure fail2ban
log "Installing fail2ban..."
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Create useful aliases
log "Creating useful aliases..."
cat >> ~/.bashrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias h='history'
alias c='clear'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias mkdir='mkdir -pv'
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
EOF

# Configure git (if not already configured)
if ! git config --global user.name &> /dev/null; then
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    log "Git configured with username: $git_username and email: $git_email"
fi

# Install additional Python packages
log "Installing useful Python packages..."
pip3 install --user \
    requests \
    beautifulsoup4 \
    pandas \
    numpy \
    matplotlib \
    jupyter \
    youtube-dl \
    speedtest-cli

# Install Node.js global packages
log "Installing useful Node.js packages..."
sudo npm install -g \
    yarn \
    http-server \
    live-server \
    nodemon \
    pm2 \
    create-react-app \
    @vue/cli

# Final system information
log "Setup completed successfully!"
echo
info "System Information:"
neofetch 2>/dev/null || {
    echo "OS: $(lsb_release -d | cut -f2)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $2}')"
}

log "Please reboot your system to ensure all changes take effect."
warning "Remember to logout and login again to use Docker without sudo and to use zsh if installed."

echo
info "Installed packages summary:"
echo "- Essential development tools (git, vim, build-essential, etc.)"
echo "- Docker and Docker Compose"
echo "- Visual Studio Code"
echo "- Google Chrome"
echo "- Python3 with pip and useful packages"
echo "- Node.js with npm and useful global packages"
echo "- Multimedia codecs and applications"
echo "- Modern CLI tools (bat, exa, ripgrep, fzf, etc.)"
echo "- Flatpak package manager"
echo "- UFW firewall (enabled)"
echo "- fail2ban for security"
echo "- Useful shell aliases"

echo
log "Your Debian system is now ready for development and daily use!"
