#!/bin/bash

ansible_ssh_private_key_file=~/.ansible/ansible-id_rsa
remote_user=ssmith
remote_user_sshkey=~/.ssh/id_rsa

server=$1

if [ "x$server" = "x" ]; then
    echo "$0 <server-ip>"
    exit;
fi

printf "Installing dependencies.."
sudo apt install sshpass
printf "\n\n"

printf "Please provide Ansible become password: "
stty -echo
read ansible_password
printf "\n"

printf "Please provide Remote sudo password: "
stty -echo
read remote_password
printf "\n"

function _ssh {
    ssh -tt "$remote_user@$1" "$2"
}

function _sudo_ssh {
    _ssh $1 "echo $remote_password | sudo -S $2"
}

printf "Starting on server $server\n"
printf "Installing dependencies..\n"

# ensure it has remote_user_sshkey
ssh-keyscan -H $server >> ~/.ssh/known_hosts > /dev/null 2>&1

# ssh-copy-id
echo $remote_password | sshpass ssh-copy-id -i $remote_user_sshkey "$remote_user@$server" > /dev/null 2>&1

SCRIPT="
apt install -y vim;

have_ansible_user=\$(grep ansible /etc/passwd);

if [[ \"x\$have_ansible_user\" == \"x\" ]]; then
    printf \"Setting up ansible user\"
    useradd -m -r -N -G sudo -g users -s /bin/bash ansible;
fi

echo \"ansible:$ansible_password\" | chpasswd;

"
_sudo_ssh $server "bash -c '$SCRIPT'" /dev/null 2>&1

# ssh-copy-id for ansible
echo $ansible_password | sshpass ssh-copy-id -i $ansible_ssh_private_key_file "ansible@$server" #| echo 0 > /dev/null 2>&1
