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

import time
import sys

from absl import logging
from absl import flags
from absl import app

from google.cloud import aiplatform

FLAGS = flags.FLAGS

logging.set_verbosity(logging.INFO)

flags.DEFINE_string('project', 'jk-mlops-dev', 'GCP Project')
flags.DEFINE_string('region', 'us-central1', 'GCP Region')
flags.DEFINE_string('staging_bucket', 'gs://jk-imaging-staging', 'Staging bucket')
flags.DEFINE_string('machine_type', 'n1-standard-16', 'Machine type')
flags.DEFINE_string('image', 'gcr.io/jk-mlops-dev/dicom-processor', 'Image')

flags.DEFINE_integer('replica_count', 3, 'Replica count')
flags.DEFINE_string('inputs', 'gs://jk-imaging/data/shard1,gs://jk-imaging/data/shard2,gs://jk-imaging/data/shard3', 'List of folders to process.')
flags.DEFINE_string('outputs', 'gs://jk-imaging/outputs/test12', 'Outputs')


def _main(argv):

    job_name = 'PROCESS_IMAGE_{}'.format(time.strftime("%Y%m%d_%H%M%S"))
    
    machine_spec = {
        "machine_type": FLAGS.machine_type,
    }
    container_spec = {
        "image_uri": FLAGS.image,
        "args": [ 
            #"-g",
            FLAGS.inputs,
            FLAGS.outputs,
        ],
    } 

    worker_pool_specs =  [
        {
            "machine_spec": machine_spec, 
            "replica_count": 1,
            "container_spec": container_spec
        }
    ]
    if FLAGS.replica_count > 1:
        replica_count = FLAGS.replica_count - 1
        worker_pool_specs.append(
            {
                "machine_spec": machine_spec, 
                "replica_count": replica_count,
                "container_spec": container_spec 
            }
        )


    logging.info(f'Starting job: {job_name}')

    job = aiplatform.CustomJob(
        display_name=job_name,
        worker_pool_specs=worker_pool_specs,
        staging_bucket=FLAGS.staging_bucket
        
    )
    job.run(sync=True,
            restart_job_on_worker_restart=False,
    )


if __name__=='__main__':
   app.run(_main)