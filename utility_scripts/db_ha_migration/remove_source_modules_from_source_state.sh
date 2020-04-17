#!/usr/bin/env bash

## Get the DB details from the statefile and write as text file for import and
## deletion.


databases="delius_db_2 delius_db_3"
scratch_path="/home/scratch/${TG_ENVIRONMENT_NAME}_SOURCE"

if [[ ! -d "${scratch_path}" ]];
then
  echo "Something wrong, nothing to read"
  exit 0
fi

echo
echo "Environment name is :: ${TG_ENVIRONMENT_NAME}"
echo "We need to remove the details for the two HA DBs"
echo "${databases}"


for database in ${databases};
do
  echo "This database :: ${database}"

  file_prefix="${scratch_path}/${TG_ENVIRONMENT_NAME}_${database}"
  module_list="${file_prefix}_module_list.txt"
  module_ids="${file_prefix}_module_ids.txt"
  lockfile="${file_prefix}_import_lockfile.txt"

  if [ ! -f "${lockfile}" ]; then
      echo "Exiting to avoid overwriting data"
      echo "The file that is written after import does not exist"
      exit 0
  fi

  echo
  echo "Environment name is :: ${TG_ENVIRONMENT_NAME}"
  echo "The Database details removing are for ${database}"

  for line in $(cat ${module_list})
  do
    echo
    echo "Module :: $(echo ${line})"

    #terragrunt state rm "${line}"

  done

  echo
  echo "List modules"
  echo

  terragrunt state list
done

echo
echo
echo "complete - ensure pipeline using new version"
