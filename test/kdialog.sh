#!/bin/bash

dbusRef=$(kdialog --progressbar "Initializing" 100)
qdbus $dbusRef Set "" value 1
qdbus $dbusRef setLabelText "Thinking really hard"
sleep 2
qdbus $dbusRef Set "" value 25
sleep 2
qdbus $dbusRef setLabelText "Thinking some more"
qdbus $dbusRef Set "" value 76
sleep 2
qdbus $dbusRef Set "" value 100
sleep 2
qdbus $dbusRef close
