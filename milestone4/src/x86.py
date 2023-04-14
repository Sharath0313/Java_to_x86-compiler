import sys

if len(sys.argv) != 2:
    sys.exit("The syntax to run x86.py file is: Python3 x86.py input3ac_filename")

input_3ac = open(sys.argv[1],"r")

inst_3ac = input_3ac.readlines()
outfile = open("trial.txt","w")

inst_3ac = [x[:-1] for x in inst_3ac]

for x in inst_3ac:
    outfile.write(x)
