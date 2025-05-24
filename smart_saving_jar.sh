#!/bin/bash

# Define directory names for storing goals, users, and logs
GOALS_DIR="goals"
USERS_DIR="users"
LOGS_DIR="logs"

# Create the directories if they don't already exist
mkdir -p $GOALS_DIR $USERS_DIR $LOGS_DIR

# ==============================================================================
# Firstly: User Management System
# ==============================================================================

# Function to create a new user account
function create_account() {
    while true; do
        # Prompt the user to choose a username
        read -p "Choose a username: " username
        userfile="$USERS_DIR/$username.user"

        # Check if the username already exists
        if [ -f "$userfile" ]; then
            echo "Account already exists. Try logging in or choose another username."
            return 1  # Return to main menu without exiting script
        fi

        # Prompt the user to set a password
        read -p "Set a password: " pass

        # Check if the password is at least 8 characters long
        if [ ${#pass} -lt 8 ]; then
            echo "Password must be at least 8 characters long."
            continue
        fi

        # Check for at least one letter in the password
        if ! [[ "$pass" =~ [A-Za-z] ]]; then
            echo "Password must contain at least one letter."
            continue
        fi

        # Check for at least one number in the password
        if ! [[ "$pass" =~ [0-9] ]]; then
            echo "Password must contain at least one number."
            continue
        fi

        # Save the password into the user file
        echo "$pass" > "$userfile"

        echo "Account created successfully!"

        # Store the username in a variable for session use
        USERNAME="$username"
        return 0
    done
}

# Function to log in an existing user
function login() {
    while true; do
        # Prompt the user to enter their username
        read -p "Enter your username: " username
        userfile="$USERS_DIR/$username.user"

        # Check if the account exists
        if [ ! -f "$userfile" ]; then
            echo "Incorrect username or password. Please try again."
            continue
        fi

        # Prompt the user to enter their password
        read -p "Enter your password: " pass
        saved_pass=$(cat "$userfile")

        # Check if the password matches the saved one
        if [ "$pass" != "$saved_pass" ]; then
            echo "Incorrect username or password. Please try again."
            continue
        fi

        # Check if the password is at least 8 characters long
        if [ ${#pass} -lt 8 ]; then
            echo "Password must be at least 8 characters long."
            continue
        fi

        # Check for at least one letter in the password
        if ! [[ "$pass" =~ [A-Za-z] ]]; then
            echo "Password must contain at least one letter."
            continue
        fi

        # Check for at least one number in the password
        if ! [[ "$pass" =~ [0-9] ]]; then
            echo "Password must contain at least one number."
            continue
        fi

        # If all checks pass, log the user in
        USERNAME="$username"
        echo "Login successful. Welcome, $USERNAME!"
        return 0
    done
}

# ==============================================================================
# Secondly: Goal Management
# ==============================================================================

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
echo "$amount;0;$(date +%F);$importance" > "$GOALS_DIR/${USERNAME}_$goal.txt"
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
status="Not Finished"
if [ "$SAVED_AMOUNT" -ge "$GOAL_AMOUNT" ]; then
   status="Finished"
fi 
# print the goal name with its status
echo "-$goal [$status]"
done
# Ask the user which goal the wanna delete
read -p "Enter the goal name to delete:" goal
#delete the goal file and its corresponding log file
rm -f "$GOALS_DIR/${USERNAME}_$goal.txt" "$LOGS_DIR/${USERNAME}_$goal.log"
#check if the goal file exists
if [ ! -f "$goal_file"]; then
  echo " Goal [$goal] not found"
  return
fi
# Ask confirmation
read -p " Are you sure you want to delete the goal [$goal] ? (yes/no):" confirm
case "$confirm" in
  [Yy][Ee][Ss]|[Yy])
   rm -f "$goal_file" "$log_file"
   echo "Goal [$goal] deleted"
   ;;
  *)
  echo "Deletion canceled"
  ;;
esac
}

# ==============================================================================
# Thirdly: Daily Operations and Alerts
# ==============================================================================

# Function to add a new saving amount to an existing goal
function add_saving_to_goal {
echo "Your current goals:"

# List all goals for the current user
ls "$GOALS_DIR" | grep "^${USERNAME}_" | sed "s/^${USERNAME}_//;s/.txt$//"
read -p "Which goal do you want to update? " goal
goal_file="$GOALS_DIR/${USERNAME}_${goal}.txt"

# Check if goal file exists
if [ ! -f "$goal_file" ]; then
   echo "Goal not found."
   return
fi

# Read current goal data from file
IFS=';' read -r GOAL_AMOUNT SAVED_AMOUNT LAST_DATE IMPORTANCE < "$goal_file"

# Ask user for today's saved amount
read -p "Enter amount saved today: " add

# Update saved amount and last update date
SAVED_AMOUNT=$((SAVED_AMOUNT + add))
LAST_DATE=$(date +%F)

# Save updated goal info back to the file
echo "$GOAL_AMOUNT;$SAVED_AMOUNT;$LAST_DATE;$IMPORTANCE" > "$goal_file"

# Calculate remaining amount
remaining=$((GOAL_AMOUNT - SAVED_AMOUNT))
# Display savings summary
echo "You saved $SAVED_AMOUNT SAR. Remaining: $remaining SAR."

# Append log entry
echo "$(date +%F), $add" >> "$LOGS_DIR/${USERNAME}_${goal}.log"

# Notify user of progress
if [ $remaining -le 0 ]; then
   echo "You have reached your goal [$goal]!"
    elif [ $remaining -le $((GOAL_AMOUNT / 10)) ]; then
    echo "You're very close to your goal [$goal]!"
    fi
}

# Function to edit an existing savings goal
function edit_goal {
echo "Your current goals:"
# Loop through user's goal files and list them
for file in "$GOALS_DIR/${USERNAME}"_*.txt; do
goal=$(basename "$file" | sed "s/^${USERNAME}_//;s/.txt$//")
IFS=';' read -r GOAL_AMOUNT SAVED_AMOUNT LAST_DATE IMPORTANCE < "$file"
echo "- $goal (Target: $GOAL_AMOUNT, Saved: $SAVED_AMOUNT, Importance: $IMPORTANCE)"
done

# Prompt the user to enter the goal they want to edit
read -p "Enter the goal name you want to edit: " goal
goal_file="$GOALS_DIR/${USERNAME}_$goal.txt"

# Check if the goal file exists
if [ ! -f "$goal_file" ]; then
   echo " Goal [$goal] not found."
   return
   fi

# Read the current goal data
IFS=';' read -r GOAL_AMOUNT SAVED_AMOUNT LAST_DATE IMPORTANCE < "$goal_file"

# Present editing options to the user
echo "What would you like to edit?"
echo "1) Change goal name"
echo "2) Change target amount"
echo "3) Change importance level"
read -p "Choose an option (1-3): " edit_opt

case "$edit_opt" in
       1)
            # Rename the goal file and log file if needed
            read -p "Enter the new goal name: " new_name
            new_file="$GOALS_DIR/${USERNAME}_$new_name.txt"
            new_log="$LOGS_DIR/${USERNAME}_$new_name.log"
            mv "$goal_file" "$new_file"
            mv "$LOGS_DIR/${USERNAME}_$goal.log" "$new_log" 2>/dev/null
            echo " Goal name updated to [$new_name]."
            ;;
        2)
            # Update the target amount
            read -p "Enter the new target amount: " new_amount
            echo "$new_amount;$SAVED_AMOUNT;$LAST_DATE;$IMPORTANCE" > "$goal_file"
            echo " Target amount updated to $new_amount."
            ;;
        3)
            # Update the importance level
            read -p "Enter the new importance (e.g. high, medium, low): " new_importance
            echo "$GOAL_AMOUNT;$SAVED_AMOUNT;$LAST_DATE;$new_importance" > "$goal_file"
            echo " Importance updated to [$new_importance]."
            ;;
        *)
            # Handle invalid input
            echo " Invalid choice. No changes made."
            ;;
    esac
}

