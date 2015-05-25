#!/bin/bash

netstat=$(netstat -na | grep ".80 " | wc -l);
#echo $netstat;
meanscores=$(cat /home/root1/diplom/meanscores)
#echo $meanscores;
let meanscoresx2=$meanscores*2;
#echo $meanscoresx2;
if [ "$netstat" -gt "$meanscoresx2" ]
then 
#	echo $meanscores
	exec /home/root1/diplom/daemon.pl
else 
#	echo $netstat
	exit
fi
