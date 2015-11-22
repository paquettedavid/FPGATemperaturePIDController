# David Paquette
# Nov 21, 2015
# ~ 1 AM
f = open('OpenLoopTests/test2/data.asc')
file = open('DATA.txt', 'w')
for line in iter(f):
    #print line
    d = line.split(',')
    x = int(hex(ord(d[0])),16)
    file.write(str(x)+'\n')
f.close()

file.close()
