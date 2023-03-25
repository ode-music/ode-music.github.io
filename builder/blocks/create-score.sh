#THIS SCRIPT HAS THREE INPUTS
#1. The source folder
#2. A destination folder to put stuff in
#3. The name of the artist

#CHECK TO SEE IF FILES EXSIST AND COMPLAIN IF THEY DONT
if [ ! -d "$1" ]; then
  echo "can't find \"$1\"."
fi

if [ ! -d "$2" ]; then
  mkdir "$2"
fi

mkdir temp-output
cp "score-download.html" "temp-output/download.html"
cp "score-index.html" "temp-output/index.html"

title=$(sed '2q;d' "$1/info.txt")
descriptions=$(sed '20q;d' "$1/info.txt")
description=${descriptions//\//\\\/}
price=$(sed '11q;d' "$1/info.txt")
pwyw=$(sed '14q;d' "$1/info.txt")
email=$(sed '17q;d' "$1/info.txt")

sed -i "s/\$ARTIST/$3/g" "temp-output/download.html"
sed -i "s/\$TITLE/$title/g" "temp-output/download.html"
sed -i "s/\$ARTIST/$3/g" "temp-output/index.html"
sed -i "s/\$TITLE/$title/g" "temp-output/index.html"
sed -i "s/\$DESCRIPTION/${description//\"/\\\"}/g" "temp-output/index.html"
sed -i "s/\$PRICE/$price/g" "temp-output/index.html"
sed -i "s/\$EMAIL/$email/g" "temp-output/index.html"
if [ $pwyw = "false" ]; then
	sed -i "s/onclick=\"document.querySelector('#payment').style.display = 'inline-block'\"/onclick=\"document.querySelector('#mc-embedded-subscribe').click() = 'inline-block'\"/g" "temp-output/index.html"
	sed -i "s/\$PPLACE/\$$price/g" "temp-output/index.html"
elif [ $price = "0" ]; then
	sed -i "s/\$PPLACE/name your price/g" "temp-output/index.html"
else
	sed -i "s/\$PPLACE/\$$price or more/g" "temp-output/index.html"
fi

mkdir temp-output/preview
cp "$1/score.pdf" "temp-output/score.pdf"
pdftoppm "temp-output/score.pdf" "temp-output/preview/" -png
pngs=$(cd "temp-output/preview/" && ls)
j=1; for png in $pngs; do
	mv "temp-output/preview/$png" "temp-output/preview/${png/-/}"
	j=$(($j+1))
done
if [ -f "temp-output/preview/01.png" ]; then
	zpngs=$(cd "temp-output/preview/" && ls 0*)
	for pngs in $zpngs; do
		mv "temp-output/preview/$pngs" "temp-output/preview/${pngs:1}"
	done
fi
sed -i "s/\$PAGECOUNT/(($j-1))/g" "temp-output/index.html"
while IFS= read -r name; do
	if [ -f "$1/download.pdf" ]; then
		cp "$1/download.pdf" "temp-output/$name.pdf"
		sed -i "s/\$PDF/$name.pdf/g" "temp-output/download.html"
	else
		cp "$1/download.zip" "temp-output/$name.zip"
		sed -i "s/\$PDF/$name.zip/g" "temp-output/download.html"
	fi
done < <(sed -n '2,2p' "$1/info.txt" | tr -d '[:punct:]')
if [ -f "$1/cover.png" ]; then
	echo "cover exsists!"
	cp "$1/cover.png" "temp-output/cover.png"
else
	cp "temp-output/preview/1.png" "temp-output/cover.png"
fi
if [ -f "$1/preview.mp3" ]; then
	echo "mp3 exsists!"
	cp "$1/preview.mp3" "temp-output/preview.mp3"
	sed -i "s/<audio>/<audio controls>/g" "temp-output/index.html"
fi

while IFS= read -r collectionName; do
	mv temp-output "$2/$collectionName"
done < <(sed -n '2,2p' "$1/info.txt" | tr -d '[:punct:]')
