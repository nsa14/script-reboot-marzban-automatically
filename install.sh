#!/bin/bash -e

echo
echo "
███╗░░░███╗░█████╗░██████╗░███████╗██████╗░░█████╗░███╗░░██╗
████╗░████║██╔══██╗██╔══██╗╚════██║██╔══██╗██╔══██╗████╗░██║
██╔████╔██║███████║██████╔╝░░███╔═╝██████╦╝███████║██╔██╗██║
██║╚██╔╝██║██╔══██║██╔══██╗██╔══╝░░██╔══██╗██╔══██║██║╚████║
██║░╚═╝░██║██║░░██║██║░░██║███████╗██████╦╝██║░░██║██║░╚███║
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝╚═╝░░╚══╝

██████╗░███████╗██████╗░░█████╗░░█████╗░████████╗███████╗██████╗░
██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
██████╔╝█████╗░░██████╦╝██║░░██║██║░░██║░░░██║░░░█████╗░░██████╔╝
██╔══██╗██╔══╝░░██╔══██╗██║░░██║██║░░██║░░░██║░░░██╔══╝░░██╔══██╗
██║░░██║███████╗██████╦╝╚█████╔╝╚█████╔╝░░░██║░░░███████╗██║░░██║
╚═╝░░╚═╝╚══════╝╚═════╝░░╚════╝░░╚════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝"
echo ""
echo "***** https://github.com/nsa14/script-reboot-marzban-automatically *****"
echo "***** write by Naser.Zare *****"
echo

install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}query is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

install_jq

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Fetch server country using ip-api.com
SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')

# Fetch server isp using ip-api.com 
SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')

# Function to display server location and IP
display_server_info() {
    echo -e "\e[93m═════════════════════════════════════════════\e[0m"  
    echo -e "${YELLOW}Server Country:${YELLOW} $SERVER_COUNTRY"
    echo -e "${YELLOW}Server IP:${YELLOW} $SERVER_IP"
}


function exit_badly {
echo "$1"
exit 1
}

error() {
    echo -e " \n $red Something Bad Happen $none \n "
}

if [ "$EUID" -ne 0 ]
then echo "Please run as root."
exit
fi


DISTRO="$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release|awk 'gsub(/[" ]/,x) + 1')"
DISTROVER="$(awk -F= '/^VERSION_ID/{print tolower($2)}' /etc/os-release|awk 'gsub(/[" ]/,x) + 1')"

valid_os()
{
    case "$DISTRO" in
    "debiangnu/linux"|"ubuntu")
        return 0;;
    *)
        echo "OS $DISTRO is not supported"
        return 1;;
    esac
}
if ! valid_os "$DISTRO"; then
    echo "Bye."
    exit 1
else
[[ $(id -u) -eq 0 ]] || exit_badly "Please re-run as root (e.g. sudo ./path/to/this/script)"
fi

update_os() {
apt-get -o Acquire::ForceIPv4=true update
apt-get -o Acquire::ForceIPv4=true install -y software-properties-common
add-apt-repository --yes universe
add-apt-repository --yes restricted
add-apt-repository --yes multiverse
apt-get -o Acquire::ForceIPv4=true install -y moreutils dnsutils tmux screen nano wget curl socat jq qrencode unzip lsof
}

export RED=$(tput setaf 1 :-"" 2>/dev/null)
export GREEN=$(tput setaf 2 :-"" 2>/dev/null)
export YELLOW=$(tput setaf 3 :-"" 2>/dev/null)
export BLUE=$(tput setaf 4 :-"" 2>/dev/null)
export RESET=$(tput sgr0 :-"" 2>/dev/null)

rtt_instller() {
    echo " 🆂🆃🅰🆁🆃 installer "
    sleep 1
    wget  "https://raw.githubusercontent.com/nsa14/script-marzban-node/master/install.sh" -O install.sh && chmod +x install.sh && bash install.sh 
    exit 1;
}

update_upgrade_server() {
    echo "
▄█
░█ 🆂🆃🅰🆁🆃 checked update and upgrade OS"
        echo "  "

	    # updates=$(/usr/lib/update-notifier/apt-check |& cut -d";" -f 1)
	    if [ $(/usr/lib/update-notifier/apt-check |& cut -d";" -f 1) -gt 0 ]; then
		    # Some commands
	        echo "updates available..."
	       	apt-get update; apt-get upgrade -y; apt-get install curl socat git -y; apt-get install curl socat git -y & spinner3

	       	read -p "needed to reboot server. are you ok? (Y/n): $q? " -r consent_reboot
		    case $consent_reboot in
		        [Yy]*) reboot;;
				*) 
				echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
				check_docker 
				;;
		    esac

   #      	read -rp "needed to reboot server. are you ok? (Y/n): " consent_reboot
	  #       case "$consent_reboot" in
		 #    [Yy]* ) 
		 #        reboot
		 #        ;;
		 #    * ) 
			# 	exit 1
		 #        ;;
			# esac
		            # exit 0
		else
			echo "no updates! is 🅾🅺  👍"
			echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
			check_docker
		            # exit 0
		fi

        # if (( updates == 0 )); then
        # 	echo "no updates!"
        #     exit 0
        #     echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
        #     # check_docker
        #     else
        #     echo "updates available"
        #     exit 0
        #     apt-get update; apt-get upgrade -y; apt-get install curl socat git -y; apt-get install curl socat git -y & spinner3
        #     # reboot
        # fi

}

check_docker(){
    echo "

▀█
█▄ 🆂🆃🅰🆁🆃 checked docker"
    echo "  "
    if ! command -v docker &> /dev/null
	then
	    install_docker
	    else
	    echo " docker is 🅾🅺 " & spinner3
        echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
	fi
    # if [[ $(docker -v) == *" 26.1."* ]]; then
    #     echo "docker is OK" & spinner3
    #     echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    # else 
    #     install_docker
    # fi
}

install_docker(){
	echo "  "
    echo "  🆂🆃🅰🆁🆃 install docker "
    echo "  "
    echo " please do not reboot or close. please wait ..."
    sudo echo nameserver 8.8.8.8 > /etc/resolv.conf
    # curl -fsSL https://get.docker.com | sh & spinner3 || { echo "Something went wrong! did you interupt the docker update? then no problem - Are you trying to install Docker on an IR server? try setting DNS."; }
    var_install_docker=$(curl -fsSL https://get.docker.com | sh) & spinner3

    if echo $var_install_docker | grep -q "Syntax OK"; then
        echo " 🅳🅾🅲🅺🅴🆁 🅸🆂 🅾🅺"
        echo ""
    else
        echo "【﻿ｅｒｒｏｒ】 Install docker. i can't continue 😕"
        echo $RED; "please you fixed error. Are you trying to install Docker on an IRAN server? try setting DNS." 
        echo $RESET
        echo ""
	        read -rp "Do you want to try again? (Y/n): " consent
	        case "$consent" in
		    [Yy]* ) 
		        echo "Proceeding run again the script... 👍"
		        rtt_instller
		        ;;
		    [Nn]* ) 
		        echo "
█▄▄ █▄█
█▄█ ░█░ Script terminated by the user 👋"
echo""
echo""
echo""
		        exit 0
		        ;;
		    * ) 
		        echo "Invalid input. Script will exit."
		        exit 1
		        ;;
			esac

        
    fi
    exit 1;
}

initial_node(){
    echo "

█▀▀█ 
──▀▄ 
█▄▄█ 🆂🆃🅰🆁🆃 initial node"
    echo "   "
    # if  Marzban-node exist only remove docker
        # [ ! -d "/etc/" ] && echo "Not Found" || echo "Found."
        if [ ! -d /root/Marzban-node ]; then
            # echo "niiiiiistt mazrban-node"
            git clone https://github.com/Gozargah/Marzban-node
            mkdir /var/lib/marzban-node
            # mkdir /root/Marzban-node
            # rm docker-compose.yml
        else 
             if [ -d /root/Marzban-node/docker-compose.yml ]; then 
                rm /root/Marzban-node/docker-compose.yml
            else
                touch /root/Marzban-node/docker-compose.yml
             fi
        fi

        echo "initial is 🅾🅺 "
        echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET

}

make_docker_compose(){
    echo " 

█░█
▀▀█ 🆂🆃🅰🆁🆃 docker compose generate "
    # $ printf "This overwrites your file" > /Marzban-node/docker-compose.yml
# echo -e "line1\nline2" > /root/Marzban-node/docker-compose.yml
echo -e "services:
  marzban-node:
    # build: .
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host

    environment:
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"

    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node" > /root/Marzban-node/docker-compose.yml
      echo ""
      echo "docker compose is 🅾🅺 "
      echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET

}

