#!/bin/bash


ARGS="$@"
OUTPUT=""
echo "Lilypond files: ${ARGS}"

for f in ${ARGS}; do
	filename=${f%%.lypp}
	echo $filename
        for i in soprano alto tenor bass ; do
        	cpp -P -DDRUM -D$(echo $i | tr a-z A-Z) $filename.lypp temp.ly 2> /dev/null
        	lilypond temp.ly
        	timidity temp.midi -Ow -o temp.wav
        	ffmpeg -i temp.wav -vn -ar 44100 -ac 2 -b:a 192k ${filename}_$i.mp3
        	rm temp*
                OUTPUT="${OUTPUT}${filename}_$i.mp3 "
        done
done


mkdir tmp

pagename=tmp/tmpmypage.md

for i in $(ls -d */ | grep -v tmp) ; do
       echo "Processing ${i%%/}"
       cat ${i}info.md >> $pagename
       echo "<br/><br/>">> $pagename
       echo "*Fichiers de travail (mp3):*" >> $pagename 
       for j in ${i}*soprano.mp3 ${i}*alto.mp3 ${i}*tenor.mp3 ${i}*bass.mp3; do
	       k=${j##*/}
	       echo "[$k](https://github.com/juliedigne/distantsinging/releases/download/main/$k)  " >> $pagename
       done

       echo "<br/>" >> $pagename

       if test -f ave_verum_corpus/*resultat.mp3; then
	      res=ave_verum_corpus/*resultat.mp3
	      echo "Result file exists";
	      echo "_Résultat du montage_:  " >> $pagename
	      resname=${res##*/}
	      echo "[$resname](https://github.com/juliedigne/distantsinging/raw/main/ave_verum_corpus/$res)  " >> $pagename

	      if test -f ave_verum_corpus/credits.md; then
	      	cat ave_verum_corpus/credits.md >> $pagename
	      fi
       fi
done

git --global user.email "githubaction@github.com"
git --global user.name "Auto commit"

git checkout gh-pages
cp $pagename mypage.md
git add mypage.md
git commit mypage.md
git push


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
