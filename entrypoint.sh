#!/bin/bash


ARGS="$@"
OUTPUT=""
echo "Lilypond files: ${ARGS}"

for f in ${ARGS}; do
	if test -f $f; then
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

          	cpp -P -DDRUM -DSOPRANO -DALTO-DTENOR -DBASS $filename.lypp temp.ly 2> /dev/null
          	lilypond temp.ly
          	timidity temp.midi -Ow -o temp.wav
          	ffmpeg -i temp.wav -vn -ar 44100 -ac 2 -b:a 192k ${filename}_tutti.mp3
          	rm temp*
                OUTPUT="${OUTPUT}${filename}_tutti.mp3 "
	fi
done


mkdir tmp

pagename=tmp/tmpmypage.md

cat webhelper/header.md > $pagename

for i in $(ls -d */ | grep -v tmp | grep -v webhelper | sort -r) ; do
       echo "Processing ${i%%/}"
       cat ${i}info.md >> $pagename
       if test -f ${i}*soprano.mp3; then
           echo "<br/><br/>">> $pagename
           echo "Fichiers de travail (mp3):<br/>" >> $pagename 
           for j in ${i}*soprano.mp3 ${i}*alto.mp3 ${i}*tenor.mp3 ${i}*bass.mp3 ${i}*tutti.mp3; do
                   k=${j##*/}
                   echo "[$k](https://github.com/juliedigne/distantsinging/releases/download/main/$k)  " >> $pagename
           done

           echo "<br/>" >> $pagename
       fi

#       if test -f ${i}*resultat.mp3; then
#	      res=${i}*resultat.mp3
#	      echo "Result file exists";
#	      echo "_Résultat du montage_:  " >> $pagename
#	      resname=${res##*/}
#	      echo "[$resname](https://github.com/juliedigne/distantsinging/raw/main/$res)  " >> $pagename
#
#	      if test -f ${i}/credits.md; then
#	      	cat ${i}/credits.md >> $pagename
#	      fi
#       fi
done

set -x

git fetch origin

REMOTE_BRANCH="gh-pages"
REMOTE_REPO="https://${GH_PAT}@github.com/${GITHUB_REPOSITORY}.git"
git config --global user.email "githubaction@github.com"
git config --global user.name "ghpage action commit"

git checkout --track origin/gh-pages
cp $pagename index.md
git add index.md
git commit index.md -m "GH page automatic update through github action"
git push --force $REMOTE_REPO


echo "::set-output name=mp3s::${OUTPUT}"
