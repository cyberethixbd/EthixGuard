#!/data/data/com.termux/files/usr/bin/bash

# ============ Banner & Input Section ============
echo -e "\n\033[1;34m[ EthixGuard Secure Terminal Setup ]\033[0m"


# ============ Device Info & Root Checker ============
echo -e "\n\033[1;33m[ Device Information ]\033[0m"
echo "Device: $(getprop ro.product.model)"
echo "OS: $(getprop ro.build.version.release)"
echo "IP Address: $(ip a | grep 'inet ' | grep -v 127 | awk '{print $2}' | head -n1)"
echo "Root Access: $(su -c \"echo YES\" 2>/dev/null || echo NO)"

read -p "Enter Banner Name (e.g., Cyber Ethic): " BANNER_NAME
read -p "Enter Tagline 1 (optional): " TAG1
read -p "Enter Tagline 2 (optional): " TAG2
read -p "Enter Tagline 3 (optional): " TAG3

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

if [ -z "\$BANNER_SHOWN" ]; then
  export BANNER_SHOWN=true
  clear
#!/bin/bash

# রঙের তালিকা (green, red, blue)
COLORS=("\033[1;32m" "\033[1;31m" "\033[1;34m")

# রঙ ট্র্যাক রাখার জন্য একটি ফাইল
COLOR_INDEX_FILE="$HOME/.cyber_color_index"

# প্রথমবার রান করলে ফাইল তৈরি করে 0 সেট করব
if [ ! -f "$COLOR_INDEX_FILE" ]; then
  echo 0 > "$COLOR_INDEX_FILE"
fi

# আগের রঙের ইনডেক্স পড়া
INDEX=$(cat "$COLOR_INDEX_FILE")

# বর্তমান রঙ নির্বাচন
CURRENT_COLOR=${COLORS[$INDEX]}

# পরবর্তী ইনডেক্স সেট (লুপ করে যাবে)
NEXT_INDEX=$(( (INDEX + 1) % ${#COLORS[@]} ))
echo $NEXT_INDEX > "$COLOR_INDEX_FILE"

# আপনার বাকি স্ক্রিপ্ট
figlet -f small "$BANNER_NAME" | lolcat
echo -e "\033[1;32m$TAG1"
echo -e "\033[1;36m$TAG2"
echo -e "\033[1;35m$TAG3"
echo -e "\033[1;33mDate : $(date '+%d-%m-%Y')\033[0m"
echo -e "${CURRENT_COLOR}Time : $(date '+%I:%M:%S %p')\033[0m"


  correct_password=\$(openssl enc -aes-256-cbc -d -in ~/.pass.enc -k secret_key 2>/dev/null)
  attemptfile="\$HOME/.termux_attempt"
  lockfile="\$HOME/.termux_lock"
  logfile="\$HOME/.termux_log"
  max_attempts=5

  if [ -f "\$lockfile" ]; then
    locktime=\$(cat "\$lockfile")
    if (( \$(date +%s) < locktime )); then
      echo "Terminal locked. Try again later."
      exit
    else
      rm -f "\$lockfile" "\$attemptfile"
    fi
  fi

  attempts=\$(cat "\$attemptfile" 2>/dev/null || echo 0)
  while [[ \$attempts -lt \$max_attempts ]]; do
    echo -n "Enter Password: "; read -s input_password; echo ""
    if [[ "\$input_password" == "\$correct_password" ]]; then
      echo "Access granted."; echo "[\$(date)] LOGIN SUCCESS" >> "\$logfile"
      rm -f "\$attemptfile"
      printf '\a'
      break
    else
      attempts=\$((attempts + 1))
      echo "\$attempts" > "\$attemptfile"
      echo "[\$(date)] Wrong password attempt \$attempts" >> "\$logfile"
      echo -e "Incorrect password. Attempts left: \$((max_attempts - attempts))"
    fi
    if [[ \$attempts -eq \$max_attempts ]]; then
      wait_time=600; echo \$((\$(date +%s) + wait_time)) > "\$lockfile"
      echo "Terminal locked for 10 minutes."; echo "[\$(date)] Terminal locked." >> "\$logfile"
      exit
    fi
  done

  for c in W e l c o m e \  t o \  y o u r \ C y b e r \ T e r m i n a l  . . .; do echo -n "\$c"; sleep 0.03; done
  echo -e "\n\033[1;90m[ Press any key to continue... ]\033[0m"; read -n 1; clear
fi

precmd() { echo -e "\033[1;94m\$(date '+%I:%M:%S %p')\033[0m"; }

# Load theme from ~/.ethix_theme
THEME_NUM=\$(cat ~/.ethix_theme 2>/dev/null)
if [[ \$THEME_NUM == "1" ]]; then
  export PROMPT='%F{green} $USERNAME@%F{white} $HOSTNAME %F{blue}%~ %f\$ '
elif [[ \$THEME_NUM == "2" ]]; then
  export PROMPT='%F{white} $USERNAME@$HOSTNAME %~ %f\$ '
elif [[ \$THEME_NUM == "3" ]]; then
  export PROMPT='%F{magenta}$USERNAME%f@%F{cyan}$HOSTNAME %F{yellow}%~ %f\$ '
else
  export PROMPT='%F{green} $USERNAME@%F{cyan} $HOSTNAME %F{white}%~ %f\$ '
fi
EOF

# ============ Finish ============
rm -f /data/data/com.termux/files/usr/etc/motd
# Avoid changing shell interactively; assume already zsh or let Termux handle it
# chsh -s zsh
clear
echo -e "\e[1;31m[✓] .....Setup Complete!....." | lolcat --spread=3 --speed=20
echo -e "\e[1;32m....These tools were developed by Cyber ​​Ethix BD..\nRestart Termux to apply your custom Cyber Terminal.\e[0m" | lolcat --spread=3 --speed=20 --reverse

