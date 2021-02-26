k t ex -c sleep $(k t g po -l app=sleep -o jsonpath='{.items[0].metadata.name}') -- curl helloworld.sample:5000/hello -s
