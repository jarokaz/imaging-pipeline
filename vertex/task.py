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


from absl import logging
from absl import flags
from absl import app


FLAGS = flags.FLAGS

logging.set_verbosity(logging.INFO)

flags.DEFINE_string(
    'fasta_path', None, 'A path to FASTA file')

flags.DEFINE_list(
    'database_paths', None, 'Paths to a list of sequence databases to search')
flags.DEFINE_string('output_dir', None, 'Path to a directory that will '
                    'store the results.')
flags.DEFINE_integer(
    'n_cpu', 4, 'The number of CPUs to give Jackhmmer'
)
flags.DEFINE_integer(
    'max_sto_sequences', 501, 'A maximum number of sequences to use for template search'
)
flags.DEFINE_string('hmmsearch_binary_path', shutil.which('hmmsearch'),
                    'Path to the hmmsearch  executable.')
flags.DEFINE_string('hmmbuild_binary_path', shutil.which('hmmbuild'),
                    'Path to the hmmbuild executable.')


def _main(argv):
    print('Hello')


if __name__=='__main__':
    app.run(_main)