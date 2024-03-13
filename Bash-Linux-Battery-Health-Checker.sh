#!/bin/bash

noColor="\e[0m"
yellow="\e[0;33m"
red="\e[0;31m"
green="\e[0;32m"

test_dir=ls /sys/class/power_supply 2> /dev/null | grep BAT*
test_upower=$(which upower &> /dev/null)
test_acpi=$(which acpi &> /dev/null)

dirFunction () {
	fullDesign=$(cat /sys/class/power_supply/BAT*/charge_full_design)
	fullCurrent=$(cat /sys/class/power_supply/BAT*/charge_full)
	cycleCount=$(cat /sys/class/power_supply/BAT*/cycle_count)
	capacity=$(( $fullCurrent * 100 / $fullDesign ))
	echo -e "The health of your battery is: ${green}"$capacity"${noColor}"
	echo -e "The cycles charge on your battery are: ${green}"$cycleCount"${noColor}"
}

upowerFunction () {
	battery=$(upower --enumerate | grep battery_BAT*)
	if [[ ! $battery ]]; then
		echo -e "${red}[!]${noColor}An error ocurred while selecting the battery"
		exit 1
	fi

	checkPresent=$(upower -i $battery | awk '{if ($1 == "present:"){print $2}}')

	if [[ ! $checkPresent == "yes" ]]; then
		echo -e "${red}[!]${noColor} Battery is not installed on the system"
		exit 1
	fi

	info=$(upower -i $battery | grep -E 'capacity|cycles')
	if [[ ! $info ]]; then
		echo -e "${red}[!]${noColor}An error ocurred while selecting the data fields"
	fi

	echo -e "The health of your battery is: ${green}"$(echo $info | awk '{print $4}')"${noColor}"
	echo -e "The cycles charge on your battery are: ${green}"$(echo $info | awk '{print $2}')"${noColor}"
}

acpiFunction () {
	infoAcpi=$(acpi -bi | grep %)
	if [[ ! $infoAcpi ]]; then
		echo -e "${red}[!]${noColor}An error ocurred while selecting the battery info"
		exit 1
	fi
	echo $infoAcpi | awk '{print "The health of your battery is: ""'$(echo -e "${green}")'"$NF"'$(echo -e "${noColor}")'"}'
}

if [[ ! $test_upower ]]; then
	upowerFunction
	exit
elif [[ ! $test_dir ]]; then
        dirFunction
        exit
elif [[ ! $test_acpi ]]; then
        acpiFunction
        exit
else
        echo -e "${red}[!]${noColor}There was an error running the script"
        exit 1
fi
