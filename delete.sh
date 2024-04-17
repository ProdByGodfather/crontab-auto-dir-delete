# Specify the URL of an NTP server

ntp_server="http://worldtimeapi.org/api/ip"

# Get the current timestamp (in seconds) from the NTP server
timestamp=$(curl -s "$ntp_server" | jq -r '.unixtime')

if [ -z "$timestamp" ]; then
    echo "Failed to fetch time from the internet. Using system time."
    timestamp=$(date +%s)
fi

# Specify the target date and time in the format: "YYYY-MM-DD HH:MM:SS"
target_datetime="2024-04-17 13:35:00"
target_timestamp=$(date -d "$target_datetime" +%s)

# Calculate the difference between the target and current timestamps
time_diff=$((target_timestamp - timestamp))

# Check if the target time has passed
if [ $time_diff -le 0 ]; then
    # If the target time has passed, delete the folder
    rm -rf ~/Desktop/dr
    echo "Folder deleted successfully!"
else
    # If the target time has not passed yet, calculate the remaining time in seconds
    echo "Folder will be deleted on $target_datetime"
    echo "Remaining time: $(date -u -d @$time_diff +'%H:%M:%S')"
fi
