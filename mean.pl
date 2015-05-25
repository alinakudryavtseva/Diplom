#!/usr/bin/perl

#run cron ones a day

open (NETSTAT, "/home/root1/diplom/netstat.txt") or die "Not file\n";
 
$sum = 0;
$scores = 0;
while ($line = <NETSTAT>)
{
foreach ($line) 
{
	$sum += $line;
	$scores++;
}
}
$meanscores = $sum / $scores;
$intmeanscores = int $meanscores;
open (MEANSCORES, ">/home/root1/diplom/meanscores");
print (MEANSCORES "$intmeanscores");
#print "$meanscores\n";	
close NETSTAT;

