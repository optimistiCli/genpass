#!/bin/bash

usage () {
cat <<EOU
Usage:
  genpass.sh [-hlLuUdDsSXaAq] [-x <character list>] [-n <number>] [<length>]

  Generates random password consisting of exactly <length> chars including
  by default capital and lowercase English letters and digits. If no length 
  is provided it defaults to 10 chars. Minimum length is 6.

Options:
  h - Print usage and exit
  l - Use lower case letters (default)
  L - Do NOT use lower case letters
  u - Use upper case letters (default)
  U - Do NOT use upper case letters
  d - Use digits (default)
  D - Do NOT use digits
  s - Use special characters !$%@#
  S - Do NOT use special characters (default)
  x - Use characters form the list - do it at your own risk!
  X - Disable and override the '-x' option
  a - Password must conain chars of all classes
  A - Same as -a but treat special and extra chars as one class (faster)
  n - Generate number of passwords (default is 1)
  q - Do not output anything but the password(s)

Please note that -x option might not be safe. It's better to enforce the use 
of -X in a hostile environment.

EOU
} 


# Char classes
LOWER_CLASS='a-z'
UPPER_CLASS='A-Z'
DIGIT_CLASS='0-9'
SPECIAL_CLASS='!$%@#'


# Set deafaults
LOWER_CHARS="$LOWER_CLASS"
UPPER_CHARS="$UPPER_CLASS"
DIGIT_CHARS="$DIGIT_CLASS"
SPECIAL_CHARS=''
EXTRA_CHARS=''
DISABLE_EXTRA_CHARS=''
ALL_CLASSES=''
JOIN_SPECIAL_AND_EXTRA=''
NUM_OF_PASSWORDS=1
QUIET=''
PASS_LENGTH=10
MIN_PASS_LENGTH=6
FUSE_LENGTH=100


# Read options
while getopts ":n:x:hlLuUdDsSXaAq" O ; do
	case $O in
		h)
			usage
			exit
			;;
		l)
			LOWER_CHARS="$LOWER_CLASS"
			;;
		L)
			LOWER_CHARS=''
			;;
		u)
			UPPER_CHARS="$UPPER_CLASS"
			;;
		U)
			UPPER_CHARS=''
			;;
		d)
			DIGIT_CHARS="$DIGIT_CLASS"
			;;
		D)
			DIGIT_CHARS=''
			;;
		s)
			SPECIAL_CHARS="$SPECIAL_CLASS"
			;;
		S)
			SPECIAL_CHARS=''
			;;
		x)
			EXTRA_CHARS="$OPTARG"
			;;
		X)
			DISABLE_EXTRA_CHARS='Yes'
			;;
		a)
			ALL_CLASSES='Yes'
			JOIN_SPECIAL_AND_EXTRA=''
			;;
		A)
			ALL_CLASSES='Yes'
			JOIN_SPECIAL_AND_EXTRA='Yes'
			;;
		n)
			NUM_OF_PASSWORDS="$OPTARG"
			;;
		q)
			QUIET='Yes'
			;;
	esac
done

[ -n "${!OPTIND}" ] && PASS_LENGTH="${!OPTIND}"

[ -n "$DISABLE_EXTRA_CHARS" ] && EXTRA_CHARS=''
CHARS="${LOWER_CHARS}${UPPER_CHARS}${DIGIT_CHARS}${SPECIAL_CHARS}${EXTRA_CHARS}"


# Set up error reporting
function brag_and_exit {
	if [ -z "$QUIET" ] ; then
		if [ -n "$1" ] ; then
			ERR_MESSAGE="$1"
		else
			ERR_MESSAGE='Something went terribly wrong'
		fi

		echo 'Error: '"$ERR_MESSAGE" >&2
	fi

	exit 1
}


# Checks if password satisfies all the conditions
function run_checks {
	local PASSWORD="$1"

	local SPECIAL_CHARS_LOCAL="$SPECIAL_CHARS"
	local EXTRA_CHARS_LOCAL="$EXTRA_CHARS"
	local JOINT_CHARS_LOCAL=''

	if [ -n "$JOIN_SPECIAL_AND_EXTRA" ] ; then
		SPECIAL_CHARS_LOCAL=''
		EXTRA_CHARS_LOCAL=''
		JOINT_CHARS_LOCAL="${SPECIAL_CHARS}${EXTRA_CHARS}"
	fi

	if [ -n "$ALL_CLASSES" ] ; then
		for C in "$LOWER_CHARS" "$UPPER_CHARS" "$DIGIT_CHARS" "$SPECIAL_CHARS_LOCAL" "$EXTRA_CHARS" "$JOINT_CHARS_LOCAL" ; do
			[ -n "$C" ] || continue

			[ -z "$(echo "$PASSWORD" | LC_CTYPE=C tr -dc "$C")" ] && return 1
		done
	fi

	return 0
}


# Check options
[[ $PASS_LENGTH =~ ^[[:digit:]]+$ ]] || brag_and_exit "Invalid passworg length $PASS_LENGTH"
[ "$PASS_LENGTH" -ge "$MIN_PASS_LENGTH" ] || brag_and_exit "Password should be at least $MIN_PASS_LENGTH long"

[[ $NUM_OF_PASSWORDS =~ ^[[:digit:]]+$ ]] || brag_and_exit "Invalid number of passwords $NUM_OF_PASSWORDS"
[ "$NUM_OF_PASSWORDS" -gt 0 ] || brag_and_exit "Can't generate $NUM_OF_PASSWORDS passwords"

[ -n "$CHARS" ] || brag_and_exit "All character classes disabled"


# Let everyone know what we're up to
if [ -z "$QUIET" ] ; then
	if [ "$NUM_OF_PASSWORDS" -gt 1 ] ; then
		echo "Generating $NUM_OF_PASSWORDS passwords of $PASS_LENGTH chars each" >&2
	else
		echo "Generating $PASS_LENGTH char password" >&2
	fi
fi


# Reads exactly N chars from STDIN then closes it and spits out whatever it have read before
function read_n {
	read -d '' -n "$PASS_LENGTH" BUFFER <&0;
	echo "$BUFFER"
}


# Finaly do the job
I=0
FUSE=0
while [ "$I" -lt "$NUM_OF_PASSWORDS" ] ; do
	PASSWORD="$(cat /dev/urandom | LC_CTYPE=C tr -dc "$CHARS" | read_n)"

	if run_checks "$PASSWORD" ; then
		echo "$PASSWORD"
		I=$(($I+1))
		FUSE=0
	fi
	FUSE=$(($FUSE+1))
	[ "$FUSE" -ge "$FUSE_LENGTH" ] && brag_and_exit "It's taking too long, aborting"
done
