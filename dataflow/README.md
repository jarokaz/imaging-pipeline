# Dataflow

```
IMAGE_URL=gcr.io/jk-mlops-dev/dicom-dataflow

docker run -it --rm \
-v /home/jupyter/imaging-pipeline/dataflow:/src \
--entrypoint /bin/bash \
$IMAGE_URL
```


## Local testing

```

DICOM_PATH=gs://jk-imaging/small_shard
OUTPUT_PATH_PREFIX=gs://jk-imaging/dataflow/t12

python  run.py \
  --dicom-path gs://jk-imaging/small_shard \
  --output-path-prefix gs://jk-imaging/dataflow/t12 \
  --runner DirectRunner 

```

```
DICOM_PATH=gs://jk-imaging/small_shard
OUTPUT_PATH_PREFIX=gs://jk-imaging/dataflow/t12

python  run.py \
  --dicom-path gs://jk-imaging/small_shard \
  --output-path-prefix gs://jk-imaging/dataflow/t12 \
  --runner=PortableRunner \
  --environment_type=DOCKER \
  --environment_config=$IMAGE_URL \
  --job_endpoint=embed

```

## Dataflow  job

```
export IMAGE_URI=gcr.io/jk-mlops-dev/dicom-dataflow:latest
export DICOM_PATH=gs://jk-imaging/small_shard
export OUTPUT_PATH_PREFIX=gs://jk-imaging/dataflow/t12
export BUCKET=gs://jk-dataflow-staging
export TEMP_LOCATION='gs://$BUCKET/temp'

export PROJECT_ID=jk-mlops-dev
export REGION=us-central1
export GCS_PATH=gs://jk-imaging
export JOB_NAME="dicom-$(date +%Y%m%d-%H%M%S)"

export DICOM_PATH=gs://jk-imaging/data/kaggle-xray-seq
export OUTPUT_PATH_PREFIX=gs://jk-imaging/dataflow/t100

python  run.py \
  --dicom-path $DICOM_PATH \
  --output-path-prefix  $OUTPUT_PATH_PREFIX \
  --runner=DataflowRunner \
  --project=$PROJECT_ID \
  --region=$REGION \
  --job_name=$JOB_NAME \
  --temp_location=$TEMP_LOCATION \
  --worker_machine_type=n1-standard-8 \
  --sdk_container_image=$IMAGE_URI \
  --experiment=use_runner_v2 \
  --experiment=no_use_multiple_sdk_containers \
  --disk_size_gb=50
```