get_client_ssl_user(){
    echo "

█▀
▄█  🆂🆃🅰🆁🆃 get certificate from user"

    echo ""
    # echo " please paste certificate code from marzban panel: "
    # read certificate_code
    # read -p "please paste certificate code from marzban panel: " certificate_code
    read -rp 'please paste certificate code from marzban panel(CTRL + C) AND after press CTRL + D:' -d $'\04' certificate_code
    # declare -p certificate_code 
    # sed '{/pattern/|/regexp/|n}{i|a|c}<$certificate_code>' certificate_code



    if [[ -n "$certificate_code" ]]; then
        # echo "Variable is not empty\n "
        # echo "$certificate_code"
        set_client_cert
    else
        echo $YELLOW error: please paste certificate code from panel marzban here $RESET
        echo ""
        get_client_ssl_user  
    fi
    # echo "The Current User Name is\n $certificate_code"
}
get_client_ssl_user2(){
        echo "

█▀
▄█  🆂🆃🅰🆁🆃 get certificate from user"

    echo ""
    echo "Please paste the content of the Client Certificate, press ENTER on a new line when finished:"
    echo ""

    certificate_code=""
    while IFS= read -r line
    do
        if [[ -z $line ]]; then
            break
        fi
        certificate_code+="$line\n"
    done
    set_client_cert
    # echo -e "$certificate_code" | sudo tee /var/lib/marzban-node/$panel.pem > /dev/null

}

set_client_cert(){
    echo ""
    # echo "$certificate_code" 
    echo -e "$certificate_code" > /var/lib/marzban-node/ssl_client_cert.pem

    echo " client cert set is 🅾🅺 "
    echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    # sleep 1;
    composer_compile & spinner3
}

composer_compile(){
    echo "

█▄▄
█▄█ 🆂🆃🅰🆁🆃 compile docker compose "
    echo ""
    echo "start docker compose container. please wait..."

    sleep 1
    sudo systemctl restart docker
    sleep 1
    sleep 1
    cd /root/Marzban-node/
    docker compose up -d & spinner3
    echo ""
    echo "docker compile is 🅾🅺 "
    echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    # printf %"$COLUMNS"s |tr " " "-"

}

initial_cron(){
    echo $YELLOW;
    echo "s͟t͟e͟p͟ ͟1, please wait ..."
    echo $RESET
    echo ""
    sleep 1
    sudo apt install cron
    echo "initial is ok "
    echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    make_cron
    #sudo systemctl enable cron
}

make_cron(){
    echo $YELLOW;
    echo "s͟t͟e͟p͟ 2, please wait ..."
    echo $RESET
    echo ""
    sleep 1
    if [ ! -d /root/marzban-cron ]; then
            mkdir /root/marzban-cron
    fi

    echo -e "" > /root/marzban-cron/output-cron.txt
    echo -e "marzban restart
    (date +%F-%T) >> /root/marzban-cron/output-cron.txt" > /root/marzban-cron/reboot-cron.sh
    chmod +x /root/marzban-cron/reboot-cron.sh
    echo "is ok "
    echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    add_cron
}

add_cron(){
      echo $YELLOW;
      echo "s͟t͟e͟p͟ 3 enter hover "
      echo $RESET
    echo $YELLOW;
        hover_time=1
        sed -i '/marzban-cron/d' /var/spool/cron/crontabs/root
        while true; do
          #read -r "Enter the hover time for reset Marzban services (default=1): " hover_time
          #hover_time=${hover_time:-1}
          print_info "Enter the hover time for reset Marzban services (default 1): "
         read -r hover_time
        hover_time=${hover_time:-1}
#            echo "number is: $hover_time"
          re='^[0-9]+$'
if ! [[ $hover_time =~ $re ]] ; then
            print_error "Invalid input. Please enter valid hover numbers between 1 and 12."
          else
            #if test hover_time -eq 0
            if [ "$hover_time" -eq "0" ];
            then
                sed -i '/marzban-cron/d' /var/spool/cron/crontabs/root
                sudo service cron restart
                print_info "clear marzban rebooter. exited, ByBy"
                exit 1
            else
#              (crontab -l 2>/dev/null; echo "*/$hover_time * * * * cd /root/marzban-cron/;sh reboot-cron.sh") | crontab -
              (crontab -l 2>/dev/null; echo "0 */$hover_time * * * cd /root/marzban-cron/;sh reboot-cron.sh") |
              crontab -
                  echo " is ok "
                  echo $GREEN; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
                  enable_cron
#                break
            fi
          fi
        done
    echo $RESET
}

enable_cron(){
    echo $YELLOW;
    echo "s͟t͟e͟p͟ 4, please wait ..."
    echo $RESET
    echo ""
    sudo systemctl enable cron
#    sudo systemctl start cron
    sudo service cron restart 
    #grep CRON /var/log/syslog
    #systemctl status cron
    # pgrep cron  -- show error line cron
#    crontab -l | grep 'word'
#    /var/spool/cron/crontabs
    #sed -i '/marzban-cron/d' /var/spool/cron/crontabs/root
    echo "enable is ok "
    echo $YELLOW; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    finished_command

}

print_info() {
  echo -e "${BLUE}$1${RESET}"
}
print_error() {
  echo -e "${RED}$1${RESET}"
}

show_spinner(){
for i in {001..100}; do
    sleep 1
    printf "\r $i"
done
}

