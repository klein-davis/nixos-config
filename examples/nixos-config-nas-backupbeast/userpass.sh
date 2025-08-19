#!/bin/bash

selection=-1
while [ $selection -ne 0 ]; do
  echo "Chose an option:"
  echo "(1) Add a password to a user"
  echo "(2) Change a password"
  echo "(3) Remove a password"
  echo "(0) Exit"
  read -p "Selection: " selection
  if [ $selection -eq 1 ]; then
    read -p "Username: " name
    sudo smbpasswd -a $name
  fi

  if [ $selection -eq 2 ]; then
    read -p "Username: " name
    sudo smbpasswd $name
  fi

  if [ $selection -eq 3 ]; then
    read -p "Username: " name
    sudo smbpasswd -x $name
  fi


done
