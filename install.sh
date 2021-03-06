#!/bin/bash
set -e

project_dir="my_user_environment"


## goto script dir
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

script_dir_parent=${PWD##*/}


main() {
	setup_script ${script_dir_parent}

#	set_bashrc
	install_git_crypt
	set_gitconfig
	set_bash_profile_git_prompt
	set_develop_dir
	set_ssh_keys_dir
	set_git_crypt_keys_dir
#	install_python
	install_apt_full
	install_apt_full_clean
	set_without_sudo_command
}

set_bashrc() {
	echo ">> Set \".bashrc\" for user: ${USER}"
		source conf/set-bashrc
	exit_func $?
}

install_git_crypt() {
	echo ">> Install git-crypt"
		sudo bash conf/install-git-crypt
	exit_func $?
}

set_gitconfig() {
	echo ">> Set \".gitconfig\" for user: ${USER}"
		install -m 644 conf/gitconfig ${HOME}/.gitconfig
	exit_func $?
}

set_bash_profile_git_prompt() {
	echo ">> Set .bash_profile git-prompt for user: ${USER}"
		source conf/set-bash_profile-git_prompt
	exit_func $?
}

set_develop_dir() {
	echo ">> Create \"develop\" dir for user: ${USER}"
		mkdir -p ${HOME}/develop
	exit_func $?	
}

set_ssh_keys_dir() {
	echo ">> Setup \".ssh\" dir for user: ${USER}"
		source conf/set-ssh-dir
	exit_func $?
}

set_git_crypt_keys_dir() {
	echo ">> Setup \".git-crypt\" dir for user: ${USER}"
		source conf/set-git-crypt-dir
	exit_func $?
}

install_apt_full() {
	echo ">> Install \".apt-full\" script on: ${HOME}"
		install -m 755 conf/apt-full ${HOME}/.apt-full
	exit_func $?
}

install_apt_full_clean() {
	echo ">> Install \".apt-full-clean\" script on: ${HOME}"
		install -m 755 conf/apt-full-clean ${HOME}/.apt-full-clean
	exit_func $?
}

set_without_sudo_command() {
	echo ">> Set not sudo for daily use commands"
		source conf/not-sudo-command
	exit_func $?
}

isrootuser() {
	[ $(id -u) = 0 ] || {
		echo "This script must be run as root" 1>&2
		exit 1
	}
}

install_git() {
	echo ">> Install git"
		source conf/install-git
	exit_func $?
}

setup_script() {
	if [ "$1" != ${project_dir} ]; then
		if ! which git > /dev/null
		then
			install_git
		fi
		echo ">> clone \"${project_dir}\" repo"
			[ -d ${project_dir} ] && rm -fr ${project_dir}
			git clone https://github.com/bySabi/${project_dir}.git
		exit_func $?
		cd ${project_dir}
		chmod +x $(basename "$0") && ./$(basename "$0") "$*"
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
