#!/bin/bash

##########################
## SET USER TO `whoami` ##
##########################

USER="$1"

##########################

if [[ $EUID -ne 0 ]]; then
   echo -e "[!]Error: This script must be run as root.\n"
   echo -e "Usage:\n\tsudo $0 USER" 
   exit 1
fi

if [ ! -n "$USER" ]; then
	echo "[!]Error: User not defined. Please set the user variable to the desired low-privilege user account (i.e. your regular username)."
	exit 1
fi

VALID_USER=""
for l in $(ls /home); do if [ "$l" = "$1" ]; then VALID_USER="$1"; fi; done
if [ ! -n "$VALID_USER" ]; then
	echo -e "[!]Error: \`$USER\` is not a valid user, please select from:\n $(ls /home)"
	exit 1
fi



if [ ! "$(cat /etc/apt/sources.list | grep '# deb-src')" = "# deb-src http://archive.canonical.com/ubuntu focal partner" ]; then
	echo -e "[!]Error: sslscan requires access to build-dep sources.\nUncomment 'deb-src' entries in /etc/apt/sources.list"
	exit 1
fi

apt update && apt upgrade -y

# install the basics
apt install -y vim net-tools zsh mlocate tmux screen terminator python2 git nmap socat build-essential manpages-dev gcc g++ libc6-i386

# install zsh add-ons
apt install -y zsh-syntax-highlighting zsh-autosuggestions

# install 7zip and rar extractors
apt install -y p7zip-full unrar

# install openjdk jre 11
apt install openjdk-11-jdk

# install GIMP for image editing
apt install -y gimp

# install Sublime Text Editor
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
apt install -y apt-transport-https

echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list

apt update
apt install -y sublime-text

# python2
if [ ! -n "$(which pip)" ]; then
	cd "/tmp"
	wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
	python2 get-pip.py
	rm get-pip.py
fi

# python3 pip
if [ ! -n "$(which pip3)" ]; then
	apt install -y python3-pip
fi


# Wireshark
apt install -y wireshark tshark tcpreplay tcpdump

# install masscan and dns tools
apt install -y masscan dnsmap dnsenum

if [ -x "/opt/dnscat2" ]; then
	cd "/opt/dnscat2"
	echo "Pulling $(pwd)..." && git pull
else
	git clone https://github.com/iagox86/dnscat2.git "/opt/dnscat2"
	cd "/opt/dnscat2/client/"
	echo "Making dnscat2... [check log at /home/$USER/dnscat2_make.log]"
	make > "/home/$USER/dnscat2_make.log"
	ln -s  /opt/dnscat2/client/dnscat /usr/local/bin/dnscat
fi


# john the ripper
if [ -x "/usr/share/john" ]; then
	cd "/usr/share/john"
	echo "Pulling $(pwd)..." && git pull
