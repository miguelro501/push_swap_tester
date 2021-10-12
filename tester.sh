#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tester.sh                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dpoveda- <me@izenynn.com>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/10/12 23:36:25 by dpoveda-          #+#    #+#              #
#    Updated: 2021/10/12 23:36:29 by dpoveda-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

### INITIALISE VARIABLES
# Colors
NOCOL='\033[0m'
RED='\033[1;31m'
YEL='\033[1;33m'
ORG='\033[0;33m'
GRN='\033[1;32m'
DGRAY='\033[1;30m'
BLU='\033[1;34m'

# Others
OP_FILE="output.txt"
PS_PATH="$1"
DIGITS='^[+-]?[0-9]+$'

### FUNCTIONS
# Invalid args
function invalid_args () {
	echo -e "${RED}ERROR:${NOCOL} Invalid arguments"
	echo "Usage: ./tester.sh [PUSH_SWAP PATH] [OPTION] [ARGUMENTS]..."
	echo "Try './tester.sh --help' for more information."
	exit 1
}

# Checkers
function check () {
	# $1 == bonus ?
	# $1 or $2 == short ?
	# Checker Mac
	CHK_MAC=`cat $OP_FILE | ./checkers/checker_mac $ARG 2> /dev/null`
	COL_MAC="$GRN"
	if [ -z $CHK_MAC ]; then
		CHK_MAC="n/a"
		COL_MAC="$YEL"
	elif [[ $CHK_MAC == "KO" ]]; then
		COL_MAC="$RED"
	fi

	# Checker Linux
	CHK_LINUX=`cat $OP_FILE | ./checkers/checker_linux $ARG 2> /dev/null`
	COL_LINUX="$GRN"
	if [ -z $CHK_LINUX ]; then
		CHK_LINUX="n/a"
		COL_LINUX="$YEL"
	elif [[ $CHK_LINUX == "KO" ]]; then
		COL_LINUX="$RED"
	fi

	# Print Checkers
	if [[ $1 == "short" ]] || [[ $2 == "short" ]]; then
		printf " ${DGRAY}MAC: ${COL_MAC}%3s${NOCOL}" "$CHK_MAC"
		printf "  ${DGRAY}LNX: ${COL_LINUX}%3s${NOCOL}" "$CHK_LINUX"
	else
		printf "${DGRAY}checker_mac:${NOCOL} ${COL_MAC}%s${NOCOL}\n" "$CHK_MAC"
		printf "${DGRAY}checker_linux:${NOCOL} ${COL_LINUX}%s${NOCOL}\n" "$CHK_LINUX"
	fi

	# Checker bonus
	if [[ $1 == "bonus" ]]; then
		CHK_BONUS=`cat $OP_FILE | $PS_PATH/checker_bonus $ARG 2> /dev/null`
		COL_BONUS="$GRN"
		if [ -z $CHK_BONUS ]; then
			CHK_BONUS="NO OUTPUT"
			COL_BONUS="$RED"
		elif [[ $CHK_BONUS == "KO" ]]; then
			COL_BONUS="$RED"
		fi
		if [[ $2 == "short" ]]; then
			printf "  ${DGRAY}BNS: ${COL_BONUS}%3s${NOCOL}" "$CHK_BONUS"
		else
			printf "${DGRAY}checker_bonus:${NOCOL} ${COL_BONUS}%s${NOCOL}\n" "$CHK_BONUS"
		fi
	fi
	
	# Moves
	MOVES=`cat $OP_FILE | wc -l | xargs`
	if [[ $1 == "short" ]] || [[ $2 == "short" ]]; then
		printf "  ${DGRAY}MOVES:${NOCOL} %-6d\n" "$MOVES"
	else
		printf "${DGRAY}MOVES:${NOCOL} %s\n" "$MOVES"
	fi
}

# Check files
function check_ps () {
	# $1: push_swap path
	if [ ! -f "$1/push_swap" ]; then
		echo -e "${YEL}WARNING:${NOCOL} \"$PS_PATH/push_swap\" does not exists, running make..."
		make -sC "$1"
		echo ""
		if [ ! -f "$1/push_swap" ]; then
			echo -e "${RED}ERROR:${NOCOL} \"$PS_PATH/push_swap\" file does not exists after make."
			exit 1
		fi
	fi
}

