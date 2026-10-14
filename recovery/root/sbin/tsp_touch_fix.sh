#!/bin/sh
# Keep the Himax HX83112 touch controller alive in recovery.
#
# The controller is a zero-flash part: its firmware lives in the kernel and
# is uploaded over SPI every time the chip powers up. It shares power with
# the in-cell panel, so whenever TWRP blanks the display the firmware is
# gone and touch stays dead until the driver reloads it. On Android the
# display stack tells the driver about screen off/on through
# /sys/class/sec/tsp/enabled ("<display_state>,<event>"), which runs the
# driver's early/late suspend and resume hooks. TWRP never sends those, so
# this script does: once after the GUI is up, and on every power-key release
# depending on whether the panel is now off (brightness 0) or on.
#
# Fallback: if the enabled node is missing, use the sec_cmd fw_update, which
# also reloads the firmware (SavedByLight's original workaround).

TSP=/sys/class/sec/tsp
BL=/sys/class/backlight/panel/brightness

# display_state: 1 = OFF, 2 = ON; event: 0 = early, 1 = late
display_off() {
    if [ -w "$TSP/enabled" ]; then
        echo "1,0" > "$TSP/enabled"
        echo "1,1" > "$TSP/enabled"
    fi
}

# The driver skips a resume unless it saw a suspend first, so always run
# the full off/on cycle on wake. That makes the wake path self-contained:
# it also recovers a panel that was blanked before this script started.
display_on() {
    if [ -w "$TSP/enabled" ]; then
        display_off
        echo "2,0" > "$TSP/enabled"
        # late resume reloads the firmware; give the panel time to come up
        sleep 1
        echo "2,1" > "$TSP/enabled"
    else
        echo fw_update > "$TSP/cmd"
    fi
}

# Power key comes from the MediaTek keypad device; find it by name instead
# of trusting the event number.
KEYDEV=""
for d in /sys/class/input/event*; do
    if [ "$(cat "$d/device/name" 2>/dev/null)" = "mtk-kpd" ]; then
        KEYDEV="/dev/input/$(basename "$d")"
        break
    fi
done
[ -n "$KEYDEV" ] || KEYDEV=/dev/input/event2

# Wait for the GUI to turn the panel on, then make sure the controller has
# firmware. (The panel may have been power-cycled since the driver probed.)
n=0
while [ "$(cat "$BL" 2>/dev/null)" = "0" ] && [ $n -lt 100 ]; do
    sleep 0.2
    n=$((n + 1))
done
sleep 0.5
display_on

getevent -l "$KEYDEV" | while read -r line; do
    case "$line" in
        *KEY_POWER*UP*)
            sleep 0.4
            if [ "$(cat "$BL" 2>/dev/null)" = "0" ]; then
                display_off
            else
                display_on
            fi
            ;;
    esac
done
