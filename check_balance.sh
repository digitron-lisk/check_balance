#!/bin/bash

###################################################################################################
#
#                         check_balance.sh - server side script to
#                      monitor balance of your accounts - by digitron
#                      alert by email (mail must be set up on server)
#           to run it every minute, enter new line in crontab (type crontab -e):
#            * * * * * /bin/bash full-path-to-check_balance.sh >/dev/null 2>&1
#
####################################################################################################
#############################################CONFIGURATION##########################################
my_accounts=('1111111111111111L' '2222222222222222L' '3333333333333333L' '4444444444444444L' '5555555555555555L')
mail_address="example@test.mail"
########################################## END CONFIGURATION #######################################

##### get previous balance from file, if present
if [ -f previous_balance ]
then
	previous_balance=$(<previous_balance)
else
	previous_balance=0
fi

#previous_balance=9999999999999999 # uncomment that line to test functionality of script
current_balance=0

##### point to mon.log in script path and start log entry for this run
log_file="$(dirname $0)/mon.log"
log_mess="---------------------------------------------\n$(date '+%F_%H-%M-%S') - account balance(s)\n"
echo -e $log_mess >> $log_file

##### get current balance = total of all accounts
for (( i=0; i<${#my_accounts[*]}; i++ ))
do
        balance[$i]=$(curl -sm 1 '127.0.0.1:8000/api/accounts/getBalance?address='${my_accounts[$i]} | cut -d':' -f4 | tr -d '"}')

        ##### catch non-integer return
        if [ ${balance[$i]} -ne ${balance[$i]} ] 2>/dev/null
        then
		balance[$i]=0
        fi

	##### make balance human readable
	balance_nice=$(echo ${balance[$i]} | awk '{printf "%.8f\n", $1/100000000}')
				
	##### add log entry
	log_mess="${my_accounts[$i]} = $balance_nice"
	echo -e $log_mess >> $log_file

		current_balance=$((current_balance+balance[i]))
done

##### make balances human readable
current_balance_nice=$(echo $current_balance | awk '{printf "%.8f\n", $1/100000000}')
previous_balance_nice=$(echo $previous_balance | awk '{printf "%.8f\n", $1/100000000}')

##### check if cause for alarm
if [ "$current_balance" -lt "$previous_balance" ]
then
	message="Your Lisk balance is lower than 1 minute ago!\nPrevious balance was $previous_balance_nice\nCurrent balance is $current_balance_nice"
	echo -e $message | mail -s "Lisk Balance Alert" $mail_address
fi

##### save new balance to file
echo $current_balance > previous_balance

##### concludes log entry
log_mess="\nPrevious balance was $previous_balance_nice\nCurrent balance is $current_balance_nice\n---------------------------------------------"
echo -e $log_mess >> $log_file
