#!/bin/bash
#
###############################################################################################################################################
#
#   This Script is designed for use in JAMF as an Extension Attribute
#	with a Data Type of Date (YYY-MM-DD hh:mm:ss)
#	and a name of OneDrive Last Sync Timestamp
#
#   - This script will ...
#       Look at the users OneDrive For Business and check for Last Sync'd time.
#		This enables Smart Groups and reporting and alerting or out of date OneDrive
#		and also unconfigured OneDrive
#
#	- Notable Information
#		This Extension Attribute is designed to run in Conjunction with 2 Smart Groups in JAMF.
#		For this reason 3 Specific Dates are used to Convey different States.
#
#		1 : No User Logged in - Date will be set to 28-06-1919 00:00:00 
#			(Date The Treaty of Versailles was signed, ending the First World War )
#
#		2 : Logged in User does not Have OneDrive Set up - Date Will be set to 02-09-1945 00:00:00
#			(Date Japan signed official Surrender on the Deck of the USS Missouris ending the Second World War)
#
#		3 : Highest Date to be used for any Specific function - 20-07-1969 21:17:40
#			(UK Date and Time Apollo 11's "Eagle" Landed On the Moon)
#
#	- How this is used in Smart Groups
#		2 Smart Groups are set up in JAMF to act on this Information.
#
#		1 : "OneDrive Not Sync'd in xx Days"
#			A Smart Group with 2 Criteria.
#			"OneDrive Last Sync Timestamp" After 1969-07-20 - This is to Eliminate any of the "Special" Dates.
#								AND
#			"OneDrive Last Sync Timestamp" more than x Days Ago - This is to Trigger on the number of days decided up for this.
#
#		2 : "OneDrive Not Set Up for User"
#			A Smart Group with 2 Criteria, set to Isolate the "Special" Date chosen to indicate this eventuality.
#			"OneDrive Last Sync Timestamp" After 1945-09-01
#								AND
#			"OneDrive Last Sync Timestamp" After 1945-09-03
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.1 - 10/12/2019
#
#   - 14/01/2019 - V1.0 - Created by Headbolt
#
#   - 10/12/2019 - V1.1 - Updated by Headbolt
#							Re Written to fix issues introducted by latest versions
#							of the OneDrive App. Also better ways of dealing with 
#							no users logged in at Inventory, or OneDrive Not being 
#							configured for the user.
#							Also Better Documentation, Reporting and Error Checking
#
###############################################################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
USER=$(stat -f%Su /dev/console) # Get Current User Name.
GUID=$(sudo ls /Users/$USER/Library/Application\ Support/OneDrive/settings/Business1/*.dat | rev | cut -c 5- | rev) # Get OneDrive Instance GUID.
#
###############################################################################################################################################
# 
# Begin Processing
#
###############################################################################################################################################
#
if [ "$USER" = "root" ] # Check for Username being "root" ie Nobody is Logged in.
	then
		STAMP='1919-06-28 00:00:00' # Set TimeStamp to a Value indicating OneDrive NOT Set Up.
	else
		if [ "$GUID" = "" ] # Check for empty GUID, Indicating OneDrive not Set up for this user.
			then
				STAMP='1945-09-02 00:00:00' # Set TimeStamp to a Value indicating OneDrive NOT Set Up.
			else
				INIFILE=$(echo $GUID.ini) # Use GUID to get .ini file name and path.
				STAMP=$(date -r "$INIFILE" +"%Y-%m-%d %H:%M:%S") # Get TimeStamp of ini File and convert to UK Format .
		fi
fi
#
# Output Results
/bin/echo "<result>$STAMP</result>"
