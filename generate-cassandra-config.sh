#!/bin/bash

source ./params.sh

TMP_FILE=/tmp/generate-dse-topology.tmp.$$

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


# Collect output variables
echo
echo ">>> Collecting variables from terraform output.."
terraform output > $TMP_FILE

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g'`

  #echo LINE:$var_name: $var_value

  case $var_name in
    "region")
      REGION="$var_value"
      ;;
    "domain_name")
      DOMAIN_NAME="$var_value"
      ;;

    "route53-admin")
      ADMIN_LB_FQDN="$var_value"
      ;;

    # Bootstrap:
    "route53-bootstrap")
      BOOTSTRAP_NAME="$var_value"
      ;;

    "bootstrap-public-name")
      BOOTSTRAP_PUBLIC_NAME=$var_value
      ;;
    "bootstrap-public-ip")
      BOOTSTRAP_PUBLIC_IP=$var_value
      ;;

    # nodes:
    "route53-nodes")
      NODES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_NAME[$COUNT]=$entry
      done
      NUM_NODES=$COUNT
      ;;
    "node-public-names")
      NODES_PUBLIC_NAMES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_NAME[$COUNT]=$entry
      done
      ;;
    "node-public-ips")
      NODE_PUBLIC_IPS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_IP[$COUNT]=$entry
      done
      ;;
    "node-private-ips")
      NODE_PRIVATE_IPS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PRIVATE_IP[$COUNT]=$entry
      done
      ;;

  esac
done

echo ">>> done."


# Generate the DSE config files
#
echo

# cassandra.yaml
#
echo ">>> Generating cassandra.yaml.."
cp ./templates/cassandra.yaml ./working-files/

sed -i $SEDBAK "s/##DSE_CLUSTER_NAME##/${DSE_CLUSTER_NAME}/" ./working-files/cassandra.yaml
sed -i $SEDBAK "s/##DSE_ENDPOINT_SNITCH##/${DSE_ENDPOINT_SNITCH}/" ./working-files/cassandra.yaml
# DSE_SEED_IPS - first 3 nodes only as seed nodes
DSE_SEED_IPS=""
for (( COUNT=1; COUNT<=3; COUNT++ ))
do
  if [ "$DSE_SEED_IPS" = "" ]
  then
    DSE_SEED_IPS=`echo "${NODE_PRIVATE_IP[$COUNT]}"`
  else
    DSE_SEED_IPS=`echo "${DSE_SEED_IPS},${NODE_PRIVATE_IP[$COUNT]}"`
  fi
done
sed -i $SEDBAK "s/##DSE_SEED_IPS##/${DSE_SEED_IPS}/" ./working-files/cassandra.yaml
# LISTEN_ADDRESS - local to each node.. embed in ansible config script..
# ? native_transport_address: localhost
#   PropertyFileSnitch uses: cassandra-topology.properties.
#   GossipingPropertyFileSnitch uses: cassandra-rackdc.properties
# note: should set internode_encryption: dc
# note: encryption at rest disabled by default, transparent_data_encryption_options settings


# dse.yaml
#
echo ">>> Generating dse.yaml.."
cp ./templates/dse.yaml ./working-files/
# note: authentication options
# note: audit_logging_options disabled by default
# note: system_info_encryption disabled by default
# note: tiered_storage_options not set by default
# note: internode_messaging_options port is: 8609
# note: gremlin_server port is: 8182


# cassandra-topology.properties
#
echo ">>> Generating cassandra-topology.properties.."

CASS_TOP_FILE=./working-files/cassandra-topology.properties

echo "# Cassandra Node IP=Data Center:Rack" > ${CASS_TOP_FILE}
for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
do
  echo "${NODE_PRIVATE_IP[$COUNT]}=DC1:RAC1" >> ${CASS_TOP_FILE}
done
echo "" >> ${CASS_TOP_FILE}
echo "# default for unknown nodes" >> ${CASS_TOP_FILE}
echo "default=DC1:RAC1" >> ${CASS_TOP_FILE}
echo "" >> ${CASS_TOP_FILE}
echo "# Native IPv6 is supported, however you must escape the colon in the IPv6 Address" >> ${CASS_TOP_FILE}
echo "# Also be sure to comment out JVM_OPTS="$JVM_OPTS -Djava.net.preferIPv4Stack=true"" >> ${CASS_TOP_FILE}
echo "# in cassandra-env.sh" >> ${CASS_TOP_FILE}
echo "fe80\:0\:0\:0\:202\:b3ff\:fe1e\:8329=DC1:RAC3" >> ${CASS_TOP_FILE}
echo "" >> ${CASS_TOP_FILE}


# cassandra-rackdc.properties
#
cp ./templates/cassandra-rackdc.properties ./working-files/

# jvm-server.options
#
cp ./templates/jvm-server.options ./working-files/

# /etc/default/dse
#
cp ./templates/dse ./working-files/
sed -i $SEDBAK "s/##DSE_SPARK_ENABLED##/${DSE_SPARK_ENABLED}/" ./working-files/dse
sed -i $SEDBAK "s/##DSE_SOLR_ENABLED##/${DSE_SOLR_ENABLED}/" ./working-files/dse
sed -i $SEDBAK "s/##DSE_GRAPH_ENABLED##/${DSE_GRAPH_ENABLED}/" ./working-files/dse

#
echo ">>> done."


/bin/rm $TMP_FILE
/bin/rm ./working-files/*.bak
exit 0

