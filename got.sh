#!/bin/bash

#==============================================================================
# Git repo manager;
# 	Keep track of all registered git repos on the current machine
#==============================================================================

# Location of registration file
registration_path=~/.config/got
registration_file=repos.greg
registration_location=$registration_path/$registration_file
registrations_line=("")
registrations_path=("")
registrations_info=("")

registration_regex='^[ \s]*(/[a-zA-Z_0-9/]+)\s+"([^"]*)"$'

mode=""
f_c=0
f_q=0


# Check if file exists
if [ ! -f $registration_location ]
then
	echo "$registration_location does not exist. Create now? [y/n]"
	read answer
	if [[ ! $answer == "y" ]] && [[ ! $answer == 'Y' ]]
	then
		echo "$registration_location not created!"
		echo "Exiting..."
		exit 1
	fi
	if [ ! -d $registration_path ]
	then
		mkdir -p $registration_path
	fi
	echo '# /path/to/repo "info about repo"' > $registration_location
	echo "Created $registration_location"
fi

function listRegistered
{
	# get lines that match regex from config file
	# print if 1 is passed
	verbose=$1
	i=0
	j=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
			registrations_line[$j]="$line"
		if [[ $line =~ $registration_regex ]]; then
			path=${BASH_REMATCH[1]}
			info=${BASH_REMATCH[2]}
			registrations_path[$i]=$path
			registrations_info[$i]=$info
			if [[ 1 -eq $verbose ]]; then
				echo $i") [$info]: $path"
			fi
			let i+=1
		fi
		let j+=1
	done < $registration_location
}

