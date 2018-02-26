#!/usr/bin/env bash
tmux attach

if [ $? -ne 0 ]
then
    # dev
    tmux new-session -d -s dev \; \
        new-window -d -t dev \; \
        new-window -d -t dev \; \
        send-keys -t dev:1 'cd ~/git/' C-m \; \
        send-keys -t dev:2 'cd ~/git/' C-m \; \
        send-keys -t dev:3 'cd ~/git/' C-m

    # misc
    tmux new-session -d -s misc \; \
        new-window -d -t misc \; \
        new-window -d -t misc

    # server
    #tmux new-session -d -s server -n server-name \; \
    #    send-keys -t server:server-name 'ssh -t server-name "cd /opt/workspace; sudo su root"' C-m

    tmux attach-session -t dev
fi

