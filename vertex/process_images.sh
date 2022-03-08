#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset

#
#trap 'exit_handler $? $LINENO' 1 2 3 15 ERR  
#
#exit_handler() {
#    echo "Error $1 occured in line $2"
#}
#

usage () {
    echo "Usage ..."
    exit 1
}

stage_images () {

}


use_fuse=false
while getopts ":g" options 
do
    case "$options" in
        g) 
            use_fuse=true
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [[ "$#" != 2 ]]; then
    echo "$#" 
    usage
fi


worker_type=$(echo "$CLUSTER_SPEC" | jq '.task.type')
worker_index=$(echo "$CLUSTER_SPEC" | jq '.task.index')

if [[ "$worker_type" != '"chief"' ]]; then
    if [[ "$worker_type" != '"workerpool0"' ]]; then
        worker_index=$(( worker_index + 1 ))
    fi
fi
paths=(${1//","/ })
if (( "${#paths[@]}" <= "$worker_index" )); then
    echo "Number of shards smaller than a number of workers"
    exit 0
fi

input_path="${paths[${worker_index}]}"
output_path="${2}/worker-${worker_index}"

readonly CHUNKS=1
readonly DEPTH=0
readonly PRINT_IMAGES=true
readonly IS_16BIT=false
readonly COMMON_HEADERS_ONLY=true
readonly FLATTEN_TO_LEVEL=patient

echo "Starting the pipeline on: $(date)"
pipeline_start_time=$(date +%s)

if [[ "$use_fuse" != "true" ]]
then
    inputs=/tmp/inputs; mkdir "$inputs"
    outputs=/tmp/outputs; mkdir "$outputs"
    echo "Copying data from ${input_path} to ${inputs}"
    start_time=$(date +%s)
    gcloud alpha storage cp -r "${input_path}/*" "$inputs" --no-user-output-enabled
    end_time=$(date +%s)
    echo "Elapsed time: $(( end_time - start_time ))"

else 
    echo 'Using GCS Fuse'
    inputs="${input_path/gs:\///gcs}"
    outputs="${output_path/gs:\///gcs}"
    echo "Inputs in ${inputs}"
    echo "Outputs in ${outputs}"
fi

echo "Starting image extraction"
start_time=$(date +%s)
python3 /app/Niffler/modules/png-extraction/ImageExtractor.py --DICOMHome ${inputs} --OutputDirectory ${outputs} \
--Depth "$DEPTH" --PrintImages "$PRINT_IMAGES" --is16Bit "$IS_16BIT" --CommonHeadersOnly "$COMMON_HEADERS_ONLY" \
--SplitIntoChunks "$CHUNKS" --FlattenedToLevel "$FLATTEN_TO_LEVEL"
end_time=$(date +%s)
echo "Elapsed time: $(( end_time - start_time ))"

# TODO. Check the Niffler logs and fail the job if any errors

if [[ "$use_fuse" != "true" ]]
then
    echo "Copying from ${outputs} to ${output_path}"
    start_time=$(date +%s)
    gcloud alpha storage cp -r "$outputs" "${output_path}" --no-user-output-enabled
    end_time=$(date +%s)
    echo "Elapsed time: $(( end_time - start_time ))"
fi

pipeline_end_time=$(date +%s)
echo "Pipeline completed on: $(date)"
echo "Elapsed time $(( $pipeline_end_time - $pipeline_start_time ))"