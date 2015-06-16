#!/bin/sh

if [ `type tesseract > /dev/null 2>/dev/null` ]; then
  echo "'tesseract' not found! Please install it first."
  exit 1
fi

if [  `type convert > /dev/null 2>/dev/null` ]; then
  echo "'convert' not found! Please install it first."
  exit 2
fi

if [ "$#" -ne 4 ]; then
  echo "Wrong arguments!"
  echo "Usage: ocr.sh source start_page_no end_page_no output"
  exit 3
fi

STARTPAGE=$2 # set to pagenumber of the first page of PDF you wish to convert
ENDPAGE=$3 # set to pagenumber of the last page of PDF you wish to convert
SOURCE=$1 # set to the file name of the PDF
OUTPUT=$4 # set to the final output file
RESOLUTION=600 # set to the resolution the scanner used (the higher, the better)

touch $OUTPUT
for i in `seq $STARTPAGE $ENDPAGE`; do
  convert -monochrome -density $RESOLUTION $SOURCE\[$(($i - 1 ))\] page.tif
  echo processing page $i
  tesseract page.tif tempoutput
  cat tempoutput.txt >> $OUTPUT
done
