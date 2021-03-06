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


export INPUTS=/inputs/kaggle-xray-seq
export OUTPUTS=/outputs/t1
export CHUNKS=6 

echo "Starting the pipeline on: $(date)"
pipeline_start_time=$(date +%s)

python3 /app/Niffler/modules/png-extraction/ImageExtractor.py --DICOMHome ${INPUTS} --OutputDirectory ${OUTPUTS} --Depth 0 --PrintImages true --is16Bit false --CommonHeadersOnly true --SplitIntoChunks ${CHUNKS} --FlattenedToLevel patient

pipeline_end_time=$(date +%s)

echo "Pipeline completed on: $(date)"
echo "Elapsed time $(( $pipeline_end_time - $pipeline_start_time ))"