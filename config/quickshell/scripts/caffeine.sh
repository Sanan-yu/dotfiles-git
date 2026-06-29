#!/bin/env bash

if pidof hypridle; then
	killall hypridle
else
	hyprctl dispatch 'hl.dsp.exec_cmd("hypridle")'
fi
