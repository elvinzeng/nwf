#!/bin/sh
# desc: A util for linux host which dos2unix was not installed.
# convert the text file to unix format from dos format.
# Author: Elvin

filepath="$1"

usage(){
	echo "usage:"
	echo "    sh _dos2unix.sh filepath"
}

if [ $# -lt 1 ]; then
	usage
	exit 1;
fi

if [ $# -gt 1 ]; then
        usage
        exit 1;
fi

if [ ! -f "$filepath" ]; then
	if [ -d "$filepath" ]; then
		echo "can not convert a directory."
		usage
		exit 1;
	fi
    echo "file not found."
    exit 1;
fi

isTextFile=$(file $filepath | grep 'text' -c)
if [ $isTextFile -ne 1 ]; then
	echo "it is not a text file. operation cancelled."
	exit 1;
fi

echo "converting file $filepath to UNIX format..."

echo "removing BOM..."
sed -i 's/\xEF\xBB\xBF//' $filepath

echo "converting newline style..."
sed -i 's/\r//g' $filepath

echo "converting file encoding to UTF-8..."
tempfile=$(mktemp)
se="$(file hehe.txt --mime-encoding | awk '{print $2}')"
skipEncodingConvertFlag=0
if [ "${se}x" = "iso-8859-1x" ]; then
	se="GBK"
elif [ "${se}x" = "utf-8x" ]; then
	se="UTF-8"
	skipEncodingConvertFlag=1
elif [ "${se}x" = "ASCIIx" ]; then
	se="ASCII"
else
	echo "unknown file encoding. file encoding convert skipped."
	skipEncodingConvertFlag=1
fi
if [ $skipEncodingConvertFlag -eq 0 ]; then
	iconv -f "$se" -t UTF-8 "$filepath" > "$tempfile"
	cp "$tempfile" "$filepath"
fi

