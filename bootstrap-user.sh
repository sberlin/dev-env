#!/bin/bash

# Required variables
test -z "$USERNAME" && exit

# User specific settings
echo "Create user $USERNAME with groups"
adduser --disabled-login --gecos "$USERNAME,,," --home /home/$USERNAME --shell /bin/bash $USERNAME
id --groups --name vagrant | tr ' ' '\n' | tail -n +2 | xargs -I{} adduser $USERNAME {}
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_$USERNAME
chmod 440 /etc/sudoers.d/99_$USERNAME

# Create workspace
mkdir -p /opt/workspace/$USERNAME/git /home/$USERNAME/.config/autostart
ln -fs /opt/workspace/$USERNAME/git /home/$USERNAME/git

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
exec 2&>1 /home/$USERNAME/setup-user.log

echo "Install configurations from archive"
if [ -n "$USERTOOLS" ]
then
    pushd . 2&>1 /dev/null
    mkdir -p /tmp/vagrant-bootstrap
    cd /tmp/vagrant-bootstrap
    curl -o tools.zip -fsSL "$USERTOOLS" && \
        unzip -o tools.zip && \
        pushd . 2&>1 /dev/null && \
        cd $(zipinfo -1 tools.zip | head -1) && \
        make install && \
        popd 2&>1 /dev/null
    popd 2&>1 /dev/null
    rm -rf /tmp/vagrant-bootstrap
fi

echo "Set user info for Git"
git config --global user.name $USERNAME
git config --global user.email $USERMAIL

if [ "$GUI" == "true" ]
then
    echo "Set GUI configurations"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 9'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'
    gsettings set org.gnome.desktop.interface font-name 'Ubuntu 10'
    gsettings set org.gnome.desktop.interface document-font-name 'Sans 10'
    gsettings set com.canonical.Unity.Launcher favorites "['application://org.gnome.Nautilus.desktop', 'application://firefox.desktop', 'application://org.gnome.gedit.desktop', 'application://org.gnome.Terminal.desktop', 'unity://running-apps', 'application://unity-control-center.desktop', 'application://unity-tweak-tool.desktop', 'unity://expo-icon', 'unity://devices']"
fi

echo "Remove setup scripts"
rm "/home/$USERNAME/.config/autostart/setup-user.desktop"
rm "$0"
EOF

echo "Set permissions for setup files"
chmod +x /home/$USERNAME/.config/autostart/setup-user.desktop /home/$USERNAME/setup-user.sh
chown --recursive $USERNAME:$USERNAME /home/$USERNAME/

echo "Reset password"
echo "$USERNAME:${PASSWORD:-$USERNAME}" | chpasswd
