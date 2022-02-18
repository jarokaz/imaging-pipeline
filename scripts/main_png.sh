#!/bin/bash
main_dir="/home/jupyter/failed_dcms"
niffler_dir="/home/jupyter/failed_dcms/Niffler/modules/png-extraction/"
data_dir="/home/jupyter/failed_dcms/temp_data"
data_bucket="gs://ml-bf1c-phi-shared-aif-us-p/data/US_elasto_png/florida_repull"
#folder contains files with gcp uri's  to folders containing dicom files  
for f in ./florida_to_extract/*; do 
	echo " ----- ${f} -----"
	mkdir ./temp_data
    #download required files 
	echo " --- Going to pull file ${f}-------- "
	bash copy_studies.sh "${f}" 
	echo " --- pull complete --- "
	echo "Going to start niffler extraction" 
    #name output folder based on input files name convention 
	outputs="$(cut -d  "/"  -f 3 <<< "${f}")"
	outputs="$(cut -d  "."  -f 1 <<< "${outputs}")"
    echo "Out dir is ${outputs}"
	out_dir="${main_dir}/${outputs}"
    #niffler execution start's from the repo's directory due to local imports 
	cd  "${niffler_dir}"
	echo " I am at : ${niffler_dir}"
	echo "Out dir will be ${out_dir}"
	echo "-------Initiate Extraction------" 
	python3 ImageExtractor.py --DICOMHome ${data_dir} --OutputDirectory ${out_dir} --Depth 1 --PrintImages true --is16Bit false --CommonHeadersOnly true --SplitIntoChunks 5 --FlattenedToLevel patient
	echo "-------finish Extraction-----" 
	cd  "${main_dir}"
	echo "data_copy: START --------"
    #upload studies 
	gsutil -m cp -r "${out_dir}" "${data_bucket}"
	echo "data_copy: END --------"
    #clean up 
	echo "data_clear: START------"
	rm -r "${out_dir}"
	rm -r "./temp_data"
	echo "data_clear: END------"
done; 

sudo poweroff 
