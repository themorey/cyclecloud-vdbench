# cyclecloud-vdbench
This repo will run vdbench against a storage target using an Azure CycleCloud compute cluster


## Download vdbench
Accept terms and download `vdbench50407.zip` from [Oracle](https://www.oracle.com/downloads/server-storage/vdbench-downloads.html)


## Stage files
SSH to your cluster scheduler node (aka *head node*) and run the following commands:

  ```bash
  mkdir -p /shared/apps/vdbench
  git clone https://github.com/themorey/cyclecloud-vdbench.git /shared/apps/vdbench
  ```

Copy (ie. scp) *vdbench50407.zip* to your scheduler node and unzip it into `/shared/apps/vdbench`...ie:

  ```bash
  unzip vdbench50407.zip -d /shared/apps/vdbench
  ```
  
Run the following commands to unzip the filesystem tests into the appropriate directory:

  ```bash
  mkdir -p /shared/apps/vdbench/benchmarks/vdbench/
  unzip /shared/apps/vdbench/filesys.zip -d /shared/apps/vdbench/benchmarks/vdbench/
  sudo chmod -R +x /shared/apps/vdbench
  ```

## Run with Slurm cluster

The script named *vdbench-sbatch.sh* will schedule this job to run across 24 execute (aka *worker*) nodes in the Slurm cluster.  You can modify the partition and # of compute nodes requested by modifyig the following script lines:

  ```bash
  # change partition from default to htc
  sed 's/##SBATCH --partition=default/#SBATCH --partition=htc/g' /shared/apps/vdbench/vdbench-sbatch.sh
  
  # change # of execute nodes from 24 to 12
  sed 's/#SBATCH -N 24/#SBATCH -N 12/g' /shared/apps/vdbench/vdbench-sbatch.sh
  ```

Run the following command as follows to submit the job to Slurm:

  ```bash
  sbatch /shared/apps/vdbench/vdbench-sbatch.sh /data
  ```
  
In the above submission example the argument `/data` is the mountpoint to benchmark with vdbench.  This could be an HPC Cache export, xNFS on Blob, Azure Files NFS, Azure NetApp Files, etc.

## Results

This will write test data to `/data/vdbench` and at the end write output/error files to `/data/vdbench-output` (assuming your test mountpoint is `/data`)
