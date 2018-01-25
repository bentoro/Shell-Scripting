# Shell-Scripting

Pseudo Code

START
• Check program arguments
• If the argument is set to remove
o Gotothe“Remove”state
• Otherwise, if the argument is set to install
o Gotothe“Install”state
Remove
• Prompt for Apache removal
• If the user wants to remove Apache
o Uninstall Apache
o Resettheconfigurationfiles
• Prompt for NFS removal
• If the user wants to remove NFS
o Uninstall NFS
o Resettheconfigurationfiles
• Prompt for Samba removal
• If the user wants to remove Samba o Uninstall Samba
o Resettheconfigurationfiles
• Exit the program
Install
• Prompt the user for user creation
• Prompt the user for a username
• If the user wants to create a new user
o Go to the “User Creation” state
• Prompt for Apache installation
• If the user wants to install Apache
o RunApacheinstallation
• Prompt user for Apache configuration
• If the user wants to configure Apache
o Gotothe“ConfigureApache”state
• Prompt for NFS installation
• If the user wants to install NFS

o Run NFS installation
• Prompt user for NFS configuration
• If the user wants to configure NFS
o Gotothe“ConfigureNFS”state
• Prompt for Samba installation
• If the user wants to install Samba
o Run Samba installation
• Prompt user for Samba configuration
• If the user wants to configure Samba
o Gotothe“ConfigureSamba”state
• Exit the program

User Creation
• Prompt the user for a new password
• Create a new user using the user supplied username and password

Configure Apache
• Set permissions of user’s home directory
• Create a folder for holding html files in the user’s home directory
• Create a passwords directory for holding the password for the webpage
• Prompt user for the new apache password file name
• Edit the user configuration file for apache to include new information
• Start the apache service
• Restart the Apache service
• Print the status of Apache to the user

Configure NFS
• Create a test file in the user’s home directory
• Set the permissions of the new file
• Change the ownership of the new file
• Change the ownership of the user’s home directory
• Edit the exports file to contain the IP address of computer allowed to access the user’s home
directory
• Enable the NFS service
• Start the NFS service
• Make the file system available in NFS
• Restart the NFS service
• Print the status of the NFS service to the user

Configure Samba
• Enable the Samba service
• Edit the Samba configuration file to set the public security
• Stop the Samba service
• Start the Samba service
• Add the user’s password to the Samba service
• Stop the Samba service
• Start the Samba service
• Print the status of the Samba service to the user
