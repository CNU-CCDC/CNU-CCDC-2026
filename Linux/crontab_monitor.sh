# Making sure the script is running as the root user
if [ $EUID -ne 0 ]; then
  echo "This script requires root permissions.  Please rerun under the root user or with the sudo command"
  exit 1
fi

# Checking if the output file exists.  If it does, it deletes it
if [ -f crontabs.txt ]; then
  rm crontabs.txt
fi

# Looping over all the users in /etc/passwd
for user in $(awk -F: '{ print $1 }' /etc/passwd); do
    # Getting the user's crontab
    crontab=$(crontab -u "$user" -l &>/dev/null 2>&1)

    # Skipping writing to the file if the user doesn't have a crontab
    # Don't need to worry about logging because the crontab command already does that
    if [ -z "$crontab" ]; then
        continue
    fi

    # Removing comments from the crontab to reduce clutter
    crontab=$(echo "$crontab" | sed "/^#/d")

    # Logging to the output file
    echo "#### ${user}'s crontab:" | tee -a >> crontabs.txt
    echo "$crontab" | tee -a >> crontabs.txt
done

# Finished!
echo "Checked all user's crontabs!  Open \"./crontabs.txt\" to see what they are."
