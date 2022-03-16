#!/bin/bash
#

set -eo pipefail
DIR=`dirname "$(readlink -f "$0")"`

FRAME_DIR="$DIR/input_pics"
OUTPUT_DIR="$DIR/output_pics"
for INFILE in $FRAME_DIR/*; do
    OUTFILE_NAME=$(basename $INFILE)
    OUTFILE="$OUTPUT_DIR/$OUTFILE_NAME"
    echo "$OUTFILE"

    w1=`identify -format %w $INFILE`
    h1=`identify -format %h $INFILE`

    
    
    echo "$w1, $h1"
    $DIR/picframe -f 2 -m 10 -b 1 $INFILE $OUTFILE
done
