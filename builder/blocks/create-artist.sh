#THIS SCRIPT NEEDS 1 ARGUMENTS:
#1 the input artist directory

artist=$(sed '2q;d' "$1/info.txt")

while IFS= read -r artistfolder; do
	mkdir "../../$artistfolder/"
	cp "artist-index.html" "../../$artistfolder/index.html"
	collections=$(cd "$1/sheetmusic" && ls)
	for collection in $collections; do
		collectiongroup=$(sed '8q;d' "$1/sheetmusic/$collection/info.txt")
		actualname=$(sed '2q;d' "$1/sheetmusic/$collection/info.txt")
		while IFS= read -r foldername; do
			echo "working on $actualname"
			sed -i "s/\$SCORES/\$SCORES<a href=\"${foldername// /%20}\/index.html\"><div class=\"score-span\"><img src=\"${foldername// /%20}\/cover.png\" \/><p>$actualname<\/p><\/div><\/a>/g" "../../$artistfolder/index.html"
		done < <(sed -n '2,2p' "$1/sheetmusic/$collection/info.txt" | tr -d '[:punct:]')
		if [ $collectiongroup = "true" ]; then
			/bin/bash create-collection.sh "$1/sheetmusic/$collection" "../../$artistfolder" "$artist"
		else
			/bin/bash create-score.sh "$1/sheetmusic/$collection" "../../$artistfolder" "$artist"
		fi
	done
	sed -i "s/\$SCORES//g" "../../$artistfolder/index.html"
	sed -i "s/\$ARTIST/$artist/g" "../../$artistfolder/index.html"
	cp -r "$1/resource" "../../$artistfolder/resource"
done < <(sed -n '2,2p' "$1/info.txt" | tr -d '[:punct:]')
