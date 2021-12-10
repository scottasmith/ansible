#!/bin/bash

ansible_ssh_private_key_file=~/.ansible/ansible-id_rsa
remote_user=ssmith
remote_user_sshkey=~/.ssh/id_rsa
requires_sudo_password=1

server=$1

if [ "x$server" = "x" ]; then
    echo "$0 <server-ip>"
    exit;
fi

if [[ "x$2" == "x0" || "x$2" == "x1" ]]; then
    requires_sudo_password=$2
fi

printf "Installing client dependencies.."
sudo apt install sshpass
printf "\n\n"

printf "Please provide Ansible become password: "
stty -echo
read ansible_password
printf "\n"

if [ $requires_sudo_password == 1 ]; then
    printf "Please provide Remote sudo password: "
    stty -echo
    read remote_password
    printf "\n"
fi

function _ssh {
    ssh -tt "$remote_user@$1" "$2"
}

function _sudo_ssh {
    if [ $requires_sudo_password == 1 ]; then
        _ssh $1 "echo $remote_password | sudo -S $2"
    else
        _ssh $1 "sudo -S $2"
    fi
}

printf "ssh-keyscan on server $server\n"

# ensure it has remote_user_sshkey
ssh-keyscan -H "${server}" >> "${HOME}/.ssh/known_hosts" 2> /dev/null

printf "ssh-copy-id on server $server\n"

# ssh-copy-id
if [ $requires_sudo_password == 1 ]; then
    echo "${remote_password}" | sshpass ssh-copy-id -i "${remote_user_sshkey}" "$remote_user@$server" > /dev/null 2>&1
else 
    ssh-copy-id -i "${remote_user_sshkey}" "$remote_user@$server" > /dev/null 2>&1
fi

SCRIPT="
apt install -y --no-install-recommends vim python3 python3-pip;

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
