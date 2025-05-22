#!/bin/bash

# Define directory names for storing goals, users, and logs
GOALS_DIR="goals"
USERS_DIR="users"
LOGS_DIR="logs"

# Create the directories if they don't already exist
mkdir -p $GOALS_DIR $USERS_DIR $LOGS_DIR

# ============================================
# Firstly: User Management System
# ============================================

# Function to create a new user account
function create_account() {
    # Prompt the user to choose a username
    read -p "Choose a username: " username
    userfile="$USERS_DIR/$username.user"
    
    # Check if the username already exists
    if [ -f "$userfile" ]; then
        echo "Account already exists. Try logging in."
        return 1
    fi

    # Prompt the user to set a password
    read -p "Set a password: " pass

    # Save the password into the user file
    echo "$pass" > "$userfile"

    echo "Account created successfully!"
    
    # Store the username in a variable for session use
    USERNAME="$username"
    return 0
}

# Function to log in with an existing account
function login() {
    # Prompt the user to enter their username
    read -p "Enter your username: " username
    userfile="$USERS_DIR/$username.user"

    # Check if the user file exists
    if [ ! -f "$userfile" ]; then
        echo "Account does not exist. Please create one."
        return 1
    fi

    # Prompt the user to enter their password
    read -p "Enter your password: " pass

    # Read the saved password from the file
    saved_pass=$(cat "$userfile")

    # Compare entered password with saved password
    if [ "$pass" != "$saved_pass" ]; then
        echo "Incorrect password."
        return 1
    fi

    # If password is correct, set the session username
    USERNAME="$username"
    echo "Login successful. Welcome, $USERNAME!"
    return 0
}
