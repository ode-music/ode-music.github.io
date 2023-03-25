import os

if (os.path.exists('../../resource/artist-list.js')):
	print("DELETED!")
	os.remove('../../resource/artist-list.js')

files = os.listdir('../../')

artists = []

for file in files:
	if (os.path.isdir('../../'+file)):
		print(file)
		if (file == "builder"):
			print("skip")
		elif (file == "resource"):
			print("skip")
		else:
			print("woah mama!")
			artists.append(file)

print(artists)

f = open("../../resource/artist-list.js", "x")
f.write("artists = [\n")
for artist in artists:
	f.write('	"'+artist+'",\n')
f.write("]")
f.close()
