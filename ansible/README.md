Ansible Playbook: Create User, Install Zsh, Copy SSH Key  

## Overview  
This playbook automates the setup of:  
- Zsh  
- Htop  
- A new user  
- SSH access  

If you don't need an update, set:  
‍‍‍
```
update: false  # true = enable, false = disable  
```
## User Configuration  
To configure the new user, update the following variables in vars/main.yml:  

```
user: "your-user"        # New username  
upassword: "your-password" # Password for the new user  
assigned_role: "yes"      # Admin access (yes/no)  
ip: "your-ip-target"      # Target server IP  
usercrate: true           # true = create user, false = skip  
```
### Notes:  

```
- ip: The target IP where the SSH key will be copied.  
- user: The new user's name.  
- upassword: Password for the new user.  
- assigned_role: Whether the user has admin privileges.  
```
Copy the sample vars file:  

```
cp vars/main.yml-sample vars/main.yml  
```
## Changing the Zsh Theme  
To modify the Zsh theme, edit:  

```
vi user_manage/vars/main.yml  
```
Update the theme: 

```
zsh_theme: arrow  # Choose your theme  
```
## Playbook Configuration  
Copy the sample playbook file:  

```
cp playbook.yml-sample playbook.yml  
```
Modify playbook.yml to include your target hosts and roles:  

```
- hosts: "your-target-host"  
  become: yes  # Root access (yes/no)  
  roles:  
    - user_manage  # Add additional roles if needed  
```
## Inventory Configuration (inventory.ini)  
Copy the sample inventory file:  

```
cp inventory.ini-sample inventory.ini  
```
Modify inventory.ini to match your target servers:  

```
Example:  
[remote]  
192.168.1.1 ansible_user=user ansible_ssh_private_key_file=~/.ssh/id_rsa  
```
Or using a password:  

```
[myservers]  
"ip-ssh-target" ansible_user="user" ansible_ssh_pass="password"  
```

## Running the Playbook  
Execute the playbook with:  

```
ansible-playbook playbook.yml -b -i inventory.ini --ask-become-pass  
```
## Docker & Docker Compose  
If you want to install Docker, modify playbook.yml:  

```
vi playbook.yml  
```
Add docker to the roles section:  

```
roles:  
  - user_manage  
  - docker  
```
Provide the Docker username and password:  

```
vi docker/vars/main.yml  
```
Copy the sample vars file:  

```
cp vars/main.yml-sample vars/main.yml  
```
Modify the credentials:  
user: "user"  
upassword: "password"  

## SSH Key Configuration  
To configure SSH keys, edit:  

```
vi user_manage/vars/main.yml  
```
Add your SSH key directory:  


```
sshkey: "your-ssh-key-directory"  
```
## Notes  
- Ensure Ansible is installed before running the playbook.  
- If using SSH keys, set correct permissions:  
  chmod 600 ~/.ssh/id_rsa  
- Customize variables in vars/main.yml as needed.  

🚀 Enjoy automating your server setup with Ansible!  
