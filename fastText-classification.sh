#!/usr/bin/env bash

myshuf() {
  perl -MList::Util=shuffle -e 'print shuffle(<>);' "$@";
}

normalize_text() {
  tr '[:upper:]' '[:lower:]' | sed -e 's/^/__label__/g' | \
    sed -e "s/'/ ' /g" -e 's/"//g' -e 's/\./ \. /g' -e 's/<br \/>/ /g' \
        -e 's/,/ , /g' -e 's/(/ ( /g' -e 's/)/ ) /g' -e 's/\!/ \! /g' \
        -e 's/\?/ \? /g' -e 's/\;/ /g' -e 's/\:/ /g' | tr -s " " 
}

RESULTDIR=result
DATADIR=input

mkdir -p "${RESULTDIR}"
mkdir -p "${DATADIR}"

cat "${DATADIR}/title_train1" | normalize_text > "${DATADIR}/title_train1.train"
cat "${DATADIR}/title_test1" | normalize_text > "${DATADIR}/title_test1.test"

./fastText/fasttext supervised -input "${DATADIR}/title_train1.train" -output "${RESULTDIR}/title_train1" -dim 10 -lr 0.1 -wordNgrams 2 -minCount 1 -bucket 10000000 -epoch 5 -thread 4

./fastText/fasttext test "${RESULTDIR}/title_train1.bin" "${DATADIR}/title_test1.test"

./fastText/fasttext predict "${RESULTDIR}/title_train1.bin" "${DATADIR}/title_test1.test" > "${RESULTDIR}/title_test1.test.predict"
