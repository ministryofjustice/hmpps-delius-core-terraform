# Migrate from Single Terraform State to Three

## Background

The least intrusive way to implement options on number of Database stand bys is
to separate the code for the three databases from the current directory.
Code from "database_failover" is to be moved such that we have a directory for
database_standbydb1
database_standbydb2
This will result in two additional Terrform State files.

No changes need to be made to the actual AWS Resources or Terraform code, except moving the code to their new directories and updating the Jenkins File.

## Simple analogy

In very simple terms imagine we have three reports written in one Word document, we're going to copy the last two into their own Word doc - Then delete them from the original word doc while not touching the the first.

## Process

With Terraform we need to "import" details of the AWS resources (EC2 instances, EBS Volumes) into the new state files.
Then delete the same from the original statefile while leaving the primary database and it's EBS volumes intact.

Some scripts have been written to extract this information and write to a text file, then it is used as input to import into the new state file.

A terraform plan will be done followed by an apply (to intialise some state) on each standby.

When that is done those same resources will be removed from the "database_failover" statefile.

The new Terraform code will then be assigned to the Jenkins Jobs.

## Runbook

### Preparation

1: Checkout the project twice

```
git clone git@github.com:ministryofjustice/hmpps-delius-core-terraform.git current
git clone git@github.com:ministryofjustice/hmpps-delius-core-terraform.git split
```
2: Open three terminal windows

3: Change dir to current in 1st then git checkout "add_utils_dir_for_DB_HA", run TF script for container in "database_failover"
```
cd current
git checkout add_utils_dir_for_DB_HA
tfrun_c hmpps_token <env_name> container database_failover
```

4: Change dir to split in 2nd then git checkout "issue/305/ALS-68_reduce_ha", run TF script for container in "database_standbydb1"
```
cd split
git checkout issue/305/ALS-68_reduce_ha
tfrun_c hmpps_token <env_name> container database_standbydb1
```

5: Change dir to split in 3rd, run TF script for container in "database_standbydb2"
```
cd split
tfrun_c hmpps_token <env_name> container database_standbydb2
```

6: When you have bash prompt in container run "pwd" to check for correct dir

7: In Terminal-1 run script to get module details and ids
```
pwd
/home/tools/data/utility_scripts/db_ha_migration/write_source_module_details.sh
# check
ls -al /home/scratch/delius-core-dev_SOURCE/
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_2_module_list.txt
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_2_module_ids.txt
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_3_module_list.txt
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_3_module_ids.txt
```

8: In Terminal-2  - check the files can alse be read then run script
```
pwd
# check
ls -al /home/scratch/delius-core-dev_SOURCE/
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_2_module_list.txt
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_2_module_ids.txt
# check the script is there
cat /home/tools/data/utility_scripts/db_ha_migration/import_source_modules_to_new_state.sh
# run it
/home/tools/data/utility_scripts/db_ha_migration/import_source_modules_to_new_state.sh
# run a plan should see "2 to add, 2 to change, 0 to destroy."
# which is correct.
terragrunt plan -out dev-standby1.plan
# apply
terragrunt apply dev-standby1.plan
# should see the outputs
# run plan again should see "No changes. Infrastructure is up-to-date."
terragrunt plan -out dev-db-standby1.plan
```
That is the first standby imported.

9: In Terminal-3  - check the files can alse be read then run script
```
pwd
# check
ls -al /home/scratch/delius-core-dev_SOURCE/
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_3_module_list.txt
cat /home/scratch/delius-core-dev_SOURCE/delius-core-dev_delius_db_3_module_ids.txt
# check the script is there
cat /home/tools/data/utility_scripts/db_ha_migration/import_source_modules_to_new_state.sh
# run it
/home/tools/data/utility_scripts/db_ha_migration/import_source_modules_to_new_state.sh
# run a plan should see "2 to add, 2 to change, 0 to destroy."
# which is correct.
terragrunt plan -out dev-standby2.plan
# apply
terragrunt apply dev-standby2.plan
# should see the outputs
# run plan again should see "No changes. Infrastructure is up-to-date."
terragrunt plan -out dev-db-standby2.plan
```
That is the second standby imported.

10: In Terminal-1 Now remove those resources from the source statefile.
```
/home/tools/data/utility_scripts/db_ha_migration/remove_source_modules_from_source_state.sh
```

11: Update the Jenkins Job to use the branch "issue/305/ALS-68_reduce_ha"