finished_command(){
  echo ""
  echo ""
  echo "🄵🄸🄽🄸🅂🄷🄴🄳! cron job is created and active for restarted marzban services.";
  echo ""
  echo ""
  exit 1
}

clear_rebooter(){
    sed -i '/marzban-cron/d' /var/spool/cron/crontabs/root
        sudo service cron restart
        echo "clear marzban rebooter it was successfully"
    }
    
show_status(){
    echo "status :"
    
if [ $(grep 'marzban-cron'  /var/spool/cron/crontabs/root | wc -l) -eq 1 ];
    then
       echo $GREEN;echo "✅ACTIVE";echo $RESET
    else
       echo $RED;echo "❌NOT active";echo $RESET
fi
echo ""
    }

    show_last_running(){
      echo "last date running  :"
      file_name=/root/marzban-cron/output-cron.txt

      if [ -z "$(cat ${file_name})" ]; then
        echo "not log detecting in script"
        exit 1
      else
        echo -e "\t"; tail -1 /root/marzban-cron/output-cron.txt
        exit 1
      fi
      echo ""
    }

show_spinner2(){
/usr/bin/scp me@website.com:file somewhere 2>/dev/null &
pid=$! # Process Id of the previous running command

spin='-\|/'

i=0
while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"
  sleep .1
done
}
spinner3()
{
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

progreSh() {
    LR='\033[1;31m'
    LG='\033[1;32m'
    LY='\033[1;33m'
    LC='\033[1;36m'
    LW='\033[1;37m'
    NC='\033[0m'
    if [ "${1}" = "0" ]; then TME=$(date +"%s"); fi
    SEC=`printf "%04d\n" $(($(date +"%s")-${TME}))`; SEC="$SEC sec"
    PRC=`printf "%.0f" ${1}`
    SHW=`printf "%3d\n" ${PRC}`
    LNE=`printf "%.0f" $((${PRC}/2))`
    LRR=`printf "%.0f" $((${PRC}/2-12))`; if [ ${LRR} -le 0 ]; then LRR=0; fi;
    LYY=`printf "%.0f" $((${PRC}/2-24))`; if [ ${LYY} -le 0 ]; then LYY=0; fi;
    LCC=`printf "%.0f" $((${PRC}/2-36))`; if [ ${LCC} -le 0 ]; then LCC=0; fi;
    LGG=`printf "%.0f" $((${PRC}/2-48))`; if [ ${LGG} -le 0 ]; then LGG=0; fi;
    LRR_=""
    LYY_=""
    LCC_=""
    LGG_=""
    for ((i=1;i<=13;i++))
    do
        DOTS=""; for ((ii=${i};ii<13;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LRR_="${LRR_}#"; else LRR_="${LRR_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${DOTS}${LY}............${LC}............${LG}............ ${SHW}%${NC}\r"
        if [ ${LNE} -ge 1 ]; then sleep .05; fi
    done
    for ((i=14;i<=25;i++))
    do
        DOTS=""; for ((ii=${i};ii<25;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LYY_="${LYY_}#"; else LYY_="${LYY_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${DOTS}${LC}............${LG}............ ${SHW}%${NC}\r"
        if [ ${LNE} -ge 14 ]; then sleep .05; fi
    done
    for ((i=26;i<=37;i++))
    do
        DOTS=""; for ((ii=${i};ii<37;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LCC_="${LCC_}#"; else LCC_="${LCC_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${LC}${LCC_}${DOTS}${LG}............ ${SHW}%${NC}\r"
        if [ ${LNE} -ge 26 ]; then sleep .05; fi
    done
    for ((i=38;i<=49;i++))
    do
        DOTS=""; for ((ii=${i};ii<49;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LGG_="${LGG_}#"; else LGG_="${LGG_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${LC}${LCC_}${LG}${LGG_}${DOTS} ${SHW}%${NC}\r"
        if [ ${LNE} -ge 38 ]; then sleep .05; fi
    done
}

valid_os
display_server_info
echo ""
show_status

echo Enter choice :
echo -e "\t 1 : To create marzban restarter service"
echo -e "\t 2 : To delete script"
echo -e "\t 3 : To show last date running script"
echo -e "\t 4 : To exit"

read -r choice
case $choice in
    1)
        initial_cron
        ;;
    2) 
        clear_rebooter
        ;;
    3)
        show_last_running
        ;;
    4)
        echo "exit by user. ByBy"
        exit 1
        ;;
    *) echo Please! Enter correct choice.
 
esac

#initial_cron

#update_upgrade_server
# check_docker
# install_docker
#initial_node
#make_docker_compose 
#get_client_ssl_user2
# set_client_cert
# rtt_instller


# exit ;;