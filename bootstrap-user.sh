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

echo "Install configurations from archive"
if [ -n "$USERTOOLS" ]
then
    pushd . &> /dev/null
    mkdir -p /tmp/vagrant-bootstrap
    cd /tmp/vagrant-bootstrap
    curl --output tools.zip --fail --show-error --location "$USERTOOLS" && \
        unzip -o tools.zip && \
        pushd . &> /dev/null && \
        cd */ && \
        make install && \
        popd &> /dev/null
    popd &> /dev/null
    rm -rf /tmp/vagrant-bootstrap
fi

echo "Remove setup scripts"
rm "/home/$USERNAME/.config/autostart/setup-user.desktop"
rm "$0"
EOF

echo "Set permissions for setup files"
chmod +x /home/$USERNAME/.config/autostart/setup-user.desktop /home/$USERNAME/setup-user.sh
chown --recursive $USERNAME:$USERNAME /home/$USERNAME/

echo "Set predefined password"
echo "$USERNAME:${PASSWORD:-$USERNAME}" | chpasswd
