#!/bin/bash

# Array of folder names
# folders=("0_controller-gen" "1_gobump" "2_logstash-exporter" "3_prometheus-beat-exporter" "4_cosign" "5_step" "6_go-swagger" "7_grafana-agent-operator" "8_terragrunt" "9_litestream")
folders=("0_controller-gen")

# Get your username
username=$(whoami)

# Loop through each folder
for folder in "${folders[@]}"; do
  # Change to the folder
  cd "$folder" || { echo "Failed to enter folder $folder"; continue; }

  # Run keygen command
  docker run --rm -v "${PWD}":/work cgr.dev/chainguard/melange keygen

  # Find all .yaml files and run the build command on each
  for yaml_file in *.yaml; do
    docker run --privileged --rm -v "${PWD}":/work cgr.dev/chainguard/melange build /work/"${yaml_file}" --arch x86_64 --signing-key melange.rsa
  done

  # Change ownership of the packages folder to your username
  if [ -d "packages/x86_64" ]; then
    sudo chown -R "$username":"$username" packages/x86_64/
  fi

  # Create the apk-files directory if it doesn't exist and change ownership
  mkdir -p apk-files
  sudo chown -R "$username":"$username" apk-files

  # Copy .apk files to apk-files directory
  if [ -d "packages/x86_64" ]; then
    cp packages/x86_64/*.apk apk-files/
    echo "Copied .apk files to $folder/apk-files/"
  else
    echo "No .apk files found in $folder/packages/x86_64/"
  fi

  # Return to the original directory
  cd ..
done
