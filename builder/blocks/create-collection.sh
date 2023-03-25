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
cp "collection-download.html" "temp-output/download.html"
cp "collection-index.html" "temp-output/index.html"

title=$(sed '2q;d' "$1/info.txt")
descriptions=$(sed '20q;d' "$1/info.txt")
description=${descriptions//\//\\\/}
price=$(sed '11q;d' "$1/info.txt")
pwyw=$(sed '14q;d' "$1/info.txt")
email=$(sed '17q;d' "$1/info.txt")

sed -i "s/\$ARTIST/$3/g" "temp-output/download.html"
sed -i "s/\$COLLECTION/$title/g" "temp-output/download.html"
sed -i "s/\$ARTIST/$3/g" "temp-output/index.html"
sed -i "s/\$COLLECTION/$title/g" "temp-output/index.html"
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

/bin/bash create-movements.sh "$1/sources" "temp-output" "$title" "$email"
pdfs=$(cd "$1/sources" && ls *.pdf)
totaltracks=1
for pdf in $pdfs; do
	number=${pdf%.*}
	if (($totaltracks < $number)); then
		totaltracks=$number
	fi
done
mkdir temp-output/preview
i=0; j=1; while [ $i -ne $totaltracks ]; do
        i=$(($i+1))
	while IFS= read -r name; do
		propername=$(sed '2q;d' "$1/sources/$i.txt")
		sed -i "s/\$MOVEMENTS/<li><a href=\"${name// /%20}\/index.html\">$propername<\/a><\/li>\$MOVEMENTS/g" "temp-output/index.html"
		pngs=$(cd "temp-output/$name/preview" && ls *.png)
		for png in $pngs; do
			cp "temp-output/$name/preview/$png" "temp-output/preview/$j.png"
			j=$(($j+1))
		done
	done < <(sed -n '2,2p' "$1/sources/$i.txt" | tr -d '[:punct:]')
done
sed -i "s/\$PAGECOUNT/(($j-1))/g" "temp-output/index.html"
sed -i "s/\$MOVEMENTS//g" "temp-output/index.html"
if [ -f "$1/preview.mp3" ]; then
	echo "mp3 exsists!"
	cp "$1/preview.mp3" "temp-output/preview.mp3"
	sed -i "s/<audio>/<audio controls>/g" "temp-output/index.html"
fi
if [ -f "$1/cover.png" ]; then
	echo "cover exsists!"
	cp "$1/cover.png" "temp-output/cover.png"
else
	cp "temp-output/preview/1.png" "temp-output/cover.png"
fi
while IFS= read -r collectionName; do
	cp "$1/download.zip" "temp-output/$collectionName.zip"
	sed -i "s/\$ZIP/$collectionName.zip/g" "temp-output/download.html"
done < <(sed -n '2,2p' "$1/info.txt" | tr -d '[:punct:]')

if [ $pwyw = "false" ]; then
	sed -i "s/<input type=\"text\"/$price<input type=\"hidden\"/g" "temp-output/index.html"
fi

while IFS= read -r collectionName; do
	mv temp-output "$2/$collectionName"
done < <(sed -n '2,2p' "$1/info.txt" | tr -d '[:punct:]')
