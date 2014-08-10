#!/bin/bash

# File: pswatch.sh
# Purpose: pswatch - cpu monitoring shell script
# Author: Paul Greenberg (http://www.greenberg.pro)
# Version: 1.0
# Copyright: (c) 2011 Paul Greenberg <paul@greenberg.pro>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


# CPU offenders
# cat /var/log/pswatch.log | grep "topcpu;" | awk -F";" '{print $4","$1}' | sed 's/^\s//' | sort -r | head -11
# cat /var/log/pswatch.log | grep "Tue Jul 19 07:33" | grep ";topcpu;" | awk -F";" '{print $4","$1}' | sed 's/^\s//' | sort -r | head -11

LOGFILE=/var/log/pswatch.log
TIMESTAMP=`date +%s`
PSDATE=`date -d @$TIMESTAMP`
LOGSTAMP=`date "+%Y%m%d-%H%m%S" -d @$TIMESTAMP`

# Check if log file exist
if [ -f $LOGFILE ]; then
 LOGSIZE=`stat -c %s $LOGFILE`
 # Check if file is more than 20M (20,000,000)
 if [[ $LOGSIZE -gt "20000000" ]]; then
  mv $LOGFILE $LOGFILE.$LOGSTAMP
 fi
fi


COUNT=0
while [ $COUNT -le 10 ]; do

 TIMESTAMP=`date +%s`
 PSDATE=`date -d @$TIMESTAMP`

 # High RAM (total,used,free,shared,buffers,cached)
 RAMSIZE=`free -m |awk 'NR==2' |awk '{ print $2","$3","$4","$5","$6","$7 }'`
 PSOUTS1=$(echo `ps -eo pcpu,pmem,user,pid,command | grep -v "%CPU" | sort -r | head -11 | tr '\n' ';'`)
 PSOUTS2=$(echo `ps -eo pmem,pcpu,user,pid,command | grep -v "%CPU" | sort -r | head -11 | tr '\n' ';'`)

 OIFS=$IFS
 IFS=';'

 echo $PSDATE";mem;"$RAMSIZE >> $LOGFILE

 for PSOUT in $PSOUTS1
 do
  echo $PSDATE";"$TIMESTAMP";topcpu;"$PSOUT >> $LOGFILE
 done

 for PSOUT in $PSOUTS2
 do
  echo $PSDATE";"$TIMESTAMP";topmem;"$PSOUT >> $LOGFILE
 done

 IFS=$OIFS
 COUNT=$(( $COUNT + 1 ))

 sleep 5
done
