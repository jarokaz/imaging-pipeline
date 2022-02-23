#!/bin/bash

SOURCE_PATH=gs://jk-imaging/data/kaggle-xray
DEST_PATH=gs://jk-imaging/data/kaggle-xray-seq

i=1
for file in $(gsutil ls "$SOURCE_PATH")
do
    i=$(( i + 1 ))
    file_name="$(printf "%020d" "$i").dcm"
    gsutil cp "$file" "$DEST_PATH/$file_name"
done
