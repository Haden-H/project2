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
#Function to create and save a new financial goal
function enter_new_goal() {
# the user will enter the name of the goal
read -p "Enter goal name :" goal
# the user will enter the target amount in saudi riyals
read -p "Enter target amount(SAR)" amount
# the user will adjust the importance level (1 to 5) of the target
read -p "Enter importance (where 1 is very high and 5 is low):" importance
#save a goal data to a format amount;save;date;importance
#for a new goal,saved=0, and date is todays date
echo "$amount;0;$(date+%F);$importance"> "$GOALS_DIR/${USERNAME}_$goal.txt"
#confirmation  messages
echo "GOAL[$goal] with target $amount SAR created"
}
#function to delete an existing goal
function delete_goal() {
#display a list of current goals
echo "Your current goals:"
for file in $GOALS_DIR/${USERNAME}_*.txt ; do
#extract the goal name from  the file name
goal=$(basename "$file" | sed "s/^${USERNAME}_//;s/.txt$//")
#read the goal data from the file : amount;saved;date;importance
IFS=';' read -r GOAL_AMOUNT SAVED_AMOUNT _IMPORTANCE < "$file"
#determine the goal status based on saved amount
status = "Not Finished"
["$SAVED_AMOUNT" -ge "$GOAL_AMOUNT"] && status="Finished"
# print the goal name with its status
echo "-$goal [$status]"
done
# Ask the user which goal the wanna delete
read -p "Enter the goal name to delete:" goal
#delete the goal file and its corresponding log file
rm -f "$GOALS_DIR/${USERNAME}_$goal.txt"
"$LOGS_DIR/${USERNAME}_$goal.log"
#confirmation message
echo "Goal [$goal] deleted"
}

