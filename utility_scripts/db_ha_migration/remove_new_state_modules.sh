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

scratch_path="/home/scratch/${TG_ENVIRONMENT_NAME}_remove_${database}"

if [[ ! -d "${scratch_path}" ]];
then
  echo "Create dir ${scratch_path}"
  mkdir "${scratch_path}"
fi

file_prefix="${scratch_path}/${TG_ENVIRONMENT_NAME}_${database}"
module_list="${file_prefix}_module_list.txt"
module_ids="${file_prefix}_module_ids.txt"
lockfile="${file_prefix}_import_lockfile.txt"

echo
echo "Environment name is :: ${TG_ENVIRONMENT_NAME}"
echo "The Database details removing are for ${database}"


echo "Get list of modules and write to file\n"
terragrunt state list | grep "${database}" >> "${module_list}"
#terragrunt state list
echo "Get list of modules and write to file\n"
cat "${module_list}"


echo "Show list of modules and IDs"

for line in $(cat ${module_list})
do
  echo
  echo "Module :: $(echo ${line})"

  terragrunt state rm "${line}"

done

echo
echo "List modules"
echo

terragrunt state list
