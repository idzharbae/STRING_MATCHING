s = input()

res = []

for i in range(0, len(s)-2, 1):
   res.append(s[i:i+3])

print(res)
print(len(res))