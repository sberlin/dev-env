#!/bin/bash

# Required variables
test -z "$USERNAME" && exit

# User specific settings
echo "Create user $USERNAME with groups"
adduser --disabled-login --gecos "$USERNAME,,," --home /home/$USERNAME --shell /bin/bash $USERNAME
id --groups --name vagrant | tr ' ' '\n' | tail --lines=+2 | xargs -I{} adduser $USERNAME {}
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_$USERNAME
chmod 440 /etc/sudoers.d/99_$USERNAME

# Create workspace
mkdir --parents /opt/workspace/$USERNAME/{git,opt} /home/$USERNAME/.config/autostart
ln --force --symbolic /opt/workspace/$USERNAME/git /home/$USERNAME/git

# Set permissions
chown --recursive $USERNAME:$USERNAME /home/$USERNAME /opt/workspace/$USERNAME /home/$USERNAME/.config/autostart

echo "Create shortcut for calling user setup once at /home/$USERNAME/.config/autostart/setup-user.desktop"
cat > /home/$USERNAME/.config/autostart/setup-user.desktop <<-EOF
[Desktop Entry]
Name=Setup-User
Type=Application
Exec=env "USERNAME=$USERNAME" env "USERTOOLS=$USERTOOLS" env "USERMAIL=$USERMAIL" env "GUI=$GUI" bash /home/$USERNAME/setup-user.sh
Terminal=false
EOF

echo "Create setup script at /home/$USERNAME/setup-user.sh"
cat > /home/$USERNAME/setup-user.sh <<-'EOF'
#!/bin/bash
exec &> /home/$USERNAME/setup-user.log

echo "Install configurations with user privileges"

if [ -n "$USERTOOLS" ]
then
    echo "Download configurations from $USERTOOLS"
    pushd . &> /dev/null
    mkdir --parents /tmp/vagrant-bootstrap
    cd /tmp/vagrant-bootstrap
    curl --output tools.zip --fail --show-error --location "$USERTOOLS" && \
        unzip -o tools.zip && \
        pushd . &> /dev/null && \
        cd */ && \
        make install && \
        popd &> /dev/null
    popd &> /dev/null
    rm --recursive --force /tmp/vagrant-bootstrap
fi

if [ $? -eq 0 ]
then
    echo "Removing setup scripts"
    rm --force "/home/$USERNAME/.config/autostart/setup-user.desktop"
    rm --force "$0"
else
    rm --force "/home/$USERNAME/.config/autostart/setup-user.desktop"
    echo "Removing setup script $0 skipped due to errors"
    echo "Please investigate and execute this script again"
fi
EOF

echo "Set permissions for setup files"
chmod +x /home/$USERNAME/.config/autostart/setup-user.desktop /home/$USERNAME/setup-user.sh
chown --recursive $USERNAME:$USERNAME /home/$USERNAME/

echo "Set predefined password"
echo "$USERNAME:${PASSWORD:-$USERNAME}" | chpasswd
