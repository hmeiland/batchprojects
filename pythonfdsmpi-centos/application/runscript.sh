#!/bin/bash

# some comments to make sure the file is a little over 1K since otherwise it seems that the blob upload does not really understand it....
# some comments to make sure the file is a little over 1K since otherwise it seems that the blob upload does not really understand it....
# some comments to make sure the file is a little over 1K since otherwise it seems that the blob upload does not really understand it....
# some comments to make sure the file is a little over 1K since otherwise it seems that the blob upload does not really understand it....
# some comments to make sure the file is a little over 1K since otherwise it seems that the blob upload does not really understand it....

export SCRIPT_NAME=$0
export INPUT_FILE=$1
export PROJECT_NAME=$2
export SHORT_NAME=${PROJECT_NAME::-4}
echo "# full line"
echo $0 $1 $2
echo "# input file: $INPUT_FILE"
echo "# project: $PROJECT_NAME $SHORT_NAME"

export LD_LIBRARY_PATH=$AZ_BATCH_NODE_SHARED_DIR:$LD_LIBRARY_PATH
export PATH=./:$PATH
#export I_MPI_FABRICS=tcp  #no rdma so using tcp here...
export I_MPI_FABRICS=shm:dapl  #no rdma so using tcp here...
export I_MPI_DAPL_PROVIDER=ofa-v2-ib0
export I_MPI_DYNAMIC_CONNECTION=0

env

cd $AZ_BATCH_TASK_SHARED_DIR
cd share
cp $AZ_BATCH_NODE_SHARED_DIR/* .

#mpirun -hosts $AZ_BATCH_HOST_LIST -np 8 ./fds circular_burner.fds 
mpirun -hosts $AZ_BATCH_HOST_LIST -np 8 ./fds $PROJECT_NAME 

zip fds_results.zip ${SHORT_NAME}* 
cp fds_results.zip ../wd/
