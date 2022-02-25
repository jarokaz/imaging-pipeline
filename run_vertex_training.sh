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

readonly IMAGE=gcr.io/jk-mlops-dev/image-processor:latest

PROJECT=${1:-jk-mlops-dev}
REGION=${2:-us-central1}

SERVICE_ACCOUNT="vertex-sa@jk-mlops-dev.iam.gserviceaccount.com"

JOB_NAME=PROCESS-DICOM-$(date "+%Y-%m-%d-%M-%S")
INPUTS="gs://jk-imaging/data/kaggle-xray-seq"
OUTPUTS="gs://jk-imaging/outputs/${JOB_NAME}"
DEPTH=0
PRINT_IMAGES=true
IS_16BIT=false
COMMON_HEADERS_ONLY=true
SPLIT_INTO_CHUNKS=6
FLATTENED_TO_LEVEL=patient

ARGS="--DICOMHome,${INPUTS}"
#,--OutputDirectory,${OUTPUTS}"
#,--Depth,${DEPTH}" #,--PrintImages,${PRINT_IMAGES},--is16bit,${IS_16BIT},--CommonHeadersOnly,${COMMON_HEADERS_ONLY},--SplitIntoChunks,${SPLIT_INTO_CHUNKS},--FlattenedToLevel,${FLATTENED_TO_LEVEL}" 


gcloud ai custom-jobs create \
--project "$PROJECT" \
--region "$REGION" \
--service-account "$SERVICE_ACCOUNT" \
--display-name "$JOB_NAME" \
--worker-pool-spec "machine-type=n1-standard-16,replica-count=1,container-image-uri=$IMAGE" \
--command "python" \
--args "$ARGS" 








