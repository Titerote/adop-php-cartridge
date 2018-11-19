#!/bin/bash

if [ -z "$1" ]; then
	echo "You need to indicate an action "
	exit 0;
else
	ACTION=$1
fi;

source $(dirname $0)/src/scripts/local.env

#echo $CARTRIDGE_TMPL_PATH
#echo $SCRIPTS_PATH
#echo $ACTION

cd $CARTRIDGE_TMPL_PATH

#export $( grep -v '^#' $SCRIPTS_PATH/${ACTION}.env | sed -E 's/(.*)=.*/\1/' | xargs)
export $( grep -v '^#' $SCRIPTS_PATH/${ACTION}.env |  xargs)

source $SCRIPTS_PATH/${ACTION}.sh

