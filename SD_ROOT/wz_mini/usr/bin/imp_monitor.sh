#!/opt/wz_mini/bin/bash

INTERVAL=60
LOCKFILE="/opt/wz_mini/tmp/daemon.lock"
LOGFILE="/opt/wz_mini/log/daemon.log"
SCRIPT_PATH=$(cd $(dirname "$0") && pwd -P)/$(basename "$0")

check() {
    output=$(impdbg --enc_info)
    . /opt/wz_mini/wz_mini.conf
    exit_status=0
    for i in 0 1; do
        rcMode=$(echo "$output" | grep -A 32 "CHANNEL $i" | grep "rcMode" | awk -F '[=()]' '{print $2}' | xargs)
        uTargetBitRate=$(echo "$output" | grep -A 32 "CHANNEL $i" | grep "uTargetBitRate" | awk -F '[=()]' '{print $2}' | xargs)
        uMaxBitRate=$(echo "$output" | grep -A 32 "CHANNEL $i" | grep "uMaxBitRate" | awk -F '[=()]' '{print $2}' | xargs)
        echo "Channel $i: rcMode=$rcMode, uTargetBitRate=$uTargetBitRate, uMaxBitRate=$uMaxBitRate"
        eval desired_rcMode=\$VIDEO_${i}_ENC_PARAMETER
        eval desired_uTargetBitRate=\$VIDEO_${i}_TARGET_BITRATE
        eval desired_uMaxBitRate=\$VIDEO_${i}_MAX_BITRATE
        if [ "$rcMode" != "$desired_rcMode" ]; then
            echo "Channel $i: rcMode is different from desired value ($desired_rcMode)"
            exit_status=1
        fi
        if [ "$uTargetBitRate" != "$desired_uTargetBitRate" ]; then
            echo "Channel $i: uTargetBitRate is different from desired value ($desired_uTargetBitRate)"
            exit_status=1
        fi
        if [ "$uMaxBitRate" != "$desired_uMaxBitRate" ]; then
            echo "Channel $i: uMaxBitRate is different from desired value ($desired_uMaxBitRate)"
            exit_status=1
        fi
    done
    return $exit_status
}

set_values() {
    . /opt/wz_mini/wz_mini.conf
    output=$(impdbg --enc_info)
    change_flag=0
    for i in 0 1; do
        rcMode=$(echo "$output" | grep -A 32 "CHANNEL $i" | grep "rcMode" | awk -F '[=()]' '{print $2}' | xargs)
        uTargetBitRate=$(echo "$output" | grep -A 32 "CHANNEL $i" | grep "uTargetBitRate" | awk -F '[=()]' '{print $2}' | xargs)
        uMaxBitRate=$(echo "$output" | grep -A 32 "CHANNEL $i" | grep "uMaxBitRate" | awk -F '[=()]' '{print $2}' | xargs)

        eval desired_rcMode=\$VIDEO_${i}_ENC_PARAMETER
        eval desired_uTargetBitRate=\$VIDEO_${i}_TARGET_BITRATE
        eval desired_uMaxBitRate=\$VIDEO_${i}_MAX_BITRATE

        if [ "$rcMode" != "$desired_rcMode" ]; then
            impdbg --enc_rc_s ${i}:44:4:$desired_rcMode
            sleep 3
            change_flag=1
        fi
        if [ "$uTargetBitRate" != "$desired_uTargetBitRate" ]; then
            impdbg --enc_rc_s ${i}:48:4:$desired_uTargetBitRate
            sleep 3
            change_flag=1
        fi
        if [ "$uMaxBitRate" != "$desired_uMaxBitRate" ]; then
            impdbg --enc_rc_s ${i}:52:4:$desired_uMaxBitRate
            sleep 3
            change_flag=1
        fi
    done
    if [ $change_flag -eq 0 ]; then
        echo "No changes needed."
    fi
}


stop_daemon() {
    if [ -e "$LOCKFILE" ]; then
        old_pid=$(head -n 1 "$LOCKFILE")
        if kill -0 $old_pid >/dev/null 2>&1; then
            kill -9 $old_pid
            rm -f "$LOCKFILE"
            echo "Daemon with PID $old_pid stopped."
        else
            echo "No running daemon found."
        fi
    else
        echo "No running daemon found."
    fi
}

daemon_loop() {
    echo $$ > "$LOCKFILE"
    echo "Starting daemon with PID $$"

    while true; do
        echo $(date)
        echo "Checking values..."
        check
        if [ $? -eq 1 ]; then
            echo $(date)
            echo "Setting values..."
            set_values
        fi
        sleep $INTERVAL
    done
}

daemon() {
    if [ -e "$LOCKFILE" ]; then
        old_pid=$(head -n 1 "$LOCKFILE")
        if kill -0 $old_pid >/dev/null 2>&1; then
            echo "Daemon is already running with PID $old_pid"
            exit 0
        else
            rm -f "$LOCKFILE"
        fi
    fi

    /opt/wz_mini/tmp/.bin/nohup /opt/wz_mini/bin/bash "$SCRIPT_PATH" --daemon-loop > "$LOGFILE" 2>&1 & disown
    exit 0
}

if [ "$1" = "--check" ]; then
    check
elif [ "$1" = "--set" ]; then
    set_values
elif [ "$1" = "--daemon" ]; then
    daemon 
elif [ "$1" = "--daemon-loop" ]; then
    daemon_loop
elif [ "$1" = "--stop" ]; then
    stop_daemon
else 
    echo "Usage: $0 [--check|--set|--daemon|--stop]"
fi
