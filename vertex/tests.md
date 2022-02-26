```
docker run -it --rm \
-v /home/jupyter/data:/data \
-v /home/jupyter/imaging-pipeline:/src \
-e CLUSTER_SPEC='{"cluster":{"workerpool0":["cmle-training-workerpool0-b644f12a34-0:2222"],"workerpool1":["cmle-training-workerpool1-b644f12a34-0:2222","cmle-training-workerpool1-b644f12a34-1:2222"]},"environment":"cloud","task":{"type":"workerpool0","index":0},"job":"{\"python_module\":\"\",\"package_uris\":[],\"job_args\":[]}"} ' \
--entrypoint /bin/bash \
gcr.io/jk-mlops-dev/dicom-processor
```
```
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
```