# Function to check if user hasn't saved for any goal in the last 3 days
function check_inactivity_alerts {
for file in "$GOALS_DIR/${USERNAME}"_*.txt; do
goal=$(basename "$file" | sed "s/^${USERNAME}_//;s/.txt$//")
# Extract the last date from the goal file
IFS=';' read -r _ _ last_date _ < "$file"

# Calculate number of days since last update
days_since=$(( ( $(date +%s) - $(date -d "$last_date" +%s) ) / 86400 ))

if [ $days_since -ge 3 ]; then
     echo "Reminder: You haven't saved for goal [$goal] in $days_since days."
fi
done
}

# ==============================================================================
# Fourthly: Analysis and Smart Planning
# ==============================================================================

#this function ask the user to choose a period(week/month/year)
# and calculate how much saved during that period
function total_savings_in_period() {
echo "Select period: "
echo "1- Week"
echo "2- Month"
echo "3- Year"
read -p "Please enter your period in words only, Your choice: " choice
# determine the start date depending on the chosen period
case $choice in
week) since=$(date -d "-7 days" +%F) ;;
month) since=$(date -d "-30 days" +%F) ;;
year) since=$(date -d "-365 days" +%F) ;;
*) echo "Invalid period" ; return ;;
esac
total=0
# loop over all (log) fiels for this user
for file in $LOGS_DIR/${USERNAME}_*.log; do
while IFS=' , ' read -r date amount; do
# if the date is after the  start date then add the amount to total
if [[ "$date" > "$since" ]]; then
total=$((total + amount))
fi
done < "$file"
done
echo "Total saved in the last $period: $total SAR"
 }
