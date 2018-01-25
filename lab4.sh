#------------------------------------------------------------------------------
# SOURCE FILE: 		lab4.sh
#
# PROGRAM:  		COMP7006 - Lab 4
#
#			function install()
#			function replaceLineNum()
#           		function createFolderHtml()
#           		function replaceLine()
#			function permissions()
#			function chOwner()
#			function apache()
#
# DATE:			Oct 17, 2017
#
# DESIGNER:		Benedict Lo & Aing Ragunathan
# Programmer:		Benedict Lo & Aing Ragunathan
#
# NOTES:		This script provides a automated method of installing and
#			configuring apache, nfs, and samba.
#			The script also provides the user with the ability to create
#			a new user on the machine.
#			A method of removing apache, nfs, and samba installations and
#			configurations are also provided by starting the program with
#			the -r argument.
#------------------------------------------------------------------------------
function install(){
	#---------------------------------------------------------------------------
	#
	#    FUNCTION:		replaceLineNum()
	#
	#    PARAMETERS   	$1 - file to modify
	#			$2 - line number to check
	#			$3 - string to find
	#			$4 - string to replace with
	#
	#    DESIGNER:		Benedict Lo & Aing Ragunathan
	#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#    DATE:		Oct 17, 2017
	#
	#    DESCRIPTION:	This method replaces an entire line using the line
	#			number
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
	function replaceLineNum() {
		sed -i "$2s/$3/$4/g" $1
	}

	#---------------------------------------------------------------------------
	#
	#    FUNCTION:    	createFolderHtml()
	#
	#    PARAMETERS   	none
	#
	#    DESIGNER:		Benedict Lo & Aing Ragunathan
	#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#    DATE:		Oct 17, 2017
	#
	#    DESCRIPTION:	Wrapper function for createing a file directory for
	#			public html files
	#
	#
	#    RETURNS:
	#          		void
	#
	#---------------------------------------------------------------------------
	function createFolderHtml() {
		echo "LOG:Removing /etc/samba/smb.conf"
		home="/home/$1"
		path="$home/public_html/"
		mkdir $path
		(cd $path && echo "Benedict & Aing" >> index.html)
	}

	#---------------------------------------------------------------------------
	#
	#    FUNCTION:    	replaceLine()
	#
	#    PARAMETERS   	$1 - file to modify
	#			$2 - string contained in line to search for
	#			$3 - string to replace line with
	#
	#    DESIGNER:		Benedict Lo & Aing Ragunathan
	#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#    DATE:		Oct 17, 2017
	#
	#    DESCRIPTION:	This finds a string in a file and replaces the entire
	#			line with a new string
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
	function replaceLine() {
	sed -i "/$2/c\ $3" $1
	}

	#---------------------------------------------------------------------------
	#
	#    FUNCTION:    	permissions()
	#
	#    PARAMETERS   	$1 - user to grant permission to
	#
	#    DESIGNER:		Benedict Lo & Aing Ragunathan
	#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#    DATE:		Oct 17, 2017
	#
	#    DESCRIPTION:	Wrapper function to change the permissions of a user
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
	function permissions() {
	  echo "Changing permissions"
	  chmod -R 755 $1
	}

	#---------------------------------------------------------------------------
	#
	#    FUNCTION:    	chOwner()
	#
	#    PARAMETERS   	$1 - user to grant permission to
	#
	#    DESIGNER:		Benedict Lo & Aing Ragunathan
	#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#    DATE:		Oct 17, 2017
	#
	#    DESCRIPTION:	Wrapper function to change the owner of a file
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
	function chOwner() {
		echo "Changing owner"
		chown $1 $2
	}

	#---------------------------------------------------------------------------
	#
	#    FUNCTION:    	apahce()
	#
	#    PARAMETERS   	$1 - user to grant permission to
	#
	#    DESIGNER:		Benedict Lo & Aing Ragunathan
	#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#    DATE:		Oct 17, 2017
	#
	#    DESCRIPTION:	Configures apache using user prompts
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
	function apache() {
		echo "LOG:Editing permissions of $1"
	  permissions "/home/$1"

	  #edit the userdir.conf file for external access
		echo "LOG:Editing userdir.conf"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 17 'UserDir disabled' 'UserDir public_html'

	  #create index.html file in /home/<username>/public_html and insert name of user
		echo "LOG:Adding public_html folder in $1"
	  createFolderHtml $1

	  #create /var/www/html/passwords
	  mkdir /var/www/html/passwords

	  #modify userdir.conf
		echo "LOG:Modifying userdir.conf"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 31 ^ "#"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 32 ^ "#"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 33 ^ "#"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 34 ^ "#"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 35 ^ "#"

	  #add user directory information to the userdir.conf file from the userdir_update file
	  newDirectory="<Directory /home/"$1">"
	  echo $newDirectory >> /etc/httpd/conf.d/userdir.conf
	  cat userdir_update >> /etc/httpd/conf.d/userdir.conf

	  #add the password folder
	  read -p 'Enter Apache password folder name: ' apachePass
	  #passFolder="AuthUserFile /var/www/html/passwords/"
	  #newPassFolder="AuthUserFile /var/www/html/passwords/"$apachePass
		echo "LOG:Adding password to the folder"
	  replaceLineNum /etc/httpd/conf.d/userdir.conf 40 $ $apachePass

	  #create password in /var/www/html/passwords
	  #htpasswd -c $apachePass $1
		echo "LOG:Creating password folder"
	  (cd /var/www/html/passwords && htpasswd -c $apachePass $1)

	  #start the apache service
		echo "LOG:Starting HTTPD"
	  systemctl start httpd

	  #restart the apache service
		echo "LOG:Restarting HTTPD"
	  systemctl restart httpd

	  #show the status of Apache
		echo "LOG:Checking HTTPD status"
	  systemctl status httpd
	}

	#-------------------------------------------------------------------------------
	#
	#	FUNCTION:	nfs()
	#
	#	PARAMETERS:	$1 - specifies the user to install with
	#
	#	DESIGNER:	Benedict Lo & Aing Ragunathan
	#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#	DATE:		Oct 14, 2017
	#
	#	DESCRIPTION:
	#			This function takes the previously prompted information and
	#			uses it to install NFS.
	#    	RETURNS:
	#                	void
	#
	#-------------------------------------------------------------------------------
	function nfs() {

		#---------------------------------------------------------------------------
		#
		#    FUNCTION:		createRndom()
		#
		#    PARAMETERS:	$1 - specifies the user to install with
		#
		#    DESIGNER:		Benedict Lo & Aing Ragunathan
		#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
		#
		#    DATE:		Oct 14, 2017
		#
		#    DESCRIPTION:	This function creates a file for testing at the
		#			designated user's folder
		#    RETURNS:
		#                	void
		#
		#---------------------------------------------------------------------------
		function createRndm() {
			#create file in user folder
			home="/home/$1/"
			file="test.txt"
			(cd $home && echo "Benedict & Aing" >> $file)
		}

		#---------------------------------------------------------------------------
		#
		#    FUNCTION:		editExport()
		#
		#    PARAMETERS		$1 - specifies the locaiton of the config file
		#
		#    DESIGNER:		Benedict Lo & Aing Ragunathan
		#    PROGRAMMER:	Benedict Lo & Aing Ragunathan
		#
		#    DATE:		Oct 14, 2017
		#
		#    DESCRIPTION:	This function takes the location of the config file and
		#			configures the exports file to connect to a client
		#    RETURNS:
		#                	void
		#
		#---------------------------------------------------------------------------
		function editExport() {
			read -p 'Please enter your client ip: ' ip
			echo "/home/$1 $ip/255.255.255.0(rw,no_root_squash)" >> /etc/exports
		}

		#creates a file for testing
		echo "LOG:Creating test file in $1"
		createRndm $1

		#change permissions of file
		echo "LOG:Adding permissions to test.txt"
		permissions "/home/$1/test.txt"

		#change ownder of file and directory
		#paramter 1 = user
		#paramter 2 = file name
		echo "LOG:Changing owners of test.txt"
		chOwner $1 "/home/$1/test.txt"
		chOwner $1 "/home/$1/"

		#installs nfs
		#systemctl install nfs-utils

		#edits the export file
		echo "LOG:editing exports"
		editExport $1

		#enables NFS service
		echo "LOG:Enable nfs-server.service"
		systemctl enable nfs-server.service

		#start nfs
		echo "LOG:Starting NFS"
		systemctl start nfs

		#makes exportfs available
		echo "LOG:Make exports available"
		/usr/sbin/exportfs -v

		#restart nfs
		echo "LOG:Restarting NFS"
		systemctl stop nfs
		systemctl start nfs

		#system status
		echo "LOG:Check status of NFS"
		systemctl status nfs

	}

	#-----------------------------------------------------------------------------
	#
	#	FUNCTION:	samba()
	#
	#	PARAMETERS	$1 - specifies the user to install with
	#
	#	DESIGNER:	Benedict Lo & Aing Ragunathan
	#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#	DATE:		Oct 14, 2017
	#
	#	DESCRIPTION:	This function takes the previously prompted information and
	#			uses it to install NFS.
	#
	#	RETURNS:
	#			void
	#
	#-----------------------------------------------------------------------------
	function samba() {

		#---------------------------------------------------------------------------
		#
		#	FUNCTION:	editConf()
		#
		#	PARAMETERS	$1 - specifies the locaiton of the config file
		#
		#	DESIGNER:	Benedict Lo & Aing Ragunathan
		#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
		#
		#	DATE:		Oct 14, 2017
		#
		#	DESCRIPTION:	This function takes the location of the config file and
		#			configures the smb.conf file to connect to a lab machine
		#
		#	RETURNS:
		#	                void
		#
		#---------------------------------------------------------------------------
		function editConf() {
			replaceLine $1 "workgroup = SAMBA" "  workgroup = CST323\n\n   server string = Samba Server"
			replaceLine $1 "passdb backend" "#passdb backend"
			replaceLine $1 "printing = cups" "#printing = cups"
			replaceLine $1 "printcap name = cups" "#printcap name = cups"
			replaceLine $1 "load printers = yes" "#load printers = yes"
			replaceLine $1 "cups options = raw" "#cups options = raw"

			echo " " >> $1
			echo "[NFSHARE]" >> $1
			echo "  comment = Win32 Share" >> $1
			#change to user
			path=" path = /home/$2"
			echo "  $path" >> $1
			echo "  public = yes" >> $1
			echo "  writable = yes" >> $1
			echo "  printable = no" >> $1
		}

		#---------------------------------------------------------------------------
		#
		#	FUNCTION:	addUser()
		#
		#	PARAMETERS	$1 - specifies the user to install with
		#
		#	DESIGNER:	Benedict Lo & Aing Ragunathan
		#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
		#
		#	DATE:		Oct 14, 2017
		#
		#	DESCRIPTION: 	This function takes the user name and adds the password to
		#			samba.
		#	RETURNS:
		#                	void
		#
		#---------------------------------------------------------------------------
		function addUser() {
			smbpasswd -a $1
		}

		#install samba
		#systemctl install samba

		#enable samba service
		echo "LOG:Enable smb.service"
		systemctl enable smb.service

		#first paramater is the file name
		#second paramater is the name of the user
		echo "LOG:Modifying smb.conf"
		editConf "/etc/samba/smb.conf" $1

		#restarts SAMBA
		echo "LOG:Restarting Samba"
		systemctl stop smb
		systemctl start smb

		#paramater #1  user
		echo "LOG:Adding $1 to Samba"
		addUser $1

		#restarts SAMBA
		echo "LOG:Restarting Samba"
		systemctl stop smb
		systemctl start smb

		#system status
		echo "LOG:Checking status of Samba"
		systemctl status smb

	}

	#user creation
	user=""
	pass=""

	read -p 'Do you want to use an existing user?(y/n)' userchoice
	echo $userchoice

	if [ "$userchoice" == "n" ];
	  then
		  read -p 'What is the username you want to use: ' user
			read -p 'What is the password you want to use: ' pass
			echo "LOG:Adding new user: $user"
			echo "LOG:Adding new password to $user"
			useradd $user
			echo $user:$pass|chpasswd
	    else
			read -p 'What is the username you want to use: ' user
			echo "LOG:Using $user."
	fi

	#apache setup
	read -p 'Do you want to install Apache? (y/n)' userchoice
	  case $userchoice in
	    "y") dnf install httpd ;;
	    "n")  ;;
	  esac

	read -p 'Do you want to configure Apache? (y/n)' userchoice
	  case $userchoice in
	    "y") apache $user ;;
	    "n")  ;;
	  esac

	#NFS setup
	read -p 'Do you want to install NFS? (y/n)' userchoice
	  case $userchoice in
	    "y") dnf install nfs-utils ;;
	    "n")  ;;
	  esac

	read -p 'Do you want to configure NFS? (y/n)' userchoice
	  case $userchoice in
	    "y") nfs $user ;;
	    "n")  ;;
	  esac

	#Samba setup
	read -p 'Do you want to install Samba? (y/n)' userchoice
	  case $userchoice in
	    "y") dnf install samba ;;
	    "n")  ;;
	  esac

	read -p 'Do you want to configure Samba? (y/n)' userchoice
	  case $userchoice in
	    "y") samba $user ;;
	    "n")  ;;
	  esac

	echo 'Completed configurations'
}
#---------------------------------------------------------------------------
#
#	FUNCTION:	remove()
#
#	DESIGNER:	Benedict Lo & Aing Ragunathan
#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
#
#	DATE:		Oct 14, 2017
#
#	DESCRIPTION:
#
#
#	RETURNS:
#			void
#
#---------------------------------------------------------------------------
function remove() {

	#---------------------------------------------------------------------------
	#
	#	FUNCTION:	removeApache()
	#
	#	DESIGNER:	Benedict Lo & Aing Ragunathan
	#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#	DATE:		Oct 14, 2017
	#
	#	DESCRIPTION:	This function removes the Apache package and puts the configs
	#			back to default.
	#	RETURNS:
	#			void
	#
	#---------------------------------------------------------------------------
	function removeApache() {
		echo "LOG:Removing Apache package"
		dnf remove httpd
		echo "LOG:Adding default userdir.conf"
		cp /userdir.conf.default /etc/httpd/conf.d/userdir.conf
	}

	#---------------------------------------------------------------------------
	#
	#	FUNCTION:	removeNFS()
	#
	#	DESIGNER:	Benedict Lo & Aing Ragunathan
	#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#	DATE:	Oct 14, 2017
	#
	#	DESCRIPTION: 	This function removes the NFS package and puts the configs
	#			back to default.
	#
	#	RETURNS:
	#			void
	#
	#---------------------------------------------------------------------------
	function removeNFS() {
		echo "LOG:Removing Samba package"
		dnf remove nfs-utils
		echo "LOG:Removing /etc/exports"
		rm -r -f /etc/exports
		echo "LOG:Adding default /etc/exports file"
		echo "" >> /etc/exports
	}

	#---------------------------------------------------------------------------
	#
	#	FUNCTION:	removeSamba()
	#
	#	DESIGNER:	Benedict Lo & Aing Ragunathan
	#	PROGRAMMER:	Benedict Lo & Aing Ragunathan
	#
	#	DATE:		Oct 14, 2017
	#
	#	DESCRIPTION: 	This function removes the Samba package and puts the configs
	#			back to default.
	#
	#	RETURNS:
	#			void
	#
	#---------------------------------------------------------------------------
	function removeSamba() {
		echo "LOG:Removing Samba"
		dnf remove samba -y
		echo "LOG:Removing /etc/samba/smb.conf"
		rm -r -f /etc/samba/smb.conf
		echo "LOG:Adding default /etc/samba/smb.conf"
		cp /smb.conf.default /etc/samba/smb.conf
	}
	read -p 'Do you want to remove Apache? (y/n)' userchoice
	  case $userchoice in
		"y") removeApache ;;
		"n")  ;;
	  esac

	  read -p 'Do you want to remove NFS? (y/n)' userchoice
		  case $userchoice in
			"y") removeNFS ;;
			"n")  ;;
		  esac

	read -p 'Do you want to remove Samba? (y/n)' userchoice
	  case $userchoice in
		"y") removeSamba ;;
		"n")  ;;
	  esac
}
# if there are no arugments exit file
if [ "$#" -ne 1 ]; then
  echo "Please enter either ./lab4.sh [install/remove]"
  exit 1
  fi
  case $1 in
	"remove") remove  ;;
	"install")  install
  esac
