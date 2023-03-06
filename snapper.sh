#!/bin/bash
ROFI_CONFIG=$HOME/snapper-rofi/configs/snapper.rasi
ROFI_CONFIG_ARG=$HOME/snapper-rofi/configs/

menu() {
	if [[ $# -gt 1 ]]; then
		rofi -config "$ROFI_CONFIG_ARG""$1.rasi" -dmenu -p "  $2"
	else
		rofi -config "$ROFI_CONFIG" -dmenu -p "  $1"
	fi
}

init_menu() {
	local options
	options="List snapshots\nDelete snapshot\nCreate snapshot"
	printf "%b" "$options" | menu "Snapshots"
}

list_snapshots() {
	snapper ls | sed -e '1,2d' | menu "list" "Snapshots overview"
}

create_menu() {
	local options
	options="Number snapshot\nTimeline snapshot\nPre snapshot\nPost snapshot"
	printf "%b" "$options" | menu "Create snapshot"
}

create_snapshot() {
	for value in "$@"; do
		if [[ $value == "number" ]]; then
			DESC=$(menu "desc" "Add number description")
			snapper -c root create -c number --description "$DESC"
		elif [[ $value == "timeline" ]]; then
			DESC=$(menu "desc" "Add timeline description")
			snapper -c root create -c timeline --description "$DESC"
		elif [[ $value == "pre" ]]; then
			DESC=$(menu "desc" "Add pre description")
			snapper -c root create -t pre -p --description "$DESC"
		elif [[ $value == "post" ]]; then
			DESC=$(menu "desc" "Add post description")2 >/dev/null
			NUM=$(snapper ls | sed -n \$p | awk '{print $1}')
			snapper -c root create -t post --pre-number "$NUM" --description "$DESC"
		fi
	done
}

delete_snapshot() {
	DELETE=$(snapper ls | sed -e '1,2d' | menu "list" "Delete snapshot" | awk '{print $1}')
	snapper -c root delete --sync "$DELETE"
}

main() {
	case "$(init_menu)" in
	"List snapshots")
		list_snapshots
		main
		;;
	"Create snapshot")
		case "$(create_menu)" in
		"Number snapshot")
			create_snapshot number
			;;
		"Timeline snapshot")
			create_snapshot timeline
			;;
		"Pre snapshot")
			create_snapshot pre
			;;
		"Post snapshot")
			create_snapshot post
			;;
		esac
		main
		;;
	"Delete snapshot")
		delete_snapshot
		main
		;;
	esac
}

main
