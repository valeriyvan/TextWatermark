#!/bin/sh

#  folder_action.sh
#  TextWatermark
#
#  Created by Valeriy Van on 9/20/12.
#  Copyright (c) 2012 w7software.com. All rights reserved.

ORIG="./Original Images"
RES="./Watermarked Images"
WMARK="/Applications/TextWatermark"
TEXT="Ⓒ Valeriy Van www.valeriyvan.com"

find_cmd () {
find . \( -iname "*.jpg" -o -iname "*.jpeg" \) -maxdepth 1 -print0
}

find_cmd_count () {
find . \( -iname "*.jpg" -o -iname "*.jpeg" \) -maxdepth 1 | wc -l
}

#COUNT=$(`eval find_cmd` | wc -l)

say started with `find_cmd_count` files

#mkdir if they don't exist
mkdir -p "$ORIG"
mkdir -p "$RES"

while [ `find_cmd_count` -ne 0 ]
do

#BEFORE=`find_cmd`

find . \( -iname "*.jpg" -o -iname "*.jpeg" \) -maxdepth 1 -print0 | xargs -0 "$WMARK" -c whiteColor -a 0.8 -f "Arial" -s 80 -r 90 -2 -x 20 -y 100 -d "$RES" -D "$ORIG" "$TEXT"

# some files might have been added, so loop again
# but if some files couldn't be processed, check that

#AFTER=`find_cmd`

#if [$BEFORE -eq $AFTER] || break

done

say finished