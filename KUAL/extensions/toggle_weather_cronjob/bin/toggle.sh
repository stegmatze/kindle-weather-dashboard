#!/bin/sh

CRONTAB_FILE="/etc/crontab/root"
CRON_JOB_PATTERN="refreshWeatherDashboard.sh"
TRIGGER_FILE="/mnt/us/extensions/toggle_weather_cronjob/cronjob_active"

# Function to check if the cron job is currently enabled
is_cron_enabled() {
    grep -q "^[^#].*${CRON_JOB_PATTERN}" "$CRONTAB_FILE"
    return $?
}

# Function to enable the cron job
enable_cron() {
    sed -i "s/^#\(.*${CRON_JOB_PATTERN}\)/\1/" "$CRONTAB_FILE"
    touch "${TRIGGER_FILE}"
}

# Function to disable the cron job
disable_cron() {
    sed -i "s/^\(.*${CRON_JOB_PATTERN}\)/#\1/" "$CRONTAB_FILE"
    rm "${TRIGGER_FILE}"
}

# Main logic
if is_cron_enabled; then
    disable_cron
else
    enable_cron
fi