# this function help the user to creat a saving plane
# by calculating how much to save monthly to reach a goal
function suggest_saving_plan() {
read -p "Enter your monthly income (SAR): " incom
read -p "Enter your saving percentage (for example: 20 for 20%): " percent
read -p "Enter the goal amount: " goal_amount
monthly_saving=$((incom * percent / 100))
# check if the result is 0 (invalid input)
if [ $monthly_saving -eq 0 ]; then
echo "The calculated saving per month is 0. please adjust your input."
return
fi
# calculate how many months it would take to reach the goal
month=$((goal_amount / monthly_saving))
echo "Suggested plan: Save $monthly_saving SAR/month to reach your goal of $goal_amount SAR in approximately $months months."
 }

# ==============================================================================
# Finally: Main Menu and Execution
# ==============================================================================

# Declares the main menu
function main_menu() {
#starts an infinite loop the menu will keep showing untill the user chooses exit
while true; do
#calls a function (checks if the user has been inactive for a while and shows an alert
  check_inactivity_alerts
# echo statements to display the menu to the user
  echo "\n --- Main Menu ---"
  echo "1) Enter new saving goal"
  echo "2) Add saving to existing goal"
  echo "3) edit an existing savings goal"
  echo "4) View total saving in a period"
  echo "5) Delete a goal"
  echo "6) Suggest saving a plan"
  echo "7) Exit"
#prompts the user to choose one of the menu options storing their input in the variable opt
read -p "Choose an option" opt
case $opt in
    # If user selects option 1: call function to enter a new goal
    1) enter_new_goal ;;

    # If user selects option 2: call function to add saving to an existing goal
    2) add_saving_to_goal ;;

    # If user selects option 3: call function to edit an existing savings goal
    3) edit_goal ;;

    # If user selects option 4: call function to view total savings in a specific period
    4) total_savings_in_period ;;

    # If user selects option 5: call function to delete a goal
    5) delete_goal ;;

    # If user selects option 6: suggest a saving plan or show all goals with status
    6) suggest_saving_plan ;;

    # If user selects option 7: exit the program with a farewell message
    7) echo "Thank you for using Smart Saving Jar. Keep saving!" ; break ;;

    # If the input does not match any valid option
    *) echo "Invalid option." ;;
esac
done 
}

# System login
clear
echo "Welcome to Smart Saving Jar System"

# Loop until the user successfully logs in, creates an account, or exits
while true; do
    # Display the login menu options
    echo ""
    echo "Thank you for using Smart Saving Jar. Keep saving!"
    echo "1) Login"
    echo "2) Create Account"
    echo "3) Exit"

    # Prompt the user to choose an option
    read -p "Choose: " choice

    case $choice in
        1)
            # If login is successful, go to the main menu
            if login; then
                main_menu
                break
            fi
            # If login fails, the loop will continue
            ;;
        2)
            # If account creation is successful, go to the main menu
            if create_account; then
                main_menu
                break
            fi
            # If account creation fails, the loop will continue
            ;;
        3)
            # Exit the program completely
            echo "Exiting... Goodbye!"
            exit 0
            ;;
        *)
            # If the user enters an invalid option
            echo "Invalid choice. Please try again."
            ;;
    esac
done

