#!/bin/bash
# Created 20160504 by eeemil
# MIT License, no warranty, if this blows stuff up: blame yourself
# He he he

if [[ ! `whoami` == "root" ]]; then
    echo "Lol, you are not root!"
    echo "You have to be root"
    exit 1
fi
echo -n "Enter username: "
read USERNAME
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]')
if [[ "$USERNAME" =~ [^a-z0-9] ]]; then
    echo "Invalid username"
    exit 2
fi

# Already exists?
getent passwd "$USERNAME" >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "User already exists!"
    exit 2
fi

echo -n "Enter full name: "
read FULLNAME
if [[ "$FULLNAME" =~ [^\ a-zA-Z] ]]; then
    echo "Invalid name"
    exit 2
fi

PASSWORD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo`
HOSTS="osthyvel diskborste"
HOSTS=$(echo $HOSTS | sed "s/\<`hostname`\>//g")
echo $HOSTS

echo "Creating user on local machine..."
# Creating user...
useradd -m "$USERNAME" >/dev/null
chfn -f \""$FULLNAME"\" "$USERNAME" >/dev/null
# Zsh: default shell
chsh -s "/usr/bin/zsh" "$USERNAME" >/dev/null
passwd "$USERNAME" >/dev/null 2>&1 <<EOF
$PASSWORD
$PASSWORD
EOF

# Add to sudoers
usermod -aG sudo "$USERNAME" >/dev/null

# Populate home with neat stuff
echo "Configuring, setting up ssh key..."
## SSH key (will enable roaming across computorz in project room)
sudo -u "$USERNAME" ssh-keygen -N "" -t rsa -b 4096 -f "/home/$USERNAME/.ssh/id_rsa" -C "automatically generated by eeemil's script createUser.sh" >/dev/null
sudo -u "$USERNAME" cp "/home/$USERNAME/.ssh/id_rsa.pub" "/home/$USERNAME/.ssh/authorized_keys" >/dev/null

## ZSH-config

sudo -u "$USERNAME" cp "/etc/zsh/newuser.zshrc.recommended" "/home/$USERNAME/.zshrc" >/dev/null

## Todo: a git config, perhaps?

echo -e "Done, cloning user to other hosts\n"

for HOSTNAME in ${HOSTS} ; do
    echo "Adding $USERNAME on $HOSTNAME"
    ssh "$HOSTNAME" getent passwd "$USERNAME" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
	echo "User already exists! Skipping..."
	continue
    fi
    ssh ${HOSTNAME} useradd -m "$USERNAME" >/dev/null
    ssh ${HOSTNAME} chfn -f \""$FULLNAME"\" "$USERNAME" >/dev/null
    ssh ${HOSTNAME} chsh -s "/usr/bin/zsh" "$USERNAME" >/dev/null
    ssh ${HOSTNAME} passwd "$USERNAME" >/dev/null 2>&1 <<EOF
$PASSWORD
$PASSWORD
EOF
    ssh ${HOSTNAME} usermod -aG sudo "$USERNAME"
    echo "Copying files, setting up ssh keys..."
    rsync -rp "/home/$USERNAME" "${HOSTNAME}:/home/" >/dev/null
    ssh ${HOSTNAME} chown -R "$USERNAME:$USERNAME" "/home/$USERNAME" >/dev/null
    echo -e "$USERNAME added on $HOSTNAME!\n---------"
done

echo -e "\n\n========SUMMARY========="
echo -e "Username: $USERNAME"
echo -e "Password: $PASSWORD"
echo -e "User created on the following hosts:"
echo -e `hostname` "$HOSTS"
