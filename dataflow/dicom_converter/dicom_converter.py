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
import hashlib
import json
import logging
import os
import pathlib
import random
import re
from typing import Any, Dict, List, Optional, Tuple

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import numpy as np
import pydicom
import tensorflow as tf


class JsonCoder(object):
  """A JSON coder interpreting each line as a JSON string."""
  def encode(self, x):
    return json.dumps(x).encode('utf-8')

  def decode(self, x):
    return json.loads(x)


def parse_dicom_image(image_path: str) -> Dict:
    """Loads a dicom image."""

    with tf.io.gfile.GFile(image_path, "rb") as f:
        ds = pydicom.dcmread(f)
    
    # TODO: This is just a example
    # We need to define what metadata to extract
    # and how to handle DICOM without PixelData
    parsed_dicom = {}
    parsed_dicom['pixel_array'] = ds.pixel_array
    parsed_dicom['StudyID'] = str(ds['StudyID'])
    parsed_dicom['StudyDate'] = str(ds['StudyDate'])
    parsed_dicom['dicom_path'] = image_path
    
    return parsed_dicom


def extract_and_save_png(parsed_dicom_image: Dict, image_path_prefix: str) -> Dict:
    
    if 'pixel_array' in parsed_dicom_image:
        filename = pathlib.Path(parsed_dicom_image['dicom_path']).stem
        #random_number = random.randint(0,16777215)
        #hex_number = str(hex(random_number))
        hash_number = hashlib.sha224(filename.encode('utf-8')).hexdigest()
        img_path = f'{image_path_prefix}/{hash_number}-{filename}.png'
        parsed_dicom_image['png_path'] = img_path
        
        # TODO: We assume grey scale pixel data. Check for RGB
        image_2d = parsed_dicom_image['pixel_array'].astype(float)
        image_2d_scaled = (np.maximum(image_2d,0) / image_2d.max()) * 255.0
        image_2d_scaled = np.uint8(image_2d_scaled)
        image_2d_scaled = np.expand_dims(image_2d_scaled, axis=2)
        png = tf.io.encode_png(image_2d_scaled)
        with tf.io.gfile.GFile(img_path, "wb") as f:
            f.write(png.numpy())
            
        parsed_dicom_image.pop('pixel_array', None)
    
    return parsed_dicom_image



def process_dicom(
    dicom_path: str,
    output_path_prefix: str,
    pipeline_options: Optional[PipelineOptions] = None,
) -> None:
    """Extract PNG images and metadata from DICOM."""
    
    image_path_prefix = f'{output_path_prefix}/images'
    metadata_path_prefix = f'{output_path_prefix}/metadata/metadata-'
    
    # TODO: decide how to handle input paths in a more 
    # flexible way
    images = [f'{dicom_path}/{filename}' for filename in tf.io.gfile.listdir(dicom_path)]
    
    with beam.Pipeline(options=pipeline_options) as p:
    
        _ = (p
            | "Get image paths" >> beam.Create(images)
            | "Parse DICOM image" >> beam.Map(parse_dicom_image)
            | "Extract PNG" >> beam.Map(extract_and_save_png, image_path_prefix)
            | "Save Metadata" >> beam.io.WriteToText(metadata_path_prefix, coder=JsonCoder())
            )
    
