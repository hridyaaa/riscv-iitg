#!/bin/bash python

import sys
import os

# NoArg = len(sys.argv)-1
# print "No of arguments: ", NoArg
	
if sys.argv[1]=="hex_enable" and os.path.isfile(sys.argv[2]) :
	fin  = open ( sys.argv[2] )
	fout = open ( sys.argv[2]+".new", "w" )
	for line in fin:
		if "$readmemh" in line.lower():
			
			if "// initial" in line.lower():
				line = line.replace( "// initial", "initial" )
			fout.write(line)
		else :
			fout.write(line)
	fin.close()
	fout.close()
	os.rename(sys.argv[2]+".new", sys.argv[2])
	# print "------------- ",sys.argv[2]," has been updated -------------"
	
if sys.argv[1]=="hex_disable" and os.path.isfile(sys.argv[2]) :
	fin  = open ( sys.argv[2] )
	fout = open ( sys.argv[2]+".new", "w" )
	for line in fin:
		if "$readmemh" in line.lower():
			if "// initial" in line.lower():
				line = line
			else:
				line = line.replace( "initial", "// initial" )
			fout.write(line)
		else :
			fout.write(line)
	fin.close()
	fout.close()
	os.rename(sys.argv[2]+".new", sys.argv[2])
	# print "------------- ",sys.argv[2]," has been updated -------------"
	
if sys.argv[1]=="fwrite_enable" and os.path.isfile(sys.argv[2]) :
	fin  = open ( sys.argv[2] )
	fout = open ( sys.argv[2]+".new", "w" )
	for line in fin:
		if "(simulation only)" in line.lower():
			line = line.replace( '/*', '' )
			fout.write(line)
		elif "endmodule" in line:
			line = line.replace( '*/', '' )
			fout.write(line)
		else :
			fout.write(line)
	fin.close()
	fout.close()
	os.rename(sys.argv[2]+".new", sys.argv[2])
	# print "------------- ",sys.argv[2]," has been updated ------------- "
	
if sys.argv[1]=="fwrite_disable" and os.path.isfile(sys.argv[2]) :
	fin  = open ( sys.argv[2] )
	fout = open ( sys.argv[2]+".new", "w" )
	till_endmodule = 0
	for line in fin:
		if "(simulation only)" in line.lower():
			if line[0:2] != '/*': till_endmodule = 1
			if line[0:2] != '/*': line = '/*' + line
			fout.write(line)
		elif "endmodule" in line and till_endmodule==1:
			if line[0:2] != '*/': till_endmodule = 0
			if line[0:2] != '*/': line = '*/' + line
			fout.write(line)
		else :
			fout.write(line)
	fin.close()
	fout.close()
	os.rename(sys.argv[2]+".new", sys.argv[2])
	# print "------------- ",sys.argv[2]," has been updated ------------- "
	
if sys.argv[1]=="hex_change" and os.path.isfile(sys.argv[2]) :
	fin  = open ( sys.argv[2] )
	fout = open ( sys.argv[2]+".new", "w" )
	for line in fin:
		if "$readmemh" in line.lower():
			list    = line.split('"')
			list[1] = '"'+sys.argv[3]+'"'
			line    = ''
			for item in list: line += item
			fout.write(line)
		else :
			fout.write(line)
	fin.close()
	fout.close()
	os.rename(sys.argv[2]+".new", sys.argv[2])
	# print "------------- ",sys.argv[2]," has been updated -------------"
	
	
	
	
	
	
	
	
	
	