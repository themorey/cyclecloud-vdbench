#!/bin/bash

# arg: $1 = NFS mountpoint to test (ie. /avere )
testmount=$1

FILENAME="$testmount/vdbench/azure-clients.conf"

# Install pssh and use it to install openjdk on all the nodes in the Slurm job
sudo yum install -y pssh
pssh -i -h nodefile "sudo yum install -y java-latest-openjdk ; sudo chmod -R 777 /mnt/resource"

# Create the associative array that contains the job name and threads per host values
declare -A threadsperhost
threadsperhost=( ["00_fsd1_format"]=6 ["00_fsd2_format"]=6 ["01_large_10_90_throughput"]=6 ["02_large_50_50_throughput"]=6 ["03_large_90_10_throughput"]=6 ["04_max_read_iops"]=64 ["05_max_read_throughput"]=6 ["06_max_write_iops"]=64 ["07_max_write_throughput"]=6 ["08_small_10_90_throughput"]=64 ["09_small_50_50_throughput"]=64 ["10_small_90_10_throughput"]=64  )
 
# Create a declarative array to index the jobs so they run in order
declare -a orderjobs
orderjobs=( "00_fsd1_format" "00_fsd2_format" "01_large_10_90_throughput" "02_large_50_50_throughput" "03_large_90_10_throughput" "04_max_read_iops" "05_max_read_throughput" "06_max_write_iops" "07_max_write_throughput" "08_small_10_90_throughput" "09_small_50_50_throughput" "10_small_90_10_throughput" )

#move to /shared/apps/vdbench as fsd files are relative to that path
cd /shared/apps/vdbench

# Loop through the array(s) to run the vdbench jobs
for K in "${orderjobs[@]}"; do
    /shared/apps/vdbench/vdbench -f /shared/apps/vdbench/benchmarks/vdbench/filesys/$K includeFile=$FILENAME lun=$testmount/vdbench threadsPerHost=${threadsperhost[$K]} -o /mnt/resource/job_${K}_node_$(jetpack config hostname)_$(date +"%Y%m%d_%I%M%p").out
    wait
done

cp /mnt/resource/{*.out,*.err} $testmount/vdbench-output/
rm -rf $testmount/vdbench/fsd*
