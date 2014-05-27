# (WIP)


## Routes

- Generate a condensed routing table with following command:

    DOC='doc/Routes.md' && echo '|Name|Method|Route|Controller|' > $DOC && echo '|---|---|---|---|' >> $DOC && rake routes | tail -n +2 | grep 'GET' | grep -v 'app_admin' | sed -E 's/[ ]+/|/g' | sed -E 's/$/ |/' | sed -E 's/^\|GET/| |GET/' >> $DOC