else
	cd "/usr/share"
	apt install -y libbz2-dev
	git clone https://github.com/openwall/john.git
	cd "/usr/share/john/src"
	./configure && make -s clean && make -sj4
	for d in /home/*/; do 
		echo 'alias john="/usr/share/john/run/john"' >> "$d".bashrc
		echo 'alias john="/usr/share/john/run/john"' >> "$d".zshrc
	done
	alias john="/usr/share/john/run/john"
	john
fi


# powershell
if [ ! -n "$(which powershell)" ]; then
	# Install pre-requisite packages.
	sudo apt-get install -y wget apt-transport-https software-properties-common
	# Download the Microsoft repository GPG keys
	wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
	# Register the Microsoft repository GPG keys
	sudo dpkg -i packages-microsoft-prod.deb
	# Update the list of packages after we added packages.microsoft.com
	sudo apt-get update
	# Install PowerShell
	sudo apt-get install -y powershell
fi
pwsh --version

# clone nishang
if [ ! -x "/opt/nishang" ]; then
	git clone https://github.com/samratashok/nishang.git "/opt/nishang"
else
	cd "/opt/nishang"
	echo "Pulling $(pwd)..." && git pull
fi
	
# metasploit
apt install -y libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev git-core autoconf postgresql pgadmin3 curl libxml2-dev libxslt1-dev libyaml-dev curl zlib1g-dev gawk bison libffi-dev libgdbm-dev libncurses5-dev libtool sqlite3 libgmp-dev gnupg2 dirmngr ruby ruby-dev ruby-full


if [ ! -x "/opt/metasploit-framework" ]; then
	git clone https://github.com/rapid7/metasploit-framework.git "/opt/metasploit-framework"
	cd "/opt/metasploit-framework"
	gem install bundler
	bundle install
else
	cd "/opt/metasploit-framework"
	echo "Pulling $(pwd)..." && git pull
fi


# install powershell empire
if [ -x "/opt/Empire" ]; then
	cd "/opt/Empire"
	echo "Pulling $(pwd)..." && git pull
else
	sudo -u $USER pip3 install poetry
	git clone --recursive https://github.com/BC-SECURITY/Empire.git "/opt/Empire"
	cd "/opt/Empire"
	./setup/install.sh
	poetry install
fi

# install snmpenum
if [ -x "/opt/exploit-database" ]; then
	cd "/opt/exploit-database"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/exploit-database"
	git clone https://gitlab.com/kalilinux/packages/snmpenum.git "/opt/exploit-database"
fi

# install snmp-user-enum
wget -qO /tmp/smtp-user-enum-1.2.tar.gz http://pentestmonkey.net/tools/smtp-user-enum/smtp-user-enum-1.2.tar.gz

if [ -x "/opt/snmpenum" ]; then
	cd "/opt/snmpenum"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/snmpenum"
	git clone https://gitlab.com/kalilinux/packages/snmpenum.git "/opt/snmpenum"
fi

# install smbmap
if [ -x "/opt/smbmap" ]; then
	cd "/opt/smbmap"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/smbmap"
	git clone https://github.com/ShawnDEvans/smbmap.git "/opt/smbmap"
fi


# install exploit-db
if [ -x "/opt/exploit-database" ]; then
	cd "/opt/exploit-database"
	echo "Pulling $(pwd)..." && git pull
else
	git clone https://github.com/offensive-security/exploitdb.git "/opt/exploit-database"
	ln -sf /opt/exploit-database/searchsploit /usr/local/bin/searchsploit	
	cp -n /opt/exploit-database/.searchsploit_rc /home/$USER/
	for d in /home/*/; do cp -n /opt/exploit-database/.searchsploit_rc "$d"; done
fi

# seclists and kali wordlists
if [ ! -x "/usr/share/wordlists" ]; then
	mkdir "/usr/share/wordlists"
fi
cd "/usr/share/wordlists"

if [ ! -x "/usr/share/wordlists/SecLists" ]; then
	git clone https://github.com/danielmiessler/SecLists.git "/usr/share/wordlists/SecLists"
else
	cd "/usr/share/wordlists/SecLists"
	echo "Pulling $(pwd)..." && git pull
fi

if [ ! -x "/usr/share/wordlists/KaliLists" ]; then
	git clone https://github.com/3ndG4me/KaliLists.git "/usr/share/wordlists/KaliLists"
else
	cd "/usr/share/wordlists/KaliLists"
	echo "Pulling $(pwd)..." && git pull
fi


# install wordlist raider
if [ ! -x "/opt/WordlistRaider" ]; then
	git clone https://github.com/GregorBiswanger/WordlistRaider.git "/opt/WordlistRaider"
	cd "/opt/WordlistRaider"
	sudo -u $USER python3 -m pip install -r requirements.txt
	python3 setup.py build
	python3 setup.py install
else
	cd "/opt/WordlistRaider"
	echo "Pulling $(pwd)..." && git pull
fi

