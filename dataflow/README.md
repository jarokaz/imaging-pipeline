# Dataflow sample

```
IMAGE_URL=gcr.io/jk-mlops-dev/dicom-dataflow
GCP_PROJECT=jk-mlops-dev
REGION=us-central1
GCS_PATH=gs://jk-imaging

python  process_images.py \
  --dicom-path gs://jk-imaging/small_shard \
  --output-path-prefix gs://jk-imaging/dataflow/t11 \
  --runner DataflowRunner \
  --project $GCP_PROJECT \
  --region $REGION \
  --temp_location "${GCS_PATH}/tmp/" \
  --experiment=use_runner_v2 \
  --sdk_container_image=$IMAGE_URL
```