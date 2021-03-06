# cyclecloud-vdbench
This repo will run vdbench against a storage target using an Azure CycleCloud compute cluster


## Download vdbench
Accept terms and download `vdbench50407.zip` from [Oracle](https://www.oracle.com/downloads/server-storage/vdbench-downloads.html)

_**NOTE**: The vdbench User Guide is also available on the Oracle download page_


## Stage files
SSH to your cluster scheduler node (aka *head node*) and run the following commands:

  ```bash
  sudo mkdir -p /shared/apps/vdbench
  sudo chmod 777 /shared/apps/vdbench
  git clone https://github.com/themorey/cyclecloud-vdbench.git /shared/apps/vdbench
  #NOTE:  install git if needed:  sudo yum install -y git
  ```

Copy (ie. scp) *vdbench50407.zip* to your scheduler node and unzip it into `/shared/apps/vdbench`...ie:

  ```bash
  sudo unzip vdbench50407.zip -d /shared/apps/vdbench/
  ```
  
Run the following commands to unzip the filesystem tests into the appropriate directory:

  ```bash
  sudo mkdir -p /shared/apps/vdbench/benchmarks/vdbench/
  sudo unzip /shared/apps/vdbench/filesys.zip -d /shared/apps/vdbench/benchmarks/vdbench/
  sudo chmod -R +x /shared/apps/vdbench
  ```

## Run with Slurm cluster

The script named *vdbench-sbatch.sh* will schedule this job to run across 24 execute (aka *worker*) nodes in the Slurm cluster.  You can modify the partition and # of compute nodes requested by modifyig the following script lines:

  ```bash
  # change partition from default to htc
  sudo sed -i 's/##SBATCH --partition=default/#SBATCH --partition=htc/g' /shared/apps/vdbench/vdbench-sbatch.sh
  
  # change # of execute nodes from 24 to 12
  sudo sed -i 's/#SBATCH -N 24/#SBATCH -N 12/g' /shared/apps/vdbench/vdbench-sbatch.sh
  ```

Run the following command as follows to submit the job to Slurm:  

  _**NOTE**:  Run with a user account that has passwordless sudo as the scripts need to mkdir, install openjdk, etc_

  ```bash
  sbatch /shared/apps/vdbench/vdbench-sbatch.sh /data
  ```
  
In the above submission example the argument `/data` is the mountpoint to benchmark with vdbench.  This could be an HPC Cache export, xNFS on Blob, Azure Files NFS, Azure NetApp Files, etc.

## Results

This will write test data to `/data/vdbench` and at the end write output/error files to `/data/vdbench-output` (assuming your test mountpoint is `/data`)

__NOTE:__  The *vdbench-local.sh* script uses the local ephemeral disk on the compute VM.  If usiing a VM size without an ephemeral disk you will need to modify the *vdbench-local.sh* script to a supported path for writing the output file
