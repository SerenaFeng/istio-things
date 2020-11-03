#!/bin/bash

cmd=${@:-"curl helloworld:5000/hello"}
k ex -c helloworld $(k g pod -l app=helloworld -o jsonpath='{.items[0].metadata.name}') ${cmd} 2>/dev/null
