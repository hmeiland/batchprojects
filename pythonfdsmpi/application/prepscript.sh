#!/bin/bash
export master_addr_port=(${AZ_BATCH_MASTER_NODE//:/ })
export master_addr=${master_addr_port[0]}
export mnt=$AZ_BATCH_TASK_SHARED_DIR
mkdir -p /home/myuser/.ssh
chmod 700 /home/myuser/.ssh
echo 'StrictHostKeyChecking no' >> /home/myuser/.ssh/config
chmod 600 /home/myuser/.ssh/config
if $AZ_BATCH_IS_CURRENT_NODE_MASTER; then
    # is head node, will be nfs server, will download and prepare all the input data in nfs share dir
    ssh-keygen -t rsa -b 2048 -N "" -f /home/myuser/.ssh/id_rsa
    cat /home/myuser/.ssh/id_rsa.pub >> /home/myuser/.ssh/authorized_keys
    chmod 600 /home/myuser/.ssh/authorized_keys
    ls
    mkdir $mnt/share
    chmod 777 -R $mnt/share
    echo "$mnt/share      10.0.0.0/24(rw,sync,no_root_squash,no_all_squash)" | sudo tee --append /etc/exports
    sudo  systemctl restart nfs-server
    sudo  exportfs -v
    cd $mnt/share
    cp $AZ_BATCH_TASK_WORKING_DIR/* .
    cp /home/myuser/.ssh/id_rsa.pub .
else
    # all other nodes are nfs clients, will connect with nfs server on nfs share dir
    echo mkdir -p $mnt/share
    mkdir -p $mnt/share
    echo "$master_addr:$mnt/share    $mnt/share   nfs defaults 0 0" | sudo tee --append /etc/fstab 
    sudo cat /etc/fstab
    while :
    do
        echo "Looping"
        sudo mount -a
        sudo mountpoint -q $mnt/share
        if [ $? -eq 0 ]; then
            break
        else
            sleep 10
        fi
    done
    cat $mnt/share/id_rsa.pub > /home/myuser/.ssh/authorized_keys
    chmod 600 /home/myuser/.ssh/authorized_keys
fi
exit
