#!/bin/bash


ARGS="$@"
OUTPUT=""
echo "Lilypond files: ${ARGS}"

for f in ${ARGS}; do
	filename=${f%%.lypp}
	echo $filename
        for i in SOPRANO ALTO TENOR BASS ; do
		rm ${filename}_${i}.mp3
        	cpp -P -DDRUM -DSOPRANO $filename.lypp temp.ly 2> /dev/null
        	lilypond temp.ly
        	timidity temp.midi -Ow -o temp.wav
        	ffmpeg -i temp.wav -vn -ar 44100 -ac 2 -b:a 192k ${filename}_$i.mp3
        	rm temp*
                OUTPUT="${OUTPUT}${filename}_$i.mp3 "
        done
done

echo "::set-output name=mp3s::${OUTPUT}"

echo "jusque là ça va"

#ARGS="$@"
#OUTPUT=""
#echo "Lilypond list: ${ARGS}"
#for f in ${ARGS}; do
#    echo "Processing ${f}"
#    if [ ! -f ${f} ]; then
#        echo "Error: ${f} does not exists"
#        exit 1
#    fi
#
#    lilypond -o $(dirname ${f}) ${f}
#    if [ $? -ne 0 ]; then
#        echo "Error: Compilation failure on ${f}"
#    fi
#
#    OUTPUT="${OUTPUT}${f%%ly}pdf "
#done
#
#echo "::set-output name=pdfs::${OUTPUT}"
