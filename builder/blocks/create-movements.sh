#THIS SCRIPT NEEDS 4 ARGUMENTS:
#1 the input "sources" directory
#2 an output directory name
#3 the name of the collection
#4 the name of the artist
#5 the email to pay to

#CHECK TO SEE IF FILES EXSIST AND COMPLAIN IF THEY DONT
if [ ! -d "$1" ]; then
  echo "can't find \"$1\"."
fi

if [ ! -d "$2" ]; then
  mkdir $2
fi


#COUNT NUMBER OF PDFS AND MAKE FOLDERS AND STUFF BASED ON THOSE
pdfs=$(cd "$1" && ls *.pdf)
for pdf in $pdfs; do
	number=${pdf%.*}
	while IFS= read -r name; do
		echo "working on $name PDFs"
		mkdir "$2/$name"
		cp "$1/$number.pdf" "$2/$name/$name.pdf"
		mkdir "$2/$name/preview/"
		pdftoppm "$2/$name/$name.pdf" "$2/$name/preview/" -png
		pngs=$(cd "$2/$name/preview/" && ls)
		j=1; for png in $pngs; do
			mv "$2/$name/preview/$png" "$2/$name/preview/${png/-/}"
			j=$(($j+1))
		done
		if [ -f "temp-output/preview/01.png" ]; then
			zpngs=$(cd "temp-output/preview/" && ls 0*)
			for pngs in $zpngs; do
				mv "temp-output/preview/$pngs" "temp-output/preview/${pngs:1}"
			done
		fi
		cp "movement-download.html" "$2/$name/download.html"
		cp "movement-index.html" "$2/$name/index.html"
		title=$(sed '2q;d' "$1/$number.txt")
		descriptions=$(sed '11q;d' "$1/$number.txt")
		description=${descriptions//\//\\\/}
		price=$(sed '5q;d' "$1/$number.txt")
		pwyw=$(sed '8q;d' "$1/$number.txt")
		sed -i "s/\$ARTIST/$4/g" "$2/$name/download.html"
		sed -i "s/\$COLLECTION/$3/g" "$2/$name/download.html"
		sed -i "s/\$TITLE/$title/g" "$2/$name/download.html"
		if [ -f "$1/$number.zip" ]; then
			cp "$1/$number.zip" "$2/$name/$name.zip"
			sed -i "s/\$PDF.pdf/$name.zip/g" "$2/$name/download.html"
		else
			sed -i "s/\$PDF/$name/g" "$2/$name/download.html"
		fi
		sed -i "s/\$ARTIST/$4/g" "$2/$name/index.html"
		sed -i "s/\$COLLECTION/$3/g" "$2/$name/index.html"
		sed -i "s/\$TITLE/$title/g" "$2/$name/index.html"
		sed -i "s/\$DESCRIPTION/${description//\"/\\\"}/g" "$2/$name/index.html"
		sed -i "s/\$PRICE/$price/g" "$2/$name/index.html"
		sed -i "s/\$EMAIL/$5/g" "$2/$name/index.html"
		sed -i "s/\$PAGECOUNT/(($j-1))/g" "$2/$name/index.html"
		if [ $pwyw = "false" ]; then
	    		sed -i "s/onclick=\"document.querySelector('#payment').style.display = 'inline-block'\"/onclick=\"document.querySelector('#mc-embedded-subscribe').click() = 'inline-block'\"/g" "$2/$name/index.html"
	    		sed -i "s/\$PPLACE/\$$price/g" "$2/$name/index.html"
	    	elif [ $price = "0" ]; then
	    		sed -i "s/\$PPLACE/name your price/g" "$2/$name/index.html"
	    	else
	    		sed -i "s/\$PPLACE/\$$price or more/g" "$2/$name/index.html"
		fi
		if [ -f "$1/$number.mp3" ]; then
	    		echo "mp3 exsists!"
	    		cp "$1/$number.mp3" "$2/$name/preview.mp3"
	    		sed -i "s/<audio>/<audio controls>/g" "$2/$name/index.html"
		fi
	done < <(sed -n '2,2p' "$1/$number.txt" | tr -d '[:punct:]')
done
