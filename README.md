# check_balance
###Account Balance Monitor - Server Side
#####bash script to monitor account balances once a minute, sending out an email alert if total amount gets less

###Required
The script is supposed to run on an Ubuntu system, with a fully synched Lisk node running. Sending mail has to be enabled on the server.

###Usage
Transfer the script to a folder on your server. Make it executable with `chmod +x check_balance.sh`. Change the following lines in the script to show your Lisk and email addresses
```
my_accounts=('1111111111111111L' '2222222222222222L' '3333333333333333L' '4444444444444444L' '5555555555555555L')
mail_address="example@test.mail"
```

Set up a cron job that runs this script once a minute, by typing `crontab -e`and adding a line  
`* * * * * /bin/bash full-path-to-check_balance.sh >/dev/null 2>&1`

You can check functionality of the script by uncommenting this line  
`#previous_balance=9999999999999999`  
Remember to comment it again once you have successfully received a warning mail.

Logs to check in case of trouble are mon.log in the install folder, and mail.log for any mail problems

