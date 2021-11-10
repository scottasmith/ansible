# Remote server
Although ansible doesn't run on the remote server, it still requires python3

## dependencies
This will be using python3 throughout. Please ensure the server and the control node has it installed with pip3.
Ubuntu focal will need `python-is-python3` package to bind the `python3` binary to `python`.

## Remote RedHat/CentOS Server
This server does not come with python3 installed using minimal install. Install with;
```
$ sudo yum install python3
```

# Private SSH key
The private SSH key for the ansible user on the servers needs to be in the `~/.ansible/ansible-id_rsa` file. This is used by the `ansible.cfg` file in this repository.
It must only be accessible by your user:
```
$ chmod 600 ~/.ansible/ansible-id_rsa
```

# Vault password file
The vault password file must be located in the directory `~/.ansible/vault_pass.txt`. This is used by the `ansible.cfg` file in this repo.

It must only be accessible by your user:
```
$ chmod 600 ~/.ansible/vault_pass.txt
```

# Using ansible
Any commands will be the same exept that you prefix with the docker container run:
```
$ docker run -v $HOME/.ansible:/home/ansible/.ansible -v $(pwd):/ansible scottsmith/ansible:2.4 ansible-playbook playbooks/server.yml
```

## Collections
This repo requires collections from the Ansible galaxy
They are in the file `requirements.yml`

To install the required collections:
```
$ docker run -v $HOME/.ansible:/home/ansible/.ansible -v $(pwd):/ansible scottsmith/ansible:2.4 ansible-galaxy collection install -r requirements.yml -p ./
```

Playbook
```
$ docker run -v $HOME/.ssh/known_hosts:/etc/ssh/ssh_known_hosts:ro -v $HOME/.ansible:/home/ansible/.ansible -v $(pwd):/ansible scottsmith/ansible:2.4 ansible-playbook playbooks/proxy.yaml
```