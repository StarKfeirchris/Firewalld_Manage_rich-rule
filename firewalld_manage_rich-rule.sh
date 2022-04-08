#/bin/bash

# Setting the execution environment, always open.
set -e

# Definition color; E = Color end
R="\e[1;91m"
G="\e[1;92m"
Y="\e[1;93m"
B="\e[1;96m"
E="\e[0m"

# Select feature
read -p "
$(echo -e "${Y}1${E} > ${G}Replace rules${E}")
$(echo -e "${Y}2${E} > ${R}Add ${E}${G}rules${E}")
$(echo -e "${Y}3${E} > ${R}Remove ${E}${G}rules${E}")
$(echo -e "${Y}Q/q${E} > ${G}Quit${E}")
$(echo -e "${B}What do you want to do this time?(Enter number) >${E}") " feature_choose
echo

# function
add_rule() {
	firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${addip}" service name="ssh" accept"
	firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${addip}" service name="transmission-client" accept"
	firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${addip}" port port="12345" protocol="tcp" accept"
}

rm_rule() {
	firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="${rmip}" service name="ssh" accept"
	firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="${rmip}" service name="transmission-client" accept"
	firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="${rmip}" port port="12345" protocol="tcp" accept"
}

# For quit feature.
if [[ ${feature_choose} == Q || ${feature_choose} == q ]];
then
	exit 0
fi

case ${feature_choose} in
	1 )
		read -p "$(echo -e "Enter ${Y}old${E} rules IP: ")" rmip
		read -p "$(echo -e "Enter ${Y}new${E} rules IP: ")" addip
		
		add_rule
		rm_rule
		;;

	2 )
		read -p "$(echo -e "Enter the IP to be ${G}added${E} rules: ")" addip
		
		add_rule
		;;

	3 )
		read -p "$(echo -e "Enter the IP to be ${R}remove${E} rules: ")" rmip
		
		rm_rule
		;;
esac

echo
echo -e "${Y}Preview${E} ${B}the rules that will be applied:${E}"
firewall-cmd --list-all --permanent | grep -A100 "rich rules:"
echo

while read -p "$(echo -e "${B}Do you want to reload firewalld? (Y/N)${E}") " fwreload
do
	if [[ ${fwreload} == y || ${fwreload} == Y ]];
	then
		firewall-cmd --reload

		echo
		echo -e "${G}Rules have been applied:${E}"
		firewall-cmd --list-all
		exit 0
	elif [[ ${fwreload} == n || ${fwreload} == N ]];
	then
		echo -e "${B}OK, it looks like you still have some concerns...${E}"
		break
	else
		echo -e "${Y}Please enter Y or N, or Ctrl + C exit.${E}"
	fi

	continue
done
