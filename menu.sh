#!/bin/bash

show_menu() {
    # local keys=("$@")
    local selected=0

    # Find the index of the menu_selected item if it exists
    local preselected_index=-1
    if [[ -n "$menu_selected" ]]; then
        for i in "${!menu_options[@]}"; do
            if [[ "${menu_options[$i]}" == "$menu_selected" ]]; then
                preselected_index=$i
                break
            fi
        done
    fi

    while true; do
        # Clear the screen
        echo -en "\033[H\033[J"

        echo "Select an option using arrow keys:"
        for i in "${!menu_options[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                # Current option
                echo -e " \033[1;32m-> ${menu_options[$i]}\033[0m"
            elif [ "$i" -eq "$preselected_index" ]; then
                # Previously selected option
                echo -e " \033[1;33m * ${menu_options[$i]}\033[0m"
            else
                # Other options
                echo "    ${menu_options[$i]}"
            fi
        done

        # Read input
        read -rsn1 input
        case "$input" in
            $'\x1b')  # Detect ESC sequences
                read -rsn2 -t 0.1 input
                case "$input" in
                    '[A')  # Up arrow
                        selected=$(( (selected - 1 + ${#menu_options[@]}) % ${#menu_options[@]} ))
                        ;;
                    '[B')  # Down arrow
                        selected=$(( (selected + 1) % ${#menu_options[@]} ))
                        ;;
                esac
                ;;
            '')  # Enter key
                menu_selected="${menu_options[$selected]}"  # Update the global variable
                return
                ;;
        esac
    done
}
