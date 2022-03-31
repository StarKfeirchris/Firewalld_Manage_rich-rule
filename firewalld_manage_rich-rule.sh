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
$(echo -e "${Y}1${E} > ${G}Replace rules.${E}")
$(echo -e "${Y}2${E} > ${R}Add ${E}${G}rules.${E}")
$(echo -e "${Y}3${E} > ${R}Remove ${E}${G}rules.${E}")
$(echo -e "${Y}Q/q${E} > ${G}Quit${E}")
$(echo -e "${B}What do you want to do this time?(Enter number) >${E}") " feature_choose
echo

addrich=$(echo 'firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="')
rmrich=$(echo 'firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="')
ssh2200=$(echo '" service name="ssh-2200" accept"')
bitwolf=$(echo '" service name="transmission-bitwolf" accept"')
webmin=$(echo '" port port="16868" protocol="tcp" accept"')

# For quit feature.
if [[ ${feature_choose} == Q || ${feature_choose} == q ]];
then
	exit 0
fi

case ${feature_choose} in
	1 )
		read -p "$(echo -e "Enter ${Y}old${E} rules IP: ")" oldip
		read -p "$(echo -e "Enter ${Y}new${E} rules IP: ")" newip
		${addrich}${newip}${ssh2200}
		${addrich}${newip}${bitwolf}
		${addrich}${newip}${webmin}
		${rmrich}${oldip}${ssh2200}
		${rmrich}${oldip}${bitwolf}
		${rmrich}${oldip}${webmin}
		;;

	2 )
		read -p "$(echo -e "Enter the IP to be ${G}added${E} rules: ")" addip
		${addrich}${addip}${ssh2200}
		${addrich}${addip}${bitwolf}
		${addrich}${addip}${webmin}
		;;

	3 )
		read -p "$(echo -e "Enter the IP to be ${R}remove${E} rules: ")" rmip
		${rmrich}${rmip}${ssh2200}
		${rmrich}${rmip}${bitwolf}
		${rmrich}${rmip}${webmin}
		;;
esac

firewall-cmd --list-all

while read -p "$(echo -e "${B}Do you want to reload firewalld? (Y/N)${E}") " fwreload
do
	if [[ ${fwreload} == y || ${fwreload} == Y ]];
	then
		firewall-cmd --reload
	elif [[ ${fwreload} == n || ${fwreload} == N ]];
	then
		echo -e "${B}OK, it looks like you still have some concerns...${E}"
		break
	else
		echo -e "${Y}Please enter Y or N, or Ctrl + C exit.${E}"
	fi

	continue
done
