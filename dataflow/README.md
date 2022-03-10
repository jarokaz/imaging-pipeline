# Dataflow based DICOM processer

This prototype uses Dataflow custom containers.

To build a container

```
./build_container.sh <YOUR PROJECT ID>
```

## Running the job

To avoid Dataflow Python package compatibility issues submit the job using the same container that is used on Dataflow workers

```
PROJECT=jk-mlops-dev
IMAGE_URL=gcr.io/$PROJECT/dicom-dataflow

docker run -it --rm \
--entrypoint /bin/bash \
$IMAGE_URL
```

To start a Dataflow job execute the following command from the custom container. Make sure to adjust
constants to reflect your environment.

```
export PROJECT_ID=jk-mlops-dev
export REGION=us-central1

export IMAGE_URI=gcr.io/$PROJECT_ID/dicom-dataflow:latest
export STAGING_BUCKET=gs://jk-dataflow-staging
export TEMP_LOCATION='gs://$BUCKET/temp'

export JOB_NAME="dicom-$(date +%Y%m%d-%H%M%S)"
export DICOM_PATH=gs://jk-dicom-images
export OUTPUT_PATH_PREFIX=gs://jk-imaging/dataflow/t999

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



## Local testing

You can test locally using the container and DirectRunner

```
PROJECT=jk-mlops-dev
IMAGE_URL=gcr.io/$PROJECT/dicom-dataflow

docker run -it --rm \
-v /home/jupyter/imaging-pipeline/dataflow:/src \
--entrypoint /bin/bash \
$IMAGE_URL
```

```

DICOM_PATH=gs://jk-imaging/dicom
OUTPUT_PATH_PREFIX=gs://jk-imaging/dataflow/t12

python  run.py \
  --dicom-path $DICOM_PATH \
  --output-path-prefix $OUTPUT_PATH_PREFIX \
  --runner DirectRunner 

```





