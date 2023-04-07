#!/bin/bash
set -o xtrace

# see https://github.com/awslabs/amazon-eks-ami/issues/318
# and https://stackoverflow.com/questions/63759047/kubelet-stopped-posting-node-status-and-node-inaccessible
# for handling OOM error from kubelet itself
/etc/eks/bootstrap.sh ${ClusterName} --kubelet-extra-args "--node-labels=eks.amazonaws.com/nodegroup-image=${AmiId},eks.amazonaws.com/nodegroup=${GroupName} --kube-reserved memory=0.3Gi,ephemeral-storage=1Gi --system-reserved memory=0.2Gi,ephemeral-storage=1Gi --eviction-hard memory.available<200Mi,nodefs.available<10%"
