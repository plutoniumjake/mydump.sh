#!/bin/bash
ver=0.1
#This script is designed to dump databases per table.
#Please report bugs to jvandeventer@liquidweb.com

#check to see if mysql is running
mysql=$(/usr/bin/mysqladmin ping | grep -o alive)
mysqlalive () {
if [ $mysql == alive ]
	then
		echo "mysqld found, proceeding..."
		sleep 1
	else
		echo "No mysql process found. Go get yourself a mysql server and come back."
		sleep 3
		exit 0
fi
}

#Trying to ensure proper usage here.
warning () {
clear
echo "This script will create separate dumps for each table."
sleep 1
echo "Please..."
sleep 1
echo "...for the love of God..."
sleep 2
echo "...run this script in the directory that you want your dumps."
sleep 4
echo "And make sure you have enough space on the partition."
sleep 4
}

#The menu text
menutext () {
echo "mydump.sh $ver"
echo "Please select from the following options:
1 - Dump all the things (all dbs, all tables).
2 - Dump almost all the things. (minus the generic databases)
3 - Dump all the tables for the databases in /root/dbs.txt.
4 - Dump only the tables in /root/tables.txt for the databse(s) in /root/dbs.txt.
0 - Exit. I never wanted this."
}

#The menu
menu () {
mainloop=0
while [ $mainloop == 0 ] ; do
	clear
	menutext
	echo -n "It's go time. What's it gonna be? "
	read choice
		case $choice in
		1)
		alldbs
		alltables
		dump1
		mainloop=1 ;;
		2)
		alldbsminus
		alltables
		dump1
		mainloop=1 ;;
		3)
		dbstxt
		alltables
		dump1
		mainloop=1 ;;
		4)
		dbstxt
		tablestxt
		dump2
		mainloop=1 ;;
		0)
		echo "I never loved you anyway."; 
		mainloop=1 ;;
		*)
		echo "I'm afraid I can't let you do that, Dave."
		sleep 2
		clear
		esac
	done
exit 1
}
yesno () {
#yes/no function
echo -n "$1 (y/n): "
read ans
case "$ans" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) echo "No? Ok... It's a free country..."; return 1 ;;
esac
}

#looks for a dbs.txt file and sets the variable accordingly
dbstxt () {
if [[ -f /root/dbs.txt ]]; then
	echo -n "/root/dbs.txt found. Do you want to use it? "
		if yesno; then
		dbs=$(cat /root/dbs.txt)
		else
		echo "Then why did you choose that option?" 
		sleep 2
		echo "Try again. Try harder this time."
		sleep 3
		menu
		fi
	else
	echo -n "/root/dbs.txt not found. Please either create it or select another option. "
	sleep 3
	menu
fi
}

#sets the variable for all dbs on the server
alldbs () {
echo "Setting dbs to all."
sleep 1
dbs=$(mysql -s -B -e "show databases")
}

#sets the variable for all the dbs minus some generic databases
alldbsminus () {
echo "Setting dbs to all except root, horde, cphulkd, eximstats, modsec, mysql, information schema, leechprotect and roundcube."
sleep 1
dbs=$(mysql -s -B -e "show databases" | egrep -v '(root|horde|cphulkd|eximstats|modsec|roundcube|information_schema|leechprotect|mysql)')
}

tablestxt () {
if [[ -f /root/tables.txt ]]; then
        echo -n "/root/tables.txt found. Do you want to use it? "
                if yesno; then
                tables=$(cat /root/tables.txt)
		else
		echo "Then why did you choose that option?" 
		sleep 2
		echo "Try again. Try harder this time."
		sleep 3
		menu
		fi
        else
        echo -n "/root/tables.txt not found. Please either create it or select another option. "
	sleep 3
	menu
fi
}

alltables () {
echo "Setting tables to all."
sleep 1
}

dump1 () {
echo "Dumping..."
sleep 1
	for db in $dbs ;
	do 
		mkdir $db
		for table in $(mysql $db -s -B -e "show tables");
		do
			echo ">>> $db $table"
			mysqldump $db $table > $db/$db.$table.sql 2> error.log
		done
	done
echo "It is finished."
}

dump2 () {
echo "Dumping..."
sleep 1
	for db in $dbs ;
	do
		mkdir $db
		for table in $tables ;
		do
			echo ">>> $db $table"
			mysqldump $db $table > $db/$db.$table.sql 2> error.log
		done
	done
echo "It is finished. Check the error log for errors."
}
mysqlalive
warning
menu
