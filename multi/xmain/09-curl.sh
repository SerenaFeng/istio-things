#!/bin/bash

set -x

cmd=${@:-"curl helloworld:5000/hello"}
k ex -c sleep $(k g pod -l app=sleep -o jsonpath='{.items[0].metadata.name}') ${cmd} 2>/dev/null
