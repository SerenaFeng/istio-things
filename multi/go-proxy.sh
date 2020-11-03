#!/bin/bash

k ex -c istio-proxy $(k g pod -l app=helloworld -o jsonpath='{.items[0].metadata.name}') -ti bash