# install PayloadsAllTheThings
if [ ! -x "/opt/PayloadsAllTheThings" ]; then
	git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "/opt/PayloadsAllTheThings"
else
	cd "/opt/PayloadsAllTheThings"
	echo "Pulling $(pwd)..." && git pull
fi

# install patator
apt install -y patator

# install nikto
apt install -y nikto


#install netsed, ngrep and ripgrep
apt install -y netsed ngrep

# install nfs-utils
apt install -y libnfs-utils nfs-common

#install net-snmp
if [ ! -x "/opt/net-snmp" ]; then
	mkdir "/opt/net-snmp"
	echo "downloading net-snmp..."
	wget -O "/opt/net-snmp/net-snmp-5.9.1.tar.gz" http://sourceforge.net/projects/net-snmp/files/net-snmp/5.9.1/net-snmp-5.9.1.tar.gz
	cd "/opt/net-snmp"
	tar -xvzf "/opt/net-snmp/net-snmp-5.9.1.tar.gz"
	rm "/opt/net-snmp/net-snmp-5.9.1.tar.gz"
	cd "net-snmp-5.9.1"
	apt install -y libperl-dev
	./configure --with-default-snmp-version="3" --with-sys-contact="@@no.where" --with-sys-location="Unknown" 
--with-logfile="/var/log/snmpd.log" --with-persistent-directory="/var/net-snmp"
	echo "Making net-snmp... [check log at /home/$USER/net-snmp_make.log]"
	make > /home/$USER/net-snmp_make.log
	make install > "/home/$USER/net-snmp_make.log"

	for d in /home/*/; do 
		echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> "$d".bashrc
		echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> "$d".zshrc
	done
	export LD_LIBRARY_PATH=/usr/local/lib 
	snmpget --version

	cd "perl"
	echo "Making net-snmp Perl tools... [check log at /home/$USER/net-snmp_perl_make.log]"
	perl Makefile.PL > "/home/$USER/net-snmp_perl_make.log"
	make > "/home/$USER/net-snmp_perl_make.log"
	make install > "/home/$USER/net-snmp_perl_make.log"

else
	snmpget --version
fi

cd "/"

# install pwntools
sudo -u $USER pip3 install pwntools

# install forensics packages
apt install -y forensics-all python3-binwalk python3-scapy scalpel samdump2 safecopy

# install reverse engineering tools
apt install -y radare2 radare2-cutter

# install windows pentest tools
# evil-winrm
gem install evil-winrm
apt install -y nbtscan 


# install other tools
apt install -y nasm hexedit ncurses-hexedit 
apt install -y hydra 

snap install amass

# install proxychains and proxytunnel
apt install -y proxychains-ng proxytunnel

# install PHP
apt install -y php libapache2-mod-php libphp-embed php-all-dev php-bcmath php-bz2 php-cgi php-cli php-common php-curl php-dev php-enchant php-fpm php-gd php-gmp php-imap php-interbase php-intl php-json php-ldap php-mbstring php-mysql php-odbc php-pgsql php-phpdbg php-pspell php-readline php-snmp php-soap php-sqlite3 php-sybase php-tidy php-xml php-xmlrpc php-zip

# install web tools
apt install -y whois traceroute fping hping3 

# install SQLmap
apt install -y sqlmap
if [ -x "/opt/sqlmap-dev" ]; then
	cd "/opt/sqlmap-dev"
	echo "Pulling $(pwd)..." && git pull
else
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git "/opt/sqlmap-dev"
fi

apt install -y sqlitebrowser

# install theHarvester
if [ -x "/opt/theHarvester" ]; then
	cd "/opt/theHarvester"
	echo "Pulling $(pwd)..." && git pull
else
	git clone https://github.com/laramies/theHarvester "/opt/theHarvester"
	cd "/opt/theHarvester"
	sudo -u $USER python3 -m pip install -r requirements/base.txt
	python3 setup.py build
	python3 setup.py install

fi

# install responder
if [ -x "/opt/Responder" ]; then
	cd "/opt/Responder"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/Responder"
	git clone https://github.com/lgandx/Responder.git "/opt/Responder"
fi

# install impacket
if [ -x "/opt/impacket" ]; then
	cd "/opt/impacket"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/impacket"
	git clone https://github.com/SecureAuthCorp/impacket.git "/opt/impacket"
	cd "/opt/impacket"
	sudo -u $USER python3 -m pip install -r requirements.txt
	python3 setup.py build
	python3 setup.py install
fi

# install polenum
if [ -x "/opt/polenum" ]; then
	cd "/opt/polenum"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/polenum"
	git clone https://github.com/Wh1t3Fox/polenum.git "/opt/polenum"
fi

# install Sublist3r
if [ -x "/opt/Sublist3r" ]; then
	cd "/opt/Sublist3r"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/Sublist3r"
	git clone https://github.com/aboul3la/Sublist3r.git "/opt/Sublist3r"
	cd "/opt/Sublist3r"
	sudo -u $USER pip install -r requirements.txt
	sudo -u $USER pip3 install -r requirements.txt
	python2 setup.py build
	python2 setup.py install
	python3 setup.py build
	python3 setup.py install
fi


# install ssl tools
sudo -u $USER pip3 install --upgrade setuptools pip
sudo -u $USER pip3 install --upgrade sslyze
apt install  -y sslsplit sslsniff ssldump
if [ ! -x "/opt/sslscan/sslscan" ]; then
	mkdir "/opt/sslscan"
	git clone https://github.com/rbsec/sslscan.git "/opt/sslscan"
	apt install -y build-essential git zlib1g-dev
	apt build-dep openssl
	cd "/opt/sslscan"
	echo "Making sslscan... [check log at /home/$USER/sslscan_make.log]"
	make static 2>&1 /home/$USER/sslscan_make.log
	ln -s /opt/sslscan/sslscan /usr/local/bin/sslscan
fi

# install Perl libs
apt install -y libwww-perl libdbd-sqlite3-perl libhtml-linkextractor-perl libterm-readline-gnu-perl liblwp-protocol-socks-perl sqlite3 libswitch-perl

# install go-lang
if [ ! -x "/usr/local/go" ]; then
	cd "/usr/local"
	mkdir -p "/usr/local/go"
	echo "downloading go..."
	wget -qO /usr/local/go1.17.2.linux-amd64.tar.gz https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
	tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz

	for d in /home/*/; do 
		echo 'export PATH=$PATH:/usr/local/go/bin' >> "$d".bashrc
		echo 'export PATH=$PATH:/usr/local/go/bin' >> "$d".zshrc
	done
	export PATH=$PATH:/usr/local/go/bin
	ln -s /usr/local/go/bin/go /bin/go
fi

go version

# install dirbuster and gobuster
apt install gobuster

if [ -x "/opt/dirbuster" ]; then
	cd "/opt/dirbuster"
	echo "Pulling $(pwd)..." && git pull
else
	mkdir "/opt/dirbuster"
	git clone https://gitlab.com/kalilinux/packages/dirbuster.git "/opt/dirbuster"
	cd "/opt/dirbuster"
	alias dirbuster="/opt/dirbuster/DirBuster-1.0-RC1.sh"
	for d in /home/*/; do 
		echo 'alias dirbuster="java -Xmx256M -jar /opt/dirbuster/DirBuster-1.0-RC1.jar"' >> "$d".bashrc
		echo 'alias dirbuster="java -Xmx256M -jar /opt/dirbuster/DirBuster-1.0-RC1.jar"' >> "$d".zshrc
	done
fi

# install qemu and associated packages
apt install -y qemu qemu-block-extra qemu-guest-agent qemu-system qemu-user-binfmt qemu-utils 

echo -e "\nPlease source /home/$USER/.zshrc or /home/$USER/.bashrc (depending on your shell)."