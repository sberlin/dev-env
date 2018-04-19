#!/usr/bin/env bash

if [ $# != 3 ]
then
    echo -e "I need\n  1) the wrong email address\n  2) the new author name\n  3) the new email address"
    exit 1
fi

git filter-branch --env-filter "
    WRONG_EMAIL=\"${1}\"
    NEW_NAME=\"${2}\"
    NEW_EMAIL=\"${3}\"

    if [ \"\$GIT_COMMITTER_EMAIL\" = \"\$WRONG_EMAIL\" ]
    then
        export GIT_COMMITTER_NAME=\"\$NEW_NAME\"
        export GIT_COMMITTER_EMAIL=\"\$NEW_EMAIL\"
    fi

    if [ \"\$GIT_AUTHOR_EMAIL\" = \"\$WRONG_EMAIL\" ]
    then
        export GIT_AUTHOR_NAME=\"\$NEW_NAME\"
        export GIT_AUTHOR_EMAIL=\"\$NEW_EMAIL\"
    fi " --tag-name-filter cat -- --branches --tags

