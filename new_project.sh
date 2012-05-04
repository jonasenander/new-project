#!/bin/bash
set -e # Exit the script if any command returns a non-sero value

# CONFIG
project_root=Projects # Change to you locale if needed
linkeddirs=("Documents" "Pictures" "Downloads")
staticdirs=("www" "Source")
WWmsg="# What and Why"

# Function from http://ubuntuforums.org/archive/index.php/t-436799.html
function ConfirmOrExit() {
	while true
	do
		echo -n "Please confirm (y or n): "
		read CONFIRM
		case $CONFIRM in
		y|Y|YES|yes|Yes) break ;;
		n|N|no|NO|No)
		echo Aborting...
		exit 1
		;;
		*) echo Please enter only y or n
		esac
	done
	echo Continuing ...
}

# SESSION
echo -n "Name of new project: "
read new_project

if [ -L $HOME/$project_root ]; then
	echo "ERROR: Root directory for project is a symlink. Quiting."
	exit 1
fi

if [ -d $HOME/$project_root/$new_project ]; then
	echo "ERROR: New project directory already exists. Do you wish to continue?"
	ConfirmOrExit
fi

`mkdir -p "$HOME/$project_root/$new_project"`
echo "SUCESS: Initiated '$new_project' in '$HOME/$project_root'"
# have to create directories in the different parts before linking
for i in "${linkeddirs[@]}"
do
	if [ -d "$HOME/$i/$project_root/$new_project" ]; then
		echo "WARNING: Project directory already exists in $i. Skipping."
	else
		`mkdir -p "$HOME/$i/$project_root/$new_project"`
		if [ $? > 0 ]; then
			echo "SUCCESS: Created project directory in $i"
		fi
	fi

	if [ -L "$HOME/$project_root/$new_project/$i" ]; then 
		echo "WARNING: Link already exists in project directory. Skipping."
	else
		`ln -s "$HOME/$i/$project_root/$new_project" "$HOME/$project_root/$new_project/$i"`
		if [ $? > 0 ]; then
			echo "SUCCESS: Created link to $i"
		fi
	fi
done

for i in "${staticdirs[@]}"
do
	if [ -d "$HOME/$project_root/$new_project/$i" ]; then
		echo "WARNING: $i already exists in project directory. Skipping."
	else
		`mkdir -p "$HOME/$project_root/$new_project/$i"`
		if [ $? > 0 ]; then
			echo "SUCCESS: Created '$i'"
		fi
	fi
done

# Create the WW document
`touch $HOME/$project_root/$new_project/ww.txt`
echo $WWmsg >> $HOME/$project_root/$new_project/ww.txt

exit 0