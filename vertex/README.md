
docker run -it --rm \
-v /home/jupyter/data:/data \
-v /home/jupyter/imaging-pipeline:/src \
--entrypoint /bin/bash \
gcr.io/jk-mlops-dev/dicom-processor


export CHUNKS=1
export DEPTH=0
export PRINT_IMAGES=true
export IS_16BIT=false
export COMMON_HEADERS_ONLY=true
export FLATTEN_TO_LEVEL=patient

export inputs=/data/t1
export outputs=/data/outputs/testing/t1


python3 /app/Niffler/modules/png-extraction/ImageExtractor.py --DICOMHome ${inputs} --OutputDirectory ${outputs} \
--Depth "$DEPTH" --PrintImages "$PRINT_IMAGES" --is16Bit "$IS_16BIT" --CommonHeadersOnly "$COMMON_HEADERS_ONLY" \
--SplitIntoChunks "$CHUNKS" --FlattenedToLevel "$FLATTEN_TO_LEVEL"