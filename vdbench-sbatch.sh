#!/bin/bash
#SBATCH --job-name=nfs-vdbench
##SBATCH --partition=default
#SBATCH -N 24
#SBATCH --exclusive

# arg: $1 = NFS mountpoint to test (ie. /avere )
testmount=$1

FILENAME="$testmount/vdbench/azure-clients.conf"
rm -f $FILENAME

if [ -d "$testmount/vdbench" ]; then
    echo "$testmount/vdbench exists"
else
    mkdir $testmount/vdbench
    chmod -R 777 $testmount/vdbench
fi

NODE_PREFIX="host"
/bin/cat <<EOM >$FILENAME
create_anchors=yes
hd=default,user=${USER},shell=ssh
EOM

scontrol show hostnames $SLURM_JOB_NODELIST > tmp-nodefile-$SLURM_JOB_ID
while IFS= read -r line
do
  scontrol show node "$line" | grep -oE "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" >> nodefile-$SLURM_JOB_ID-tmp
done < "tmp-nodefile-$SLURM_JOB_ID"
uniq nodefile-$SLURM_JOB_ID-tmp nodefile
rm nodefile-$SLURM_JOB_ID-tmp tmp-nodefile-$SLURM_JOB_ID

echo "cat nodefile:"
cat nodefile

COUNTER=0
uniq nodefile |
{
while read i; do
    HOST_NUMBER=$(($COUNTER + 1))
    HOST_NUMBER_HEX=$( printf '%02x' $HOST_NUMBER )
    NODE_NAME="${NODE_PREFIX}-${COUNTER}"
    ###IP=$( getent hosts ${i} |  awk '{print $1}' )
    echo "NODE NAME ${NODE_NAME}, ${i}"
    echo "hd=host${HOST_NUMBER_HEX},system=${i}" >> $FILENAME
    COUNTER=$[$COUNTER+1]
done
}

batchHost=$(scontrol show job $SLURM_JOB_ID | grep BatchHost | cut -d\= -f2)
srun -N 1 -w $batchHost /shared/apps/vdbench/vdbench-local.sh $testmount
