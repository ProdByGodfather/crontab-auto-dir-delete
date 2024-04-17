# crontab auto dir delete
One of the challenges created in the Ubuntu environment was that we wanted our project directory to be deleted after 10 days of use and after expiration so that the client would receive the final and paid version of the project.
This led us to turn to crontab within the Ubuntu environment.
## structure
A `.sh` file with name `delete.sh` is included for this project, which is placed in this repository.
In the first step, we get the time from the Internet to make sure that the time is not manipulated by the user on the computer.
This is how we got the seconds of the year from a website:
```shell
ntp_server="http://worldtimeapi.org/api/ip"

# Get the current timestamp (in seconds) from the NTP server
timestamp=$(curl -s "$ntp_server" | jq -r '.unixtime')
```
We considered all the possibilities and gave the possibility of the internet being down, so now we have to get the current time from the system as a second way if there is no internet.
```shell
if [ -z "$timestamp" ]; then
    echo "Failed to fetch time from the internet. Using system time."
    timestamp=$(date +%s)
fi
```
In the next part, we should have given the desired time to delete the project to the file, so that if the current time exceeds the time we gave, the project will be deleted.

We put the target time into the target_time variable like this
And with the format `YYYY-MM-DD HH:MM:SS` we gave:
```shell
target_datetime="2024-04-17 13:35:00"
```
And to check the current time with the target time, we had to convert the target time to seconds:
```shell
target_timestamp=$(date -d "$target_datetime" +%s)
```
Now we checked if the current time has reached the target time or if it has passed the target time. If it passed, delete our folder.
```shell
time_diff=$((target_timestamp - timestamp))

# Check if the target time has passed
if [ $time_diff -le 0 ]; then
    # If the target time has passed, delete the folder
    rm -rf /your/directory/source
    echo "Folder deleted successfully!"
else
    # If the target time has not passed yet, calculate the remaining time in seconds
    echo "Folder will be deleted on $target_datetime"
    echo "Remaining time: $(date -u -d @$time_diff +'%H:%M:%S')"
fi
```
## crontab
The first reason for choosing crontab was that it does its work again after the system is restarted or in all different situations, and this reason is completely accepted.
Here we have to give the path of our delete.sh file to crontab so that our file is executed every time and the desired checks are done.
1. In the first step, we run crontab with the following command in the terminal:
    ```shell
    crontab -e
    ```
    If you are asked a question, choose number `1`.
2. Replace the following code in the last line of the file that opens.
    ```shell
    * * * * * /bin/bash /the/sh/file/location/delete.sh
    ```
   The story of the first 5 stars of this order is as follows.
   ```
       * * * * * /path/to/command
       - - - -
       | | | | |
       | | | | +---- Day of the week (0 - 7) (Sunday=0 or 7)
       | | | +------ Month (1 - 12)
       | | +-------- Day of the month (1 - 31)
       | +---------- Hour (0 - 23)
       +------------ Minute (0 - 59)
   ```
   We entered all 5 stars here without numbers so that our file will run every minute, but you can edit this for yourself according to the guide above.

In this section, our work with crontab is finished.

## sudo
One of our challenges in the next section is that naturally, when the files of a folder or directory are running, we cannot delete the folder unless we have sudo access. However, crontab is not allowed to use sudo. To solve this challenge, these steps must be taken.
1. Go to `visudo` with the following command in the terminal:
   ```shell
   sudo visudo
   ```
2. To have sudo access to delete the desired folder without giving this permission in the terminal, add this code at the end of the opened file: **(Change your directory path in the last section)**
   ```shell
   username ALL=(ALL) NOPASSWD: /bin/rm -rf /your/directory/source
   ```


By doing these steps, your folder will be deleted in the target time **(the probability of deletion is one minute more)**.