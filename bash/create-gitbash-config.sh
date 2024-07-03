#!/bin/bash

# Define the key bindings
KEY_BINDINGS="Ctrl+Shift+C:copy;Ctrl+Shift+V:paste"

# Check if .minttyrc exists, if not create it
if [ ! -f ~/.minttyrc ]; then
  touch ~/.minttyrc
fi

# Add the key bindings to the .minttyrc file
echo "KeyFunctions=$KEY_BINDINGS" >~/.minttyrc

# Inform the user
echo "Custom key bindings for copy and paste have been set in ~/.minttyrc"

# Restart mintty to apply changes
pkill mintty
