TextWatermark - images text watermarking utility.

	TextWatermark -c whiteColor -a 0.8 -f "Arial" -s 80 -r 90 -2 -x 20 -y 100 -o "Ⓒ Bob Ivanoff www.example.com" file.jpg

Adds vertical watermark with text "Ⓒ Bob Ivanoff www.example.com" in right bottom corner in white color, alpha 0.8, Arial font of size 80, offset 20 by x axis and 100 by y axis. Resulting image:
![Watermarked image][example_image]

	find  . -iname "*.jpg" -print0 | xargs -0 TextWatermark -c lightGrayColor  -f "American Typewriter" -s 60  -1 -o "Ⓒ Bob Ivanoff www.example.com"

Adds horisontal watermark into down left corner to all .jpg images in current forder.

To make folder which will automaticly watermark all images in it, copy file com.w7software.TextWatermark.plist (don't forget to populate it with your data) into ~/Library/LaunchAgents folder. textwatermarking_script.sh and TextWatermark should be places somewhere where they could be run.

[example_image]: http://w7software.com/external_resources/IMG_7603.JPG