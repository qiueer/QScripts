#!/bin/sh
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" ./ -R | grep -Ev 'route.txt|route01|*.log|Binary file'
