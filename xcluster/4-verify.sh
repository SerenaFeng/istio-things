
ic pc ep $(k t g po -l app=sleep -o jsonpath='{.items..metadata.name}').sample | grep hello

