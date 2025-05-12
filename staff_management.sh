#!/bin/bash

# File paths
USER_FILE="/etc/restaurant_staff_users.txt"
LOGIN_FILE="/etc/restaurant_login.txt"

# Ensure login file exists
if [ ! -f "$LOGIN_FILE" ]; then
    echo "admin:admin123" > "$LOGIN_FILE"
    chmod 600 "$LOGIN_FILE"
    echo "Default admin login created: admin/admin123"
fi

# Login function
login() {
    USERNAME=$(whiptail --inputbox "Enter username:" 10 60 --title "Login" 3>&1 1>&2 2>&3) || exit
    PASSWORD=$(whiptail --passwordbox "Enter password:" 10 60 --title "Login" 3>&1 1>&2 2>&3) || exit

    if grep -q "^$USERNAME:$PASSWORD$" "$LOGIN_FILE"; then
        return 0
    else
        whiptail --msgbox "Invalid credentials. Access Denied." 8 45 --title "Login Failed"
        exit 1
    fi
}

# Ensure user file exists
if [ ! -f "$USER_FILE" ]; then
    touch "$USER_FILE"
    chmod 666 "$USER_FILE"
    echo "User file created: $USER_FILE"
fi

# Add user function
add_user() {
    NAME=$(whiptail --inputbox "Enter full name:" 10 60 --title "Add User" 3>&1 1>&2 2>&3) || return
    USERNAME=$(whiptail --inputbox "Enter username:" 10 60 --title "Add User" 3>&1 1>&2 2>&3) || return
    ROLE=$(whiptail --inputbox "Enter role (e.g., waiter, chef, manager):" 10 60 --title "Add User" 3>&1 1>&2 2>&3) || return

    if [ -z "$NAME" ] || [ -z "$USERNAME" ] || [ -z "$ROLE" ]; then
        whiptail --msgbox "All fields are required!" 8 45 --title "Error"
        return
    fi

    echo "$USERNAME:$NAME:$ROLE" >> "$USER_FILE"
    whiptail --msgbox "User $USERNAME added successfully!" 8 45 --title "Success"
}

# Edit user function
modify_user() {
    USERNAME=$(whiptail --inputbox "Enter username to edit:" 10 60 --title "Edit User" 3>&1 1>&2 2>&3) || return

    if grep -q "^$USERNAME:" "$USER_FILE"; then
        NEW_NAME=$(whiptail --inputbox "Enter new name:" 10 60 --title "Edit User" 3>&1 1>&2 2>&3) || return
        NEW_ROLE=$(whiptail --inputbox "Enter new role:" 10 60 --title "Edit User" 3>&1 1>&2 2>&3) || return
        sed -i "/^$USERNAME:/c\\$USERNAME:$NEW_NAME:$NEW_ROLE" "$USER_FILE"
        whiptail --msgbox "User $USERNAME updated successfully!" 8 45 --title "Success"
    else
        whiptail --msgbox "User $USERNAME does not exist!" 8 45 --title "Error"
    fi
}

# View users function
view_users() {
    if [ ! -s "$USER_FILE" ]; then
        whiptail --msgbox "No users found!" 8 45 --title "Error"
    else
        USERS=$(awk -F: '{printf "Username: %s\nName: %s\nRole: %s\n\n", $1, $2, $3}' "$USER_FILE")
        whiptail --msgbox "$USERS" 20 70 --title "Staff Members"
    fi
}

# Delete user function
remove_user() {
    USERNAME=$(whiptail --inputbox "Enter username to delete:" 10 60 --title "Delete User" 3>&1 1>&2 2>&3) || return

    if grep -q "^$USERNAME:" "$USER_FILE"; then
        sed -i "/^$USERNAME:/d" "$USER_FILE"
        whiptail --msgbox "User $USERNAME deleted successfully!" 8 45 --title "Success"
    else
        whiptail --msgbox "User $USERNAME not found!" 8 45 --title "Error"
    fi
}

# Run login first
login

# Main menu loop
while true; do
    CHOICE=$(whiptail --title "Restaurant Staff Management" --menu "Choose an option:" 15 60 6 \
        "1" "Add New Staff Member" \
        "2" "Remove Staff Member" \
        "3" "Modify Staff Member" \
        "4" "View Current Staff" \
        "5" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) add_user ;;
        2) remove_user ;;
        3) modify_user ;;
        4) view_users ;;
        5) break ;;
        *) whiptail --msgbox "Invalid option!" 8 45 --title "Error" ;;
    esac
done

exit 0
