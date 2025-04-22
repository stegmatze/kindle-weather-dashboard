#!/bin/bash

# getting the absolute script directory
script_dir_abs=$(dirname "$(realpath "$0")")

# import environment variables
echo "Checking for existing .env file"
if [ -f "$script_dir_abs/.env" ]; then
  export $(grep -v '^#' "$script_dir_abs/.env" | xargs)
  echo "Imported environment variables from .env file"
fi

# check internet connectivity
check_internet() {
  # pinging a stable server
  if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    return 0  # available
  else
    return 1  # not available
  fi
}

# after internet connection is confirmed
refreshWebLaunch() {
	# dump battery info
	gasgauge_output=$(gasgauge-info -s)
	echo "dump battery info: ${gasgauge_output}"
	echo "var battery = '${gasgauge_output}';" > "$script_dir_abs/battery.js"

	# restart WebLaunch
	echo "start WebLaunch"
#	lipc-set-prop com.lab126.appmgrd stop app://com.PaulFreund.WebLaunch
	lipc-set-prop com.lab126.appmgrd start app://com.PaulFreund.WebLaunch

	# notify uptime monitor
	echo "check for UPTIME_MONITOR_URL environment variable"
	if [[ -z "${UPTIME_MONITOR_URL}" ]]; then
    echo "UPTIME_MONITOR_URL is not set"
  else
    echo "UPTIME_MONITOR_URL is set, notifying uptime monitor"
    battery_level="${gasgauge_output%\%}"
    curl -k --retry 3 "${UPTIME_MONITOR_URL}${battery_level}" &> /dev/null
  fi

	# wait a bit, then disable wifi
	 echo "disable wifi in 10"
	 sleep 10
	 lipc-set-prop com.lab126.cmd wirelessEnable 0
}

# main script logic
# enable wifi
lipc-set-prop com.lab126.cmd wirelessEnable 1
echo "Checking for internet connection..."
while ! check_internet; do
  echo "No internet connection. Waiting 5 seconds before retrying..."
  sleep 5
done

# internet connection confirmed, run the function
refreshWebLaunch
echo "Script execution complete."
