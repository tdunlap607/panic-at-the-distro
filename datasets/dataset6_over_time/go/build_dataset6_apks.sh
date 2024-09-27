#!/bin/bash

# Array of folder names
# folders=("0_controller-gen" "1_gobump" "2_logstash-exporter" "3_prometheus-beat-exporter" "4_cosign" "5_step" "6_go-swagger" "7_grafana-agent-operator" "8_terragrunt" "9_litestream")
folders=("0_controller-gen")

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

  # Return to the original directory
  cd ..
done