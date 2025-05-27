#!/data/data/com.termux/files/usr/bin/bash

# ============ Banner & Input Section ============
echo -e "\n\033[1;34m[ EthixGuard Secure Terminal Setup ]\033[0m"

# ============ Device Info & Root Checker ============
echo -e "\n\033[1;33m[ Device Information ]\033[0m"
echo "Device: $(getprop ro.product.model)"
echo "OS: $(getprop ro.build.version.release)"
echo "IP Address: $(ip a | grep 'inet ' | grep -v 127 | awk '{print $2}' | head -n1)"
echo "Root Access: $(su -c "echo YES" 2>/dev/null || echo NO)"

# ============ User Input ============
read -p "Enter Banner Name (e.g., Cyber Ethix): " BANNER_NAME
read -p "Enter Tagline 1 (Optional): " TAG1
read -p "Enter Tagline 2 (Optional): " TAG2
read -p "Enter Tagline 3 (Optional): " TAG3

# ============ Option Menu ============
echo -e "\n\033[1;36mSelect an Option:\033[0m"
echo "1. Install"
echo "2. Reset Configuration"
echo "3. Uninstall"
read -p "Enter your choice (1/2/3): " OPTION

if [[ "$OPTION" == "2" ]]; then
  cp ~/.zshrc.bak ~/.zshrc && echo "Restored previous .zshrc backup. Restart Termux."
  exit
elif [[ "$OPTION" == "3" ]]; then
  rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zshrc.bak ~/.termux_lock ~/.termux_attempt ~/.termux_log ~/.pass.enc ~/.ethix_theme && echo "Uninstalled EthixGuard configuration."
  exit
fi

# ============ Backup Old zshrc ============
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak

# ============ Theme Selection ============
echo -e "\n\033[1;36mSelect a Theme:\033[0m"
echo "1. Light (Green prompt)"
echo "2. Dark (White prompt)"
echo "3. Neon (Multi-color prompt)"
read -p "Enter theme number: " THEME_NUM
echo "$THEME_NUM" > ~/.ethix_theme

# ============ Password Setup ============
while true; do
  read -s -p "Set Access Password: " PASSWORD
  echo ""
  read -s -p "Confirm Password: " CONFIRM_PASS
  echo ""
  if [ "$PASSWORD" == "$CONFIRM_PASS" ]; then
    echo -n "$PASSWORD" | openssl enc -aes-256-cbc -salt -out ~/.pass.enc -k secret_key
    break
  else
    echo -e "\nPasswords do not match. Try again."
  fi
done

read -p "Enter Custom Username: " USERNAME
read -p "Enter Custom Hostname: " HOSTNAME

# ============ Package Installation ============
pkg update -y && pkg upgrade -y
pkg install ruby figlet zsh git curl wget openssl-tool -y
gem install lolcat

# ============ Install Oh My Zsh ============
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# ============ Zsh Plugins ============
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# ============ .zshrc Generation ============
cat > ~/.zshrc << EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh

# Display banner and taglines once per session
if [ -z "\$BANNER_SHOWN" ]; then
  export BANNER_SHOWN=true
  clear
  figlet -f small "$BANNER_NAME" | lolcat
  echo -e "\\033[1;32m$TAG1"
  echo -e "\\033[1;36m$TAG2"
  echo -e "\\033[1;35m$TAG3"
  echo -e "\\033[1;33mDate : \$(date '+%d-%m-%Y')\\033[0m"
  echo -e "\\033[1;34mTime : \$(date '+%I:%M:%S %p')\\033[0m"

  correct_password=\$(openssl enc -aes-256-cbc -d -in ~/.pass.enc -k secret_key 2>/dev/null)
  attemptfile="\$HOME/.termux_attempt"
  lockfile="\$HOME/.termux_lock"
  logfile="\$HOME/.termux_log"
  max_attempts=5

  # Lock check
  if [ -f "\$lockfile" ]; then
    locktime=\$(cat "\$lockfile")
    if (( \$(date +%s) < locktime )); then
      echo -e "\\nToo many incorrect attempts. Terminal locked. Try again later."
      exit
    else
      rm -f "\$lockfile" "\$attemptfile"
    fi
  fi

  attempts=\$(cat "\$attemptfile" 2>/dev/null || echo 0)
  while [[ \$attempts -lt \$max_attempts ]]; do
    echo -n "Enter Password: "; read -s input_password; echo ""
    if [[ "\$input_password" == "\$correct_password" ]]; then
      echo "Access granted."
      echo "[\$(date)] LOGIN SUCCESS" >> "\$logfile"
      rm -f "\$attemptfile"
      printf '\\a'  # beep sound
      break
    else
      attempts=\$((attempts + 1))
      echo "\$attempts" > "\$attemptfile"
      echo "[\$(date)] Wrong password attempt \$attempts" >> "\$logfile"
      echo -e "\\nIncorrect password. Attempts left: \$((max_attempts - attempts))"
    fi
    if [[ \$attempts -eq \$max_attempts ]]; then
      wait_time=600
      echo \$((\$(date +%s) + wait_time)) > "\$lockfile"
      echo -e "\\nToo many incorrect attempts. Terminal locked for 10 minutes."
      echo "[\$(date)] Terminal locked." >> "\$logfile"
      exit
    fi
  done

  # Welcome message with typing effect
  text="Welcome to your cyber terminal..."
  for ((i=0; i<\${#text}; i++)); do
    echo -n "\${text:\$i:1}"
    sleep 0.03
  done
  echo -e "\\n\\033[1;90m[ Press any key to continue... ]\\033[0m"
  read -n 1
  clear
fi

# Function to show time above the prompt
function show_time() {
  echo -e "\\033[1;94m\$(date '+%I:%M:%S %p')\\033[0m"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd show_time

# Prompt with custom username and hostname from user input
THEME_NUM=\$(cat ~/.ethix_theme 2>/dev/null)
if [[ \$THEME_NUM == "1" ]]; then
  export PROMPT='%F{green}'"$USERNAME"'@%F{white}'"$HOSTNAME"' %F{blue}%~ %f\$ '
elif [[ \$THEME_NUM == "2" ]]; then
  export PROMPT='%F{white}'"$USERNAME"'@'"$HOSTNAME"' %~ %f\$ '
elif [[ \$THEME_NUM == "3" ]]; then
  export PROMPT='%F{magenta}'"$USERNAME"'%f@%F{cyan}'"$HOSTNAME"' %F{yellow}%~ %f\$ '
else
  export PROMPT='%F{green}'"$USERNAME"'@%F{cyan}'"$HOSTNAME"' %F{white}%~ %f\$ '
fi
EOF

# ============ Finish ============
# ============ Finish ============
rm -f /data/data/com.termux/files/usr/etc/motd
clear
echo -e "\n\033[1;34m[ These tools were developed by Cyber Ethix BD. ]\033[0m"
echo -e "\n\033[1;32m[✓] .......... Setup Complete! \033[0m" | lolcat
sleep 0.5
echo -e "\033[1;36m....Restarting Termux to apply\033[0m" | lolcat
sleep 0.5
echo -e "\033[1;33mYour custom Cyber Terminal is ready!\033[0m" | lolcat
sleep 0.5
echo -e "\n\033[1;35m[ Press any key to restart your terminal session... ]\033[0m" | lolcat
read -n 1 -s
source ~/.zshrc
