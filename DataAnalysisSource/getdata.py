f = open('d.txt')
file = open('pd.txt', 'w')
data = f.readline().split("0A")
print(data)
for line in iter(data):
    #print line
	d = line.split("2C")
	try:
		x = str(int(d[0],16))+ ", " + str(int(d[1],16))
		print(x)
		file.write(x+'\n')
	except ValueError:
		print("ehh")
f.close()

file.close()