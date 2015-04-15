#!/bin/bash

# Copyright 2015 Telefónica Investigación y Desarrollo, S.A.U
#
# This file is part of FIWARE project.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at:
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For those usages not covered by the Apache version 2.0 License please
# contact with opensource@tid.es

# CAVEATS: 
# You must have set the openstack credentials (usually: "source openrc")
# before running this script.
#
# Please, be aware that this script is may not be correct with Organizations.
# 
# This script creates the file /tmp/2delete.txt which is the script to use
# to delete the VMs of those people who haven't accepted terms and 
# conditions
#
# Autor: Jose Ignacio Carretero Guarde.
#


# Some configuration
ACCEPT_FILE=/tmp/accepted_list.txt
VM_FILE=/tmp/vm_file.txt
DO_DELETE=/tmp/2delete.txt
DONT_DELETE=/tmp/2keep.txt

> $DO_DELETE
> $DONT_DELETE

# Fill in the ACCEPTED file with people who have accepted
curl http://terms.lab.fiware.org/api/v1/all_accepted?version=1.1  > $ACCEPT_FILE
sed -e 's/\["//g' -e 's/","/\n/g' -e 's/\]"//g' -i $ACCEPT_FILE

# Get the list of all VMs and keep IDs in a file
nova list --all_tenants=1 | egrep -v "(+------|\| ID)" | \
awk -F '|' '
@include "trims.awk"
{print trim($2)}' > $VM_FILE

# Just for every VM in the vm_file
for vm in `cat $VM_FILE`; do
   # Query user_id and tenant_id
   infor=(`nova show $vm | \
   awk -F '|' '
      @include "trims.awk"
      /user_id/ {uid=trim($3)}
      /tenant_id/ {tid=trim($3)}
      END {print uid, tid}
'`)

   # ${infor[0]} = user_id ; ${infor[1]}=project_id
   if [ `grep "^${infor[0]}$" $ACCEPT_FILE` ]; then
      # Write a log in a "keep file" --- 
      echo "keep $vm # user=${infor[0]} tenant=${infor[1]}" | tee -a $DONT_DELETE
   else
      # Write a nova delete command in a delete file -- This file is like a script you
      # can exec later.
      echo "nova delete $vm # user=${infor[0]} tenant=${infor[1]}" | tee -a $DO_DELETE
   fi
done

