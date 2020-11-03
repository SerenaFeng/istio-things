#!/bin/bash

k g po -l app=sleep -o name | cut -f2 -d'/' | \
    xargs -I{} ic proxy-config endpoints {} --cluster "outbound|5000||helloworld.default.svc.cluster.local"
