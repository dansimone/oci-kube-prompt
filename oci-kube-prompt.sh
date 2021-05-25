#!/bin/bash

CLUSTER_INFO_DIR=~/.oci/clusters

fetch_oci_clusters()
{
    mkdir -p ${CLUSTER_INFO_DIR}
    declare -a regions=("us-ashburn-1" "us-phoenix-1" "uk-london-1" "eu-frankfurt-1" "ap-seoul-1" "ap-tokyo-1" "ca-toronto-1")
    for region in "${regions[@]}"
    do
        echo "Processing Region: ${region}"
        sed '/^region.*/d' ~/.oci/config > ${CLUSTER_INFO_DIR}/config
        chmod 600 ${CLUSTER_INFO_DIR}/config
        echo region=$region >> ${CLUSTER_INFO_DIR}/config
        oci iam compartment list --all | jq '.data[].id' | while read -r compartment_ocid ; do
            compartment_ocid="${compartment_ocid%\"}"
            compartment_ocid="${compartment_ocid#\"}"
            echo "  Processing Compartment: ${compartment_ocid}"
            echo oci ce cluster list --compartment-id ${compartment_ocid} --config-file ${CLUSTER_INFO_DIR}/config | bash | jq '.data[].id' | while read -r cluster_ocid ; do
                cluster_name=`echo oci ce cluster get --cluster-id ${cluster_ocid} --config-file ${CLUSTER_INFO_DIR}/config | bash | jq '.data.name'`
                cluster_name="${cluster_name%\"}"
                cluster_name="${cluster_name#\"}"
                cluster_ocid="${cluster_ocid%\"}"
                cluster_ocid="${cluster_ocid#\"}"
                echo "    Adding Cluster: ${cluster_ocid}"
                echo ${region}/${cluster_name} > ${CLUSTER_INFO_DIR}/${cluster_ocid}
            done
        done
        rm ${CLUSTER_INFO_DIR}/config
    done
}

# TODO - Add support for other vendors here
fetch_gke_clusters()
{
    :
}

__oci_cluster_name()
{
    if [ -z ${KUBECONFIG+x} ]
    then
        echo ""
    else
        ocid=`cat ${KUBECONFIG} | grep ocid1.cluster.oc1`
        ocid=`echo ${ocid} | awk '{print $2}'`
        if ls ${CLUSTER_INFO_DIR}/*$ocid 1> /dev/null 2>&1; then
            echo "(`cat ${CLUSTER_INFO_DIR}/*${ocid}`)"
        else
            echo "(unknown OKE cluster)"
        fi
    fi
}
