#!/bin/bash

convertman() {
	# $1 should be name of manpage
	# $2 should be section of man
	SECTION="$2"
	LOC=$(man -w "$SECTION" "$NAME")
	zcat "$LOC" | pandoc -f man -o "$NAME".html 2> /dev/null || \
	echo "pandoc failed, resorting to groff for $NAME ($SECTION)" && \
	zcat "$LOC" | (groff -t -mandoc -Thtml > "$NAME".html 2> /dev/null && sed -i '/<h1 align/,/<hr>/d' "$1".html) || \
	echo "converting $NAME ($SECTION) failed."

	sed -i "/<body>/a <h1>$NAME<\/h1>" "$NAME".html
}

make_title_html() {
  : > man/toc.html
  cat << EOF >> man/toc.html
<nav id='TOC' role='doc-toc'>
<ul>
EOF

	for a in $@; do
    echo "<li><a href='#section-$a' id='toc-section-$a'>Section $a</a></li>" >> man/toc.html
	done

	cat << EOF >> man/toc.html
</ul>
</nav>
EOF
}

export -f convertman

if [ ! -d "man" ]; then
  echo "converting all manpages to html"
  for a in $@; do
    mkdir -p man/"$a"
    cd man/"$a"
    # async
    apropos -s "$a" . 2> /dev/null | \
    cut -f 1 -d' ' | \
    parallel -I % -j0 convertman "%" "$a" 2> /dev/null || echo "conversions failed for section $a"
    echo "converted section $a"
    cd ../../
  done;
else
  echo "./man already exists, skipping"
fi;

if [ ! -d "man/intros" ]; then
	mkdir -p man/intros
  
  echo "separating section intros"
  for a in $@; do
		mv man/"$a"/intro.html man/intros/intro_"$a".html
  done
else
  echo "./man/intros already exists, skipping"
fi

if [ ! -d "man/comb" ]; then
  mkdir -p man/comb

  echo "combining individual sections"
  for a in $@; do
    (cd man/"$a" && \
    	pandoc -o ../comb/"$a".html -s -M pagetitle="Section $a" -M title="Section $a"  $(test -f ../intros/intro_"$a".html && echo "../intros/intro_$a.html")  $(ls *.html  2> /dev/null | sort -bdfi) && \
    	# sed -i "/<body>/a <h1>Section $a<\/h1>" ../comb/"$a".html && \
    	echo "combined section $a" && \
    	cd ../../) &
  done
  wait
else
  echo "./man/comb already exists, skipping"
fi

if [ ! -d "man/build" ]; then
  mkdir -p man/build

  echo "building final book"

	make_title_html $@

  pandoc -o man/build/build.html -M pagetitle="Manbook" -M title="Manbook" -B man/toc.html -s man/comb/*.html
else
  echo "./man/build already exists, skipping"
fi

echo "done"
