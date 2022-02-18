
download_file=$1
echo "downloading files found in ${download_file}"
while read p; do
	gsutil -m cp -r "${p}" ./temp_data
done < "${download_file}"
