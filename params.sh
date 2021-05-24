#
# These variables are subsituted into templates buy run-terraform.sh
#

# Terraform Variables - terraform/variables.tf.template -> terraform/variables.tf
#
TF_AWS_INSTANCE_PREFIX=dse
TF_AWS_DOMAINNAME=testdse.example.com
TF_AWS_OWNER_TAG=myusername
TF_AWS_EXPIRATION_TAG=6h
TF_AWS_PURPOSE_TAG="dse cluster"
#
TF_AWS_KEY_NAME=myawssshkeyname
#
# route53 zone id to place subdomain
TF_AWS_ROUTE53_ZONE_ID=Z0000000000000000000
#
TF_AWS_REGION=eu-west-2
TF_AWS_AVAILABILITY_ZONES=eu-west-2a,eu-west-2b,eu-west-2c
#
# aws --region eu-west-2 ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce | egrep 'CreationDate|Description|ImageId'
# Centos 7 2020_01 - eu-west-2 / London:
TF_AWS_CENTOS_AMI=ami-09e5afc68eed60ef4

#
TF_AWS_NODE_COUNT=3
TF_AWS_DATA_VOLUME_SIZE=50
#
TF_AWS_BOOTSTRAP_INSTANCE_TYPE=t2.medium
#TF_AWS_NODE_INSTANCE_TYPE=t2.large
#TF_AWS_NODE_INSTANCE_TYPE=m4.2xlarge
TF_AWS_NODE_INSTANCE_TYPE=m4.xlarge


# for ansible
ANSIBLE_SSH_PRIVATE_KEY_FILE="\~\/.ssh\/myawssshkeyname"
ANSIBLE_USER=centos

# Extra Config Variables
DSE_ADMIN_USERNAME=dseadmin
DSE_ADMIN_PASSWORD=mydseadminpwdvalue

# tar file from: https://downloads.datastax.com/datastax-studio/
DSE_STUDIO_DOWNLOAD="datastax-studio-6.8.0.tar.gz"
DSE_CLUSTER_NAME="DSE"
# GossipingPropertyFileSnitch uses cassandra-rackdc.properties config
# PropertyFileSnitch uses cassandra-topology.properties config
DSE_ENDPOINT_SNITCH="GossipingPropertyFileSnitch"
DSE_SPARK_ENABLED=0
DSE_SOLR_ENABLED=1
DSE_GRAPH_ENABLED=1


