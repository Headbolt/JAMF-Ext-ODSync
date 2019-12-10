#!/bin/bash
#
###############################################################################################################################################
#
#   This Script is designed for use in JAMF as an Extension Attribute
#	with a Data Type of Date
#
#   - This script will ...
#       Look at the users OneDrive For Business and check for Last Sync'd time.
#		This enables Smart Groups and reporting and alerting or out of date OneDrive
#		and also unconfigured OneDrive
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
		STAMP="No User Logged In" # Set TimeStamp to a value indicating nobody is logged in when Inventory ran.
	else
		if [ "$GUID" = "" ] # Check for empty GUID, Indicating OneDrive not Set up for this user.
			then
				STAMP='Not Configured for "'$USER'"' # Set TimeStamp to a Value indicating OneDrive NOT Set Up.
			else
				INIFILE=$(echo $GUID.ini) # Use GUID to get .ini file name and path.
				STAMP=$(date -r "$INIFILE" +"%Y-%m-%d %H:%M:%S") # Get TimeStamp of ini File and convert to UK Format .
		fi
fi
#
# Output Results
/bin/echo "<result>$STAMP</result>"
