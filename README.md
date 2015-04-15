# delete-unaccepted-vms

This Script is writen in order to clean the VMs in FIWARE-LAB which should be deleted because users have not accepted the terms and contidions.

The script uses 2 temporary files:
* /tmp/accepted_list.txt  -- The file containing the usernames who have accepted
* /tmp/vm_file.txt  -- The list of the instances in the node

The scripts produces 2 result files:
* /tmp/2delete.txt  -- This is a result file. A "script like" file of nova-delete commands to be executed.
* /tmp/2keep.txt   -- This is another result file of images to be kept.

Before running the Script you must set the openstack variables, or exec your own "keystonerc" file:

    export OS_AUTH_URL=xxx
    export OS_USERNAME=xxx
    export OS_PASSWORD=xxx
    export OS_TENANT_NAME=xxx
    export OS_REGION_NAME=xxx


Known issues
------------
* Please, be aware that this script doesn't seem to work with organizations. If a VM belongs to an orgnization, it might be deleted. So, some careful study of /tmp/2delete.txt file must be performed before deleting anything.

* "nova list" only return 1000 results. If the amount of instances is bigger than that, the script might not completely work. It might be useful to be executed serveral times after the deletions.

