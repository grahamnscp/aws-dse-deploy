# aws-dse-deploy
Some terraform and ansible to deploy a DataStax Cassandra cluster using AWS as IaaS infra

## Generate custom variables.tf
Custom config is defined in params.sh which is used by setup-terraform-vars.sh to generate the variables.tf from a template file variables.tf.template
```
cp ./params.sh.example ./params.sh
edit: params.sh
run ./setup-terraform-vars.sh
```
check generated ./terraform/variables.tf is as required, no missing variables etc.

note: if you want to add variables you need to change the template and the setup script as well as adding them to the params.sh


## Setup and test terraform

note: I wrote and tested this with terraform v0.11

```
terraform init terraform
terraform plan terraform
```

## All looking good, then apply the terraform to deploy..

```
terraform apply -auto-approve terraform
```

## check the terraform output variables are looking good
as they are used by later scripts to generate the inventory files for ansible..

```
terraform output
```

## Ansible to finish the infra config, deploy docker daemon and bits
### Generate the ansible hosts file using the terraform output:
First generate an ansible hosts file to use with the playbooks defined in the site.yml:
```
---

- hosts: all
  roles:
  - accept-host-keys
  - ntp
  - pre-deploy
  - grub-config
  - dse-os-config
#  - update-packages
  - firewall
  - datastax-repo

- hosts: bootstrap
  roles:
  - ccm-install
  - dse-install-opscenter
  - dse-install-dsestudio

- hosts: nodes
  roles:
  - data-storage-mounts
  - dse-install-package
  - dse-install-node

- hosts: node1
  roles:
  - dse-install-node1
```
note: this script includes the params.sh so gets some of the variables directly from there, the rest are parsed from terraform output.

```
./generate-hosts-file.sh
```

### Generate the DataStax DSE config files as required from preset config values:

This currently generates these config files using templates in the templates folder and values in params.sh
- cassandra.yaml
- dse.yml
- cassandra-topology.properties
- cassandra-rackdc.properties
- jvm-server.options
- dse

The resultant files are places in the working-files directory

```
./generate-cassandra-config.sh
```

## Ansible commands to check host access and what will be deployed

check the generated hosts file and run the ansible playbook to finish the infra config..
You can see which hosts will be included and also which role tasks will be run from the ./roles directory;
```
ansible-playbook -i hosts --list-hosts site.yml
ansible-playbook -i hosts --list-tasks site.yml
#ansible-playbook -i hosts --check site.yml
```

## All looking good? then run the deployment
Run the config playbook, note that this also updates and reboots the instances so takes a while..
```
ansible-playbook -i hosts site.yml
```



## To teardown
```
terraform destroy -auto-approve terraform
```