function expect_last
{
	# no more arguments expected
	if [[ $# -gt 1 ]]; then
		echo "Unexpected parameters: <$@>."
		echo "Unhandled... Try --help."
		exit 1
	fi
}

function expect_mode_init
{
	# only one mode at a time
	if [[ ! "$mode" == "" ]]; then
		echo "In mode <$mode>."
		echo "Encountered new mode <$1>."
		echo "Aborting. Try --help."
		exit 1
	else
		# bash scopeing does stuff
		mode="$1"
	fi
}

function get_index
{
	if [[ $# -gt 1 ]]; then
		shift
		potRepNum=$1
		listRegistered 0
	else
		listRegistered 1
		read -p "Select number: " potRepNum
	fi
	# Check if number
	if [[ $(($potRepNum)) -gt ${#registrations_path[@]} ]] || [[ $(($potRetNum)) -lt 0 ]]
	then
		echo "out of bound $potRepNum"
		exit
	fi
	repNum=$potRepNum
}

function print_usage
{
	echo 'got (-r | register) [-p <PATH>]   registers repo'
	echo 'got (-s | status) [-c] [-q]       [--quiet] status for registered repos [--control]'
	echo 'got (-l | list)                   list registered repos'
	echo 'got remove [<NUMBER>]             remove registration'
	echo 'got go [<NUMBER>]                 open repo in new terminal'
}




# check arguments
if [[ $# -eq 0 ]]; then
	print_usage
	exit 1
fi


while [[ $# -gt 0 ]]; do
	case "$1" in
		-h | --help)
			# < print help >
			expect_mode_init "help"
			print_usage
			expect_last
			;;
		-c | --control)
			# < set control flag >
			f_c=1
			;;
		-q | --quiet)
			# < set quiet flag >
			f_q=1
			;;
		-r | register)
			# < enter registration mode >
			expect_mode_init "register"
			# check for path parameter
			if [[ $# -gt 1 ]]; then
				shift
				if [[ $1 == "-p" ]]; then
					if [[ $# -gt 1 ]]; then
						shift
						potRepDir=$1
					else
						echo "Expected path after <-p>. Try --help."
						exit 1
					fi
				elif [[ $1 =~ --path=(.*) ]]; then
					potRepDir=${BASH_REMATCH[1]}
				else
					echo "Unexpected argument <$1>. Try --help."
					exit 1
				fi
			# use current directory if no path supplied
			else
				potRepDir=$(pwd)
			fi
			# check if directory exists
			if [ ! -d $potRepDir ]
			then
				echo "<$potRepDir> not a directory! Try --help."
				exit 1
			fi
			# check if directoy is root of a git repository
			if [ ! -d $potRepDir/.git ]
			then
				echo "<$potRepDir> not a git repository! Try --help."
				exit 1
			fi
			repDir=$potRepDir
			;;
		-s | status)
			# < enter status mode >
			expect_mode_init "status"
			;;
		-l | list)
			# < enter list mode >
			expect_mode_init "list"
			expect_last
			;;
		remove)
			# < enter removal mode >
			expect_mode_init "remove"
			get_index $@
				if [[ $# -gt 1 ]]; then
					shift
				fi
			expect_last
			;;
		go)
			# < enter mode to open repository in new terminal >
			expect_mode_init "go"
			get_index $@
				if [[ $# -gt 1 ]]; then
					shift
				fi
			expect_last
			;;
		dump)
			# < this is mostly for debugging, but hey you can call it >
			listRegistered 0
			echo "found <dump> ignoring rest:"
			echo "PATH-DUMP start ..."
			for index in ${!registrations_path[@]}; do
				echo "> ${registrations_path[index]}"
			done
			echo "PATH-DUMP done."
			echo ""
			echo "INFO-DUMP start ..."
			for index in ${!registrations_info[@]}; do
				echo "> ${registrations_info[index]}"
			done
			echo "INFO-DUMP done."
			echo ""
			echo "LINE-DUMP start ..."
			for index in ${!registrations_line[@]}; do
				echo "> ${registrations_line[index]}"
			done
			echo "LINE-DUMP done."
			echo ""
			exit 1337
			;;
		*)
			expect_last
			;;
	esac
	shift
done


# perform action according to arguments
case "$mode" in
	register)
		if [[ $f_q -eq 0 ]]; then
			echo "Found $repDir/.git"
			echo "Adding to tracked repos..."
		fi
		if [[ $f_c -eq 1 ]]; then
			read -p "Add descripion: " info
		else
			info=$(basename $repDir)
		fi
		echo "$repDir \"$info\"" >> $registration_location
		expect_last
		;;
	status)
		listRegistered 0
		for index in ${!registrations_path[@]}
		do
			repo=${registrations_path[index]}
			# if verbose -> print full status messages
			if [[  $f_q -eq 0 ]]; then
				echo "=================================================="
				echo ""
				echo "[ $repo ] ($index)" | GREP_COLOR='31;1' grep --color=always -E "\([0-9]\)|$"
				echo "( ${registrations_info[index]} ):"
				echo ""
				git -C $repo remote update
				echo ""
				git -C $repo status | GREP_COLOR='30;47' grep --color=always -E "up to date|up-to-date|ahead|behind|diverged|$" | GREP_COLOR='30;47' grep --color=always -E "by [0-9]+ commit[s]*|$" | GREP_COLOR='39;4' grep --color=always -E "modified:|deleted:|new file:|renamed:|$"
				echo ""
			else
				# mute
				git -C $repo remote update | grep "" -q
			fi
			# collect simple "changed? yes/no" information on each repository
			change=$(git -C $repo status | grep -E 'ahead|behind|modified|diverged|deleted|renamed|new file')
			if [[ ! "$change"  == "" ]]
			then
				# bring everything to start of line
				unindent_change=$(echo -e "$change" | sed -e 's/^[ \t]*//')
				# indent same amount
				indent_change=$(echo -e "$unindent_change" | sed -e 's/^/    /')
				attend="$attend[$index] $repo:\n""$indent_change""\n"
			fi
			# if -c specified by user -> wait for input
			if [[ $f_c -gt 0 ]] && [[ $f_q -eq 0 ]]; then
				read -p "Press ENTER to continue" dummy
			fi
		done
		echo "=================================================="
		echo "Report:"
		echo '""""""'
		echo -e "$attend" | GREP_COLOR='39;4' grep --color=always -E "\[.*$|$"
		expect_last
		;;
	list)
		listRegistered 1
		expect_last
		;;
	remove)
		# get remove path
		del_path=${registrations_path[repNum]}
		if [[ $f_q -eq 0 ]]; then
			echo "picked $del_path"
			echo ""
		fi

		# clear file then rebuild with all but selected
		echo "" > $registration_location

		# remove _line not combination of _path and _info to keep formatting and comments in tact
		for index in ${!registrations_line[@]}; do
			line=${registrations_line[index]}

			# distinguish between comment line and registration line
			if [[ $line =~ $registration_regex ]]
			then
				# check if this is the path that should be removed
				if [[ $del_path = ${BASH_REMATCH[1]} ]]
				then
					# Dont reprint this line --> delete
					if [[ $f_q -eq 0 ]]; then
						echo "-- $del_path"
					fi
				else
					# Reprint this reg line
					if [[ $f_q -eq 0 ]]; then
						echo "*  $line"
					fi
					echo $line >> $registration_location
				fi
			else
				# reprint this comment line
				echo $line >> $registration_location
				if [[ $f_q -eq 0 ]]; then
					echo "#  $line"
				fi
			fi
		done
		;;
	go)
		currPath=${registrations_path[repNum]}
		urxvt -cd $currPath &
		;;
	*)
		echo "no action performed. Try -help."
		exit 1
		;;
esac
# done
exit 0
