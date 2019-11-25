#!/bin/bash
#===============================================================================
# AUTHOR:       : Stefano Viola (stefano.viola@seco.com)
# TITLE         : prints.sh
# LICENSE       : GPL
# VERSION       : 0.1
#===============================================================================
#
# INFO: Small bash library for custom prints
#
#===============================================================================
#
#
# USAGE: source prints.sh
#
#


PRINTS_VERBOSE=0
PRINTS_DEBUG=0

COLOR_RESET="\e[39m"
COLOR_DEBUG="\e[36m"
COLOR_ERROR="\e[31m"
COLOR_WARNING="\e[33m"
COLOR_INFO="\e[39m"
COLOR_SUCCES="\e[32m"


function echo_d () {
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - ${FUNCNAME[1]}:${BASH_LINENO[$FUNCNAME[1]]} - D ]: "
	else
		verbose_str="* "
	fi
	if [ $PRINTS_DEBUG = 1 ]; then
		echo -e "$COLOR_DEBUG$verbose_str$1$COLOR_RESET"
	else
		return
	fi
}

function echo_e () {
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - ${FUNCNAME[1]}:${BASH_LINENO[$FUNCNAME[1]]} - E ]: "
	else
		verbose_str="* ERROR: "
	fi
	echo -e "$COLOR_ERROR$verbose_str$1$COLOR_RESET"
}


function echo_w () {
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - ${FUNCNAME[1]}:${BASH_LINENO[$FUNCNAME[1]]} - W ]: "
	else
		verbose_str="* WARNING: "
	fi
	echo -e "$COLOR_WARNING$verbose_str$1$COLOR_RESET"
}


function echo_i () {
	local verbose_str=""
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - I ]: "
	else
		verbose_str="* "
	fi
	echo -e "$COLOR_INFO$verbose_str$1$COLOR_RESET"
}


function echo_i_n () {
	local verbose_str=""
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - I ]: "
	else
		verbose_str="* "
	fi
	echo -e -n "$COLOR_INFO$verbose_str$1$COLOR_RESET"
}


function echo_ok () {
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - OK]: "
	else
		verbose_str="* "
	fi
	echo -e "$COLOR_SUCCES$verbose_str$1$COLOR_RESET"
}


function echo_ko () {
	if [ $PRINTS_VERBOSE = 1 ]; then
		verbose_str="[`date +"%T"` - OK]: "
	else
		verbose_str="* "
	fi
	echo -e "$COLOR_ERROR$verbose_str$1$COLOR_RESET"
}

# END

