#!/bin/bash

source ./params.sh

TMP_FILE=/tmp/generate-hosts-file.tmp.$$

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

  esac
done

echo ">>> done."


# Parse Ansible hosts.template to generate the Ansible hosts file
#
echo
echo ">>> Generating Ansible hosts file from templates/hosts.template.."
cp ./templates/hosts.template hosts

sed -i $SEDBAK "s/##REGION##/$REGION/" ./hosts
sed -i $SEDBAK "s/##ANSIBLE_SSH_PRIVATE_KEY_FILE##/$ANSIBLE_SSH_PRIVATE_KEY_FILE/" ./hosts
sed -i $SEDBAK "s/##DOMAIN_NAME##/$DOMAIN_NAME/" ./hosts
sed -i $SEDBAK "s/##ADMIN_EXTERNAL_FQDN##/$ADMIN_LB_FQDN/g" ./hosts
sed -i $SEDBAK "s/##DSE_ADMIN_USERNAME##/$DSE_ADMIN_USERNAME/g" ./hosts
sed -i $SEDBAK "s/##DSE_ADMIN_PASSWORD##/$DSE_ADMIN_PASSWORD/g" ./hosts
sed -i $SEDBAK "s/##DSE_STUDIO_DOWNLOAD##/$DSE_STUDIO_DOWNLOAD/g" ./hosts

sed -i $SEDBAK "s/##BOOTSTRAP_PUBLIC_IP##/$BOOTSTRAP_PUBLIC_IP/" ./hosts
sed -i $SEDBAK "s/##BOOTSTRAP_NAME##/$BOOTSTRAP_NAME/" ./hosts

# Append variable number of nodes to ansible hosts file
echo "" >> ./hosts
echo "[nodes]" >> ./hosts
for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
do
  echo "node${COUNT} ansible_host=${NODE_PUBLIC_IP[$COUNT]} fqdn=${NODE_NAME[$COUNT]}" >> ./hosts
done
echo "" >> ./hosts
echo ">>> done."

echo
echo "Please check the Ansible hosts file and run the playbook:"
echo "   ansible-playbook -i hosts site.yml"
echo


/bin/rm $TMP_FILE
rm ./hosts.bak
exit 0

