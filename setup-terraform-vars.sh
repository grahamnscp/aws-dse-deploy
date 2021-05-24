#!/bin/bash

source ./params.sh

# sed -i has extra param in OSX
SEDBAK=""

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac
                SEDBAK=".bak"
                ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac
echo OS is ${MACHINE}




# Subsitute terraform variables to generate variables.tf
echo ">>> Generating Terraform ./terraform/variables.tf file from variables.tf.template.."
cp ./templates/variables.tf.template ./terraform/variables.tf

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##TF_AWS_OWNER_TAG##/$TF_AWS_OWNER_TAG/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_EXPIRATION_TAG##/$TF_AWS_EXPIRATION_TAG/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_PURPOSE_TAG##/$TF_AWS_PURPOSE_TAG/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_KEY_NAME##/$TF_AWS_KEY_NAME/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_INSTANCE_PREFIX##/$TF_AWS_INSTANCE_PREFIX/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOMAINNAME##/$TF_AWS_DOMAINNAME/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_ROUTE53_ZONE_ID##/$TF_AWS_ROUTE53_ZONE_ID/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_REGION##/$TF_AWS_REGION/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_AVAILABILITY_ZONES##/$TF_AWS_AVAILABILITY_ZONES/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_CENTOS_AMI##/$TF_AWS_CENTOS_AMI/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_NODE_COUNT##/$TF_AWS_NODE_COUNT/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_DATA_VOLUME_SIZE##/$TF_AWS_DATA_VOLUME_SIZE/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_BOOTSTRAP_INSTANCE_TYPE##/$TF_AWS_BOOTSTRAP_INSTANCE_TYPE/" ./terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_NODE_INSTANCE_TYPE##/$TF_AWS_NODE_INSTANCE_TYPE/" ./terraform/variables.tf

rm ./terraform/variables.tf.bak

exit 0

