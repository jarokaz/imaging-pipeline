#!/usr/bin/env python

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

"""This Apache Beam pipeline processes DICOM images.
"""

import argparse
import json
import logging
import os
from typing import Any, Dict, List, Optional, Tuple

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, SetupOptions

from dicom_converter.dicom_converter import process_dicom

#_SETUP_FILE = './setup.py'


if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-path-prefix",
        required=True,
        help="Path prefix for output image files. "
        "This can be a Google Cloud Storage path.",
    )
    
    parser.add_argument(
        "--dicom-path",
        required=True,
        help="Path to DICOM images to process. "
        "This can be a Google Cloud Storage path.",
    )
   

    args, beam_args = parser.parse_known_args()
    pipeline_options = PipelineOptions(beam_args)
    #pipeline_options.view_as(SetupOptions).setup_file = _SETUP_FILE
    
    process_dicom(args.dicom_path, args.output_path_prefix, pipeline_options)
