#!/bin/bash

k ex -c sleep $(k g pod -l app=sleep -o jsonpath='{.items[0].metadata.name}') curl helloworld:5000/hello 2>/dev/null
