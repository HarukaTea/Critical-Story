
import re

path = "./items.json"

with open(path, 'r', encoding="utf-8") as f:
    content = f.read()
    f.close()

content = re.sub(r'\[', '{', content)
content = re.sub(r']', '}', content)
content = re.sub(r'//', '--', content)

newList = []

# Fing all keys
obj = re.compile( r'"[^,]*?:')
list_1 = obj.findall(content)

for s in list_1:
    tmp = '[' + s
    tmp = re.sub(r'"\s*?:', '\"] =', tmp)
    newList.append(tmp)

# replace back
for i in range(len(list_1)):
    content = content.replace(list_1[i], newList[i])

# fix some potential errors
filename = re.sub(r'\..*$','', path)
f = open('Items.lua', 'w')
f.write(content)
f.close()
print("output success! --> " + 'Items.lua')