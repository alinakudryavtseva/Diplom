#!/usr/bin/perl -w

use IO::File;
use strict;
use DBI;
our $host="localhost";
our $db="apachelogs";
our $user="root";
our $passwd="rootroot";
use File::Tail;

my $file=File::Tail->new(name=>"/var/log/nginx/localhost.access.log", maxinterval=>1, adjustafter=>7);
while (defined(my $line=$file->read))
{
	
	my ($ip, $i, $user, $time, $time2, $method, $zapros, $vers, $kodotv, $sizeotv, $referer, $useragent, $x11, $u, $os, $ost1, $ost2, $ost3, $ost4);
	my @line=($ip, $i, $user, $time, $time2, $method, $zapros, $vers, $kodotv, $sizeotv, $referer, $useragent, $x11, $u, $os, $ost1, $ost2, $ost3, $ost4);
	($ip, $i, $user, $time, $time2, $method, $zapros, $vers, $kodotv, $sizeotv, $referer, $useragent, $x11, $u, $os, $ost1, $ost2, $ost3, $ost4) = split /\s+/, $line, 23;
	print "ip=$ip, i=$i, user=$user, time=$time, time2=$time2, method=$method, zapros=$zapros, vers=$vers, kodotv=$kodotv, sizeotv=$sizeotv, referer=$referer, useragent=$useragent, x11=$x11, u=$u, os=$os, ost1=$ost1, ost2=$ost2, ost3=$ost3, ost4=$ost4\n";

	my $flag = 0;
	open(IPDDOS, "/home/root1/diplom/ipddos.txt");
                while(<IPDDOS>)
                {
                        if(/$ip/)
                        {
				$flag = 1;
                        }
		}
			if ($flag == 0)
			{
		
#	my $dbh = DBI->connect("DBI:mysql:$db:$host",$user,$passwd);
        my $dbh = DBI->connect("DBI:mysql:host=localhost:database=apachelogs","root","rootroot");
        if (!defined($dbh))
        	{
                        print "No connecnt to Database";
                }
       	my $selecturi = "SELECT request_uri FROM web1_access_log WHERE request_uri='$zapros'";
        my $selectagent = "SELECT agent FROM web1_access_log";
        my $selectip = "SELECT remote_host FROM web1_access_log WHERE remote_host='$ip'";
	my $selectreferer = "SELECT referer FROM web1_access_log WHERE referer='$referer'";
        my $selectall = "SELECT * FROM web1_access_log";

        my $sthuri = $dbh->prepare($selecturi);
        my $sthall = $dbh->prepare($selectall);
       	my $sthagent = $dbh->prepare($selectagent);
        my $sthip = $dbh->prepare($selectip);
	my $sthreferer = $dbh->prepare($selectreferer);

        $sthuri->execute;
        $sthip->execute;
        $sthagent->execute;
	$sthall->execute;
	$sthreferer->execute;

       	my $countall=0;
        while (my @rowall = $sthall->fetchrow_array)
       	{
       	        $countall++;
        }
        print "$countall\n";

        my $countagent=0;
        my @rowagent = $sthagent->fetchrow_array;
#       print @rowagent[0];
        while (my @rowagent = $sthagent->fetchrow_array)
        {
                $countagent++;
        }
        print "$countagent\n";

        my $counturi=0;
        while (my @row = $sthuri->fetchrow_array)
        {
#               print "@row\n";
       	        $counturi++;
        }
        print "$counturi\n";
	my $p_uri_noddos = ($counturi / $countall);
	print "p_uri_noddos = $p_uri_noddos\n";
 	
	my $countip=0;
        while (my @rowip = $sthip->fetchrow_array)
        {
#               print "@rowip\n";
                $countip++;
        }
        print "$countip\n";

	my $countreferer=0;
	while (my @rowreferer = $sthreferer->fetchrow_array)
	{
#		print "@rowreferer\n";
                $countreferer++;
        }
        print "$countreferer\n";
	my $p_referer_noddos;
	if ($countreferer != 0)
	{ 
		$p_referer_noddos = ($countreferer / $countall);
	}
	else
	{
		$p_referer_noddos = 0.5;
	}
        print "p_referer_noddos = $p_referer_noddos\n";
	

        my $p_ip_noddos;
        if ($countip >= 1)
        {
        	$p_ip_noddos = "0.9";
 	} 
	else 
	{
		$p_ip_noddos = "0.1";
	}
        print "$p_ip_noddos\n";

        my $p_os_noddos;
        if ($os =~ /Unix|Linux|FreeBSD/)
        {
                $p_os_noddos = "0.9";
        }
        else
        {
                $p_os_noddos = "0.4";
 	}

        my $pragent;
        if ($useragent =~ /Mozilla/)
        {
                $pragent = "0.1";
        }
        elsif ($useragent =~ /Safari/)
        {
                $pragent = "0.75";
        }
        elsif ($useragent =~ /Explorer/)
        {
        	$pragent = "0.85";
        }
        elsif ($useragent =~ /Opera/)
        {
                $pragent = "0.9";
        }
        else
        {
        	$pragent = "0.5";
        }

	
	my $p_noddos = $p_ip_noddos * $p_os_noddos * $pragent * $p_uri_noddos * $p_referer_noddos;
        print "p_noddos = $p_noddos\n";

        my $p_ddos = (1 - $p_ip_noddos) * (1 - $p_os_noddos) * (1 - $pragent) * (1 - $p_uri_noddos) * (1 - $p_referer_noddos);
        print "p_ddos = $p_ddos\n";

        my $ddos = log($p_ddos / $p_noddos);
	print "$ddos\n";	

        my $rc0 = $sthuri->finish;
        my $rc1 = $sthagent->finish;
        my $rc2 = $sthall->finish;

#       print "$row[0]\n";
#       my $sizerow = scalar(@row);
#       print "$sizerow\n\n";

        $rc0 = $dbh->disconnect;

        if ($ddos > 0)
        {
#	        my $num='cat /home/root1/diplom/rule';
#                open(RULE, "/home/root1/diplom/rule");
#		my $num=<RULE>;
#		close(RULE);
#		print "num=$num\n"; 
#		chomp $num;
#                my $rule=0;
#                open(IPDDOS, "</home/root1/diplom/ipddos.txt");
#                while(<IPDDOS>)
#                {
#                	if (/"$ip"/)
#                        {
#                        	$rule=1;
#				print $ip;
#                                last;
#                        }
#               }
#               close(IPDDOS);
#		unless($rule)
#
#			else
#                {
	                system("/sbin/iptables -A INPUT -i eth1 -p tcp --dport 80 --source $ip -j DROP");
	
        	        open(BANNED, ">>/home/root1/diplom/banned.txt");
                	print BANNED "banned ip $ip\n";
                	close(BANNED);

	                open(IPDDOS, ">>/home/root1/diplom/ipddos.txt");
        	        print IPDDOS "$ip\n";
                	close(IPDDOS);
	
#        	        $num++;
#                }
#                echo $num > /home/root1/diplom/rule;
#                open(RULE, ">>/home/root1/diplom/rule");
#                print IPDDOS $num;
#                close(RULE);
		
	}

	          

	else
	{
	print "no blok\n";
	}

	
}

else
{
print "uge blok\n";
}

}

