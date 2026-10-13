#!/bin/sh
# The sec_ts touchscreen on a13ve stops reporting after the panel was
# switched off once. Re-run the firmware update command (which resets the
# controller) every time the power key is released.

fix() {
    echo fw_update > /sys/class/sec/tsp/cmd
    result=$(cat /sys/class/sec/tsp/cmd_result 2>/dev/null)
    case "$result" in
        *OK*) ;;
        *)
            echo incell_power_control,0 > /sys/class/sec/tsp/cmd
            echo incell_power_control,1 > /sys/class/sec/tsp/cmd
            echo fw_update > /sys/class/sec/tsp/cmd
            ;;
    esac
}

sleep 3

getevent -l /dev/input/event2 | while read line; do
    case "$line" in
        *KEY_POWER*UP*)
            sleep 0.3
            fix
            ;;
    esac
done
