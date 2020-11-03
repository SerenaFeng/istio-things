#!/bin/bash

op=${1:-a}

cd ../samples
k l ns default istio-injection=enabled --overwrite || true
k ${op} sleep/sleep.yaml

sleep 1
if [[ $op == a ]]; then
  while true; do
    ready=$(k g po | grep sleep | awk '{print $2}')
    st=$(k g po | grep sleep | awk '{print $3}')
    ok=$(cut -d '/' -f1 <<< $ready)
    total=$(cut -d '/' -f2 <<< $ready)
    if [[ $ok == $total ]]; then 
      break
    fi
    [[ $st != $ost || $ready != $oready ]] && k g po
    ost=$st
    oready=$ready
    sleep 1
  done	
else
  while true; do
    ready=$(k g po | grep sleep | awk '{print $2}')
    num=$(k g po | grep sleep | wc -l)
    if [[ $num == 0 ]]; then
      break
    fi
    [[ $ready != $oready ]] && k g po
    oready=$ready
    sleep 1
  done
fi
# k g po -w
