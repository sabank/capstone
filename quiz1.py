import re

# file name
# file_name = r"/Volumes/My Passport Ultra/3-Documents/34-EDUCATION/342_Coursera/JohnsHopkinsUniversity/GitHub/capstone/final/en_US/en_US.twitter.txt"
# file_name = r"/Volumes/My Passport Ultra/3-Documents/34-EDUCATION/342_Coursera/JohnsHopkinsUniversity/GitHub/capstone/final/en_US/en_US.news.txt"
file_name = r"/Volumes/My Passport Ultra/3-Documents/34-EDUCATION/342_Coursera/JohnsHopkinsUniversity/GitHub/capstone/final/en_US/en_US.blogs.txt"

# creates handler for file, and checks file exists
try:
	file_handler = open(file_name,"r")
except:
	print "File cannot be opened."
	exit()
####################################################################################################
# Quiz1: Getting started
# Q1: The en_US.blogs.txt file is how many megabytes?
# Answer = 200
####################################################################################################
# Q2: The en_US.twitter.txt has how many lines of text?
# Answer =
# linecount = 0
# for line in file_handler:
# 	line = line.rstrip()
# 	linecount += 1
# print "There were", linecount, "lines in the file en_US.twitter.txt"
####################################################################################################
# Q3: What is the length of the longest line seen in any of the three en_US data sets?
# Answer =
length = 0
for line in file_handler:
	line = line.rstrip()
	if not len(line) > length:
		continue
	length = len(line)
print length
####################################################################################################
# Q4: In the en_US twitter data set, if you divide the number of lines where the word "love"
# (all lowercase) occurs by the number of lines the word "hate" (all lowercase) occurs, about what do
# you get?
# Answer =
# lovecount = 0
# hatecount = 0
# for line in file_handler:
# 	line = line.rstrip()
# 	if re.search("[l]ove",line):
# 		lovecount += 1
# 	if re.search("[h]ate",line):
# 		hatecount += 1
#
# print "There were", lovecount, "lines with word 'love' in the file en_US.twitter.txt"
# print "There were", hatecount, "lines with word 'hate' in the file en_US.twitter.txt"
# print "the ratio =", lovecount/hatecount
####################################################################################################
# Q5: The one tweet in the en_US twitter data set that matches the word "biostats" says what?
# Answer =
# for line in file_handler:
# 	line = line.rstrip()
# 	if re.search("[b]iostats",line):
# 		print line
####################################################################################################
# Q6: How many tweets have the exact characters "A computer once beat me at chess, but it was no match
# for me at kickboxing". (I.e. the line matches those characters exactly.)
# Answer =
# count = 0
# for line in file_handler:
# 	line = line.rstrip()
# 	if re.search("A computer once beat me at chess, but it was no match for me at kickboxing",line):
# 		count += 1
# print "There were", count, "tweets matching exactly 'A computer once beat me at chess, but it was \
# no match for me at kickboxing'"
