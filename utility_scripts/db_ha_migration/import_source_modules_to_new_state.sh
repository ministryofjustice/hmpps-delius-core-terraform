#!/usr/bin/env bash

## Get the DB details from the statefile and write as text file for import and
## deletion.

db="$(pwd | cut -d'_' -f2)"

database=""
if [[ ${db} == "standbydb2" ]];then database="delius_db_3"; fi
if [[ ${db} == "standbydb1" ]];then database="delius_db_2"; fi

if [[ -z ${database} ]];
then
  echo "Not correct DB :: ${database}"
  exit 0
fi

scratch_path="/home/scratch/${TG_ENVIRONMENT_NAME}_SOURCE"
file_prefix="${scratch_path}/${TG_ENVIRONMENT_NAME}_${database}"
module_list="${file_prefix}_module_list.txt"
module_ids="${file_prefix}_module_ids.txt"
lockfile="${file_prefix}_import_lockfile.txt"


#
echo
echo "Environment name is :: ${TG_ENVIRONMENT_NAME}"
echo "The Database details importing are for ${database}"

if [ -f "${lockfile}" ]; then
    echo "Exiting to avoid overwriting data"
    exit 0
fi

if [ ! -f "${module_ids}" ]; then
    echo "Exiting no module list file to import"
    exit 0
fi

echo "Show list of modules and IDs"

for line in $(cat ${module_ids})
do
  echo
  echo "Module :: $(echo ${line} | cut -d':' -f1)"
  echo "ID     :: $(echo ${line} | cut -d':' -f2)"
  terragrunt import "$(echo ${line} | cut -d':' -f1)" "$(echo ${line} | cut -d':' -f2)"

done

echo "Create a lock file to stop it running again"
date > "${lockfile}"

echo "List modules"

terragrunt state list