function check_bonus () {
	# $1: push_swap path
	if [ ! -f "$1/checker_bonus" ]; then
		echo -e "${YEL}WARNING:${NOCOL} \"$PS_PATH/checker_bonus\" does not exists, running make bonus...\n"
		make bonus -sC "$1"
		echo ""
		if [ ! -f "$1/checker_bonus" ]; then
			echo -e "${RED}ERROR:${NOCOL} \"$PS_PATH/checker_bonus\" file does not exists after make bonus."
			exit 1
		fi
	fi
}

function get_args() {
	if [[ -z $3 ]]; then
		local res=`seq $1 $2 | sort -R | tr '\n' ' '`
	else
		local res=`seq $1 $2 | sort -R | tail -n $3 | tr '\n' ' '`
	fi
	echo "$res"
}

function exec_ps() {
	echo -n `$PS_PATH/push_swap $ARG 2>&1` | tr ' ' '\n' > "$OP_FILE"
	if [ -s "$OP_FILE" ]; then
		echo "" >> "$OP_FILE"
	fi
	local output=`cat "$OP_FILE"`
	if [[ $output == "Error" ]]; then
		echo -e "${RED}ERROR:${NOCOL} push_swap returned \"Error\"${NOCOL}"
		rm -rf "$OP_FILE" 2> /dev/null
		exit 0
	fi
}

### FLAGS FUNCTIONS
function flag_c () {
	local bonus="0"
	for var in "$@"; do
		if [[ $var == "-b" ]]; then
			bonus="1"
			break
		fi
		if ! [[ $var =~ $DIGITS ]]; then
			invalid_args
		fi
		ARG="${ARG} ${var}"
	done
	if [[ -z $ARG ]]; then
		invalid_args
	fi
	printf "${BLU}ARGS:${NOCOL}%s\n\n" "$ARG"
	exec_ps
	if [[ $bonus == "1" ]]; then
		check "bonus"
	else
		check
	fi
}

function flag_co () {
	local bonus="0"
	for var in "$@"; do
		if [[ $var == "-b" ]]; then
			bonus="1"
			break
		fi
		if ! [[ $var =~ $DIGITS ]]; then
			invalid_args
		fi
		ARG="${ARG} ${var}"
	done
	if [[ -z $ARG ]]; then
		invalid_args
	fi
	printf "${BLU}ARGS:${NOCOL}%s\n\n" "$ARG"
	exec_ps
	echo -e "${DGRAY}OUTPUT:${NOCOL}"
	cat "$OP_FILE"
	echo ""
	if [[ $bonus == "1" ]]; then
		check "bonus"
	else
		check
	fi
}

function flag_r () {
	if [ -z $1 ] || [ -z $2 ]; then
		invalid_args
	elif ! [[ $1 =~ $DIGITS ]] || ! [[ $2 =~ $DIGITS ]]; then
		invalid_args
	elif [ ! -z $3 ] && ! [[ $3 == "-b" ]] && ! [[ $3 =~ $DIGITS ]]; then
		invalid_args
	elif [ ! -z $4 ] && ! [[ $4 == "-b" ]]; then
		invalid_args
	fi
	ARG=$(get_args $1 $2 $3)
	if [[ -z $ARG ]]; then
		invalid_args
	fi
	printf "${BLU}ARGS:${NOCOL} %s\n\n" "$ARG"
	exec_ps
	if [[ $3 == "-b" ]] || [[ $4 == "-b" ]]; then
		check "bonus"
	else
		check
	fi
}

function flag_ro () {
	if [ -z $1 ] || [ -z $2 ]; then
		invalid_args
	elif ! [[ $1 =~ $DIGITS ]] || ! [[ $2 =~ $DIGITS ]]; then
		invalid_args
	elif [ ! -z $3 ] && ! [[ $3 == "-b" ]] && ! [[ $3 =~ $DIGITS ]]; then
		invalid_args
	elif [ ! -z $4 ] && ! [[ $4 == "-b" ]]; then
		invalid_args
	fi
	ARG=$(get_args $1 $2 $3)
	if [[ -z $ARG ]]; then
		invalid_args
	fi
	printf "${BLU}ARGS:${NOCOL} %s\n\n" "$ARG"
	exec_ps
	echo -e "${DGRAY}OUTPUT:${NOCOL}"
	cat "$OP_FILE"
	echo ""
	if [[ $3 == "-b" ]] || [[ $4 == "-b" ]]; then
		check "bonus"
	else
		check
	fi
}

function flag_rn () {
	if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
		invalid_args
	elif ! [[ $1 =~ $DIGITS ]] || ! [[ $2 =~ $DIGITS ]] || ! [[ $3 =~ $DIGITS ]]; then
		invalid_args
	elif [ ! -z $4 ] && ! [[ $4 == "-b" ]] && ! [[ $4 =~ $DIGITS ]]; then
		invalid_args
	elif [ ! -z $5 ] && ! [[ $5 == "-b" ]]; then
		invalid_args
	fi
	for (( i=1; i<=$1; i++ )); do
		printf "${BLU}TEST %4d:${NOCOL} " "$i"
		ARG=$(get_args $2 $3 $4)
		if [[ -z $ARG ]]; then
			invalid_args
		fi
		exec_ps
		if [[ $4 == "-b" ]] || [[ $5 == "-b" ]]; then
			check "bonus" "short"
		else
			check "short"
		fi
	done
	}

### SCRIPT
# Check args
if [ -z $1 ]; then
	invalid_args
fi

# Display help
if [[ $1 == "--help" ]]; then
	echo "Usage: ./tester.sh [PUSH_SWAP PATH] [OPTION] [ARGUMENTS]..."
	echo "A tester for 42 push_swap project"
	echo "Example: ./tester.sh -r -10 10"
	echo ""
	echo "Options:"
	echo ""
	echo "    -c [ARGUMENTS]..."
	echo "            run push_swap with provided arguments"
	echo "    -co [ARGUMENTS]..."
	echo "            like -c but displays your push_swap output"
	echo "    -r [RANGE START] [RANGE END] [QUANTITY]"
	echo "            generate a list of random numbers between range"
	echo "            start and range end. If a quantity is specified"
	echo "            it will choose that amount of numbers from the"
	echo "            generated list (default is all the list"
	echo "    -ro [RANGE START] [RANGE END] [QUANTITY]"
	echo "            like -r but displays your push_swap output"
	echo "    -rn [NUMBER OF TESTS] [RANGE START] [RANGE END] [QUANTITY]"
	echo "            like -r but it will perform the number of test"
	echo "            you specified"
	echo ""
	echo "In addition, you can add the flag \"-b\" at the end of any"
	echo "command to display also the checker_bonus output"
	echo "Example: ./tester.sh -rn 100 0 5 -b"
	echo ""
	echo "Also note that in -r, -ro and -rn if range end is smaller than range"
	echo "start range will be 0, so no random arguments will be generated."
	echo "Example: ./tester.sh 10 5 (no numbers will be generated becouse end"
	echo "is smaller than start)"
	echo ""
	echo "Also note that if quantity is less than total range, then quantity will"
	echo "be equal to total range."
	echo "Example: ./tester.sh 0 3 5 (quantity will be 3, not 5)"
	echo ""
	echo "Tester by: izenynn"
	echo "github: https://github.com/izenynn"
	exit 0
fi

# Check push_swap path
if [ ! -d "$1" ]; then
	echo -e "${RED}ERROR:${NOCOL} \"$1\" directory does not exists."
	exit 1
fi
check_ps $1

# Check flags
if [[ -z $2 ]]; then
	invalid_args
elif [[ $2 == "-c" ]]; then
	flag_c ${@:3}
elif [[ $2 == "-co" ]]; then
	flag_co ${@:3}
elif [[ $2 == "-r" ]]; then
	flag_r $3 $4 $5 $6
elif [[ $2 == "-ro" ]]; then
	flag_ro $3 $4 $5 $6
elif [[ $2 == "-rn" ]]; then
	flag_rn $3 $4 $5 $6 $7
else
	invalid_args
fi

# Delete garbage
rm -rf "$OP_FILE" 2> /dev/null
