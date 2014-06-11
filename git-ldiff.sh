#!/bin/bash
#
# A simple bash script for creating LaTeX diffs from git revisions
#
# Usage: git-ldiff.sh OLD_REF NEW_REF 
#
# Notes: 1) Latexdiff is required, preferably version 1.0.1+ so that 
# included files are handled correctly. 2) The script will pick up on 
# a .append-safecmd file in the main document folder to use for the 
# --append-safecmd option of latexdiff. 
#
# Author: Joe Monaco <jmonaco@jhu.edu> 
# Last updated: June 11, 2014.
#
# This work is licensed under the Creative Commons Attribution 4.0
# International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by/4.0/.
#

# Set base names of main input (.tex) file and the output (.pdf) file
MAINBASE=main
DIFFBASE=diff

if [[ ! -d ".git" ]]; then
    echo please run from the root of your document repository
    exit 1
fi

ROOT=`pwd`
REPO=$ROOT/.git
PROG=`basename $0`
TMP=`mktemp -d -t $PROG` || exit 2

OLD=$TMP/old
NEW=$TMP/new
MAIN=$MAINBASE.tex
DIFF=$DIFFBASE.tex
AUX=$DIFFBASE.aux
PDF=$DIFFBASE.pdf

OLDREF=$1
NEWREF=$2

LD_OPTS="--flatten"
SAFEFILE=$ROOT/.append-safecmd
if [[ -e "$SAFEFILE" ]]; then
    LD_OPTS="--append-safecmd=\"$SAFEFILE\" $LD_OPTS"
fi

GIT="git"
LATEXDIFF="latexdiff"
LATEX="pdflatex"
BIBTEX="bibtex"
CD="cd"
MV="mv"

$GIT clone $REPO $OLD
$GIT clone $REPO $NEW

$CD $OLD; $GIT checkout $OLDREF > /dev/null 2>&1
$CD $NEW; $GIT checkout $NEWREF > /dev/null 2>&1

$CD $TMP; 
$LATEXDIFF $LD_OPTS $OLD/$MAIN $NEW/$MAIN > $NEW/$DIFF

$CD $NEW;
$LATEX -interaction batchmode $DIFF
if [[ ! -z `cat *.aux */*.aux 2>&1 /dev/null | grep citation` ]]; then
    $BIBTEX -terse $AUX
    $LATEX -interaction batchmode $DIFF
    $LATEX -interaction batchmode $DIFF
fi

FINALPDF=$ROOT/$DIFFBASE-$OLDREF-$NEWREF.pdf
$MV $NEW/$PDF "$FINALPDF";

echo diff saved as "$FINALPDF"
