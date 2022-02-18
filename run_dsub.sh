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

readonly DSUB_PROVIDER=google-cls-v2
readonly POLLING_INTERVAL=30s
readonly IMAGE=gcr.io/jk-mlops-dev/image-processor:latest
readonly SCRIPT=./scripts/process_images.sh

TASKS=${1:-tasks.tsv}
PROJECT=${2:-jk-mlops-dev}
REGION=${3:-us-central1}
MIN_RAM=${4:-16}
MIN_CORES=${5:-4}
DISK_SIZE=${6:-200}
LOGGING_PATH=${7:-gs://jk-dsub-staging/logging}

LOGGING_PATH=$LOGGING_PATH/$(date +"%Y-%m-%d-%M-%S")


dsub \
--provider $DSUB_PROVIDER \
--script $SCRIPT \
--project $PROJECT \
--regions $REGION \
--min-ram $MIN_RAM \
--min-cores $MIN_CORES \
--disk-size $DISK_SIZE \
--image $IMAGE \
--logging $LOGGING_PATH \
--tasks $TASKS







