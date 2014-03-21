#!/bin/bash
set -e
set +x

project_dir="my_user_environment"


## goto script dir
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

script_dir_parent=${PWD##*/}


main() {
	setup_script ${script_dir_parent}

	set_bashrc
	install_git_crypt
	set_gitconfig
	set_ssh_keys_dir
	set_git_crypt_keys_dir
}

set_bashrc() {
	echo ">> Set \".bashrc\" for user: ${USER}"
		source conf/set-bashrc
	exit_func $?
}

install_git_crypt() {
	echo ">> Install git-crypt"
		source conf/install-git-crypt
	exit_func $?
}

set_gitconfig() {
	echo ">> Set \".gitconfig\" for user: ${USER}"
		install -m 644 conf/gitconfig ${HOME}/.gitconfig
	exit_func $?
}

set_ssh_keys_dir() {
	echo ">> Create \".ssh\" dir for user: ${USER}"
		mkdir -p ${HOME}/.ssh
		echo "copy \"id_rsa\" to ${HOME}/.ssh"
		echo "copy \"id_rsa.pub\" to ${HOME}/.ssh"
		echo "copy \"authorized_keys\" to ${HOME}/.ssh"
	exit_func $?
}

set_git_crypt_keys_dir() {
	echo ">> Create \".git-crypt\" dir for user: ${USER}"
		mkdir -p ${HOME}/.git-crypt
		echo "copy git-crypt keys to ${HOME}/.git-crypt"
	exit_func $?
}

isrootuser() {
	[ $(id -u) = 0 ] || {
		echo "This script must be run as root" 1>&2
		exit 1
	}
}

setup_script() {
	if [ "$1" != ${project_dir} ]; then
		if ! which git > /dev/null
		then
			echo ">> Install git"
				apt-get install -y --no-install-recommends git 1>/dev/null
			exit_func $?
		fi
		echo ">> clone \"${project_dir}\" repo"
			git clone https://github.com/bySabi/${project_dir}.git
		exit_func $?
		cd ${project_dir}
		chmod +x install.sh && ./install.sh &
		exit 0
	fi
}

exit_func() {
	local exitcode=${1}
	if [ $exitcode == 0 ]; then 
		echo -e "\e[00;32mOK\e[00m"
	else 
		echo -e "\e[00;31mFAIL\e[00m"
	fi
}


main "$@"
exit 0
