def project = [:]
project.config          = 'hmpps-env-configs'
project.dcore           = 'hmpps-delius-core-terraform'
project.config_version  = ''
project.dcore_version   = ''
db_high_availability_count = 0

// Parameters required for job
// parameters:
//     choice:
//       name: 'environment_name'
//       description: 'Environment name.'
//     string:
//       name: 'CONFIG_BRANCH'
//       description: 'Target Branch for hmpps-env-configs'
//     string:
//       name: 'DCORE_BRANCH'
//       description: 'Target Branch for hmpps-delius-core-terraform'
//     booleanParam:
//       name: 'confirmation'
//       description: 'Whether to require manual confirmation of terraform plans.'
def get_version(env_name, repo_name, override_version) {
  ssm_param_version = sh (
    script: "aws ssm get-parameters --region eu-west-2 --name \"/versions/delius-core/repo/${repo_name}/${env_name}\" --query Parameters | jq '.[] | select(.Name | test(\"${env_name}\")) | .Value' --raw-output",
    returnStdout: true
  ).trim()

  echo "ssm_param_version - " + ssm_param_version
  echo "override_version - " + override_version

  if (ssm_param_version!="" && override_version=="master") {
    return ":refs/tags/" + ssm_param_version
  } else {
    return override_version
  }
}

def get_db_ha_count(git_project_dir, env_name, db_name) {
    file = "${git_project_dir}/${env_name}/ansible/group_vars/all.yml"
    item = "database.${db_name}.high_availability_count"
    db_ha_count = get_yaml_value(file, item)

    echo "db_ha_count - " + db_ha_count

    if (db_ha_count!="") {
        return db_ha_count
    } else {
        return 0
    }
}

def get_yaml_value(file, item_name) {
    item = sh (
        script: "cat \"${file}\" | shyaml --quiet get-value \"${item_name}\"",
        returnStdout: true
    ).trim()

    echo "item - " + item
    return item
}

def checkout_version(git_project_dir, git_version) {
  sh """
    #!/usr/env/bin bash
    set +e
    pushd "${git_project_dir}"
    git checkout "${git_version}"
    echo `git symbolic-ref -q --short HEAD || git describe --tags --exact-match`
    popd
  """
}

def debug_env(git_project_dir, git_version) {
  sh """
    #!/usr/env/bin bash
    set +e
    pushd "${git_project_dir}"
    git branch
    git describe --tags
    echo `git symbolic-ref -q --short HEAD || git describe --tags --exact-match`
    popd
  """
}

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder:latest
    '''
}

def plan_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF PLAN for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
            -v `pwd`:/home/tools/data \
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                [ ${submodule_name} == 'pingdom' ] && source pingdom/ssm.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan -detailed-exitcode --out ${env_name}.plan > tf.plan.out; \
                exitcode=\\\"\\\$?\\\"; \
                cat tf.plan.out; \
                if [ \\\"\\\$exitcode\\\" == '1' ]; then exit 1; fi; \
                if [ \\\"\\\$exitcode\\\" == '2' ]; then \
                    parse-terraform-plan -i tf.plan.out | jq '.changedResources[] | (.action != \\\"update\\\") or (.changedAttributes | to_entries | map(.key != \\\"tags.source-hash\\\") | reduce .[] as \\\$item (false; . or \\\$item))' | jq -e -s 'reduce .[] as \\\$item (false; . or \\\$item) == false'; \
                    if [ \\\"\\\$?\\\" == '1' ]; then exitcode=2 ; else exitcode=3; fi; \
                fi; \
                echo \\\"\\\$exitcode\\\" > plan_ret;" \
            || exitcode="\$?"; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/${submodule_name}/plan_ret").trim()
    }
}

def apply_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF APPLY for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
          -v `pwd`:/home/tools/data \
          -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
          bash -c " \
              source env_configs/${env_name}/${env_name}.properties; \
              [ ${submodule_name} == 'pingdom' ] && source pingdom/ssm.properties; \
              cd ${submodule_name}; \
              terragrunt apply ${env_name}.plan; \
              tgexitcode=\\\$?; \
              echo \\\"TG exited with code \\\$tgexitcode\\\"; \
              if [ \\\$tgexitcode -ne 0 ]; then \
                exit  \\\$tgexitcode; \
              else \
                exit 0; \
              fi;"; \
        dockerexitcode=\$?; \
        echo "Docker step exited with code \$dockerexitcode"; \
        if [ \$dockerexitcode -ne 0 ]; then exit \$dockerexitcode; else exit 0; fi;
        set -e
        """
    }
}

def confirm(message) {
    try {
        timeout(time: 15, unit: 'MINUTES') {

            env.Continue = input(
                id: 'Proceed1', message: message, parameters: [
                    [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Apply Terraform']
                ]
            )
        }
    } catch(err) { // timeout reached or input false
        def user = err.getCauses()[0].getUser()
        env.Continue = false
        if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
            echo "Timeout"
            error("Build failed because confirmation timed out")
        } else {
            echo "Aborted by: [${user}]"
        }
    }
}

def do_terraform(config_dir, env_name, git_project, component) {
    plancode = plan_submodule(config_dir, env_name, git_project, component)
    if (plancode == "2") {
        if ("${confirmation}" == "true") {
           confirm('Apply changes to ' + component + '?')
        } else {
            env.Continue = true
        }
        if (env.Continue == "true") {
           apply_submodule(config_dir, env_name, git_project, component)
        }
    }
    else if (plancode == "3") {
        apply_submodule(config_dir, env_name, git_project, component)
        env.Continue = true
    }
    else {
        env.Continue = true
    }
}

pipeline {

    agent { label "jenkins_slave" }

    parameters {
        string(name: 'CONFIG_BRANCH', description: 'Target Branch for hmpps-env-configs', defaultValue: 'master')
        string(name: 'DCORE_BRANCH',  description: 'Target Branch for hmpps-delius-core-terraform', defaultValue: 'master')
        booleanParam(name: 'deploy_DATABASE_HA', defaultValue: true, description: 'Deploy/update Database High Availibilty?')
        booleanParam(name: 'db_patch_check', defaultValue: true, description: 'Check Oracle DB patches?')
    }


    stages {

        stage('setup') {
            steps {
                script {
                  def starttime = new Date()
                  println ("Started on " + starttime)

                  project.config_version = get_version(environment_name, project.config, env.CONFIG_BRANCH)
                  println("Version from function (project.config_version) -- " + project.config_version)

                  project.dcore_version  = get_version(environment_name, project.dcore, env.DCORE_BRANCH)
                  println("Version from function (project.dcore_version) -- " + project.dcore_version)

                  def information = """
                  Started on ${starttime}
                  project.config_version -- ${project.config_version}
                  project.dcore_version  -- ${project.dcore_version}
                  """

                  println information
                }

                slackSend(message: "\"Apply\" of \"${project.dcore_version}\" started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

                dir( project.config ) {
                  checkout scm: [$class: 'GitSCM',
                              userRemoteConfigs:
                                [[url: 'git@github.com:ministryofjustice/' + project.config, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a' ]],
                              branches:
                                [[name: project.config_version]]],
                              poll: false
                }
                debug_env(project.config, project.config_version)


                dir( project.dcore ) {
                  checkout scm: [$class: 'GitSCM',
                              userRemoteConfigs:
                                [[url: 'git@github.com:ministryofjustice/' + project.dcore, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a' ]],
                              branches:
                                [[name: project.dcore_version]]],
                              poll: false
                }
                debug_env(project.dcore, project.dcore_version)

                script {
                    db_high_availability_count = get_db_ha_count(project.config, environment_name, "delius")
                    echo "DB HIGH AVAILABILITY COUNT is " + db_high_availability_count
                }

                prepare_env()
            }
        }

        stage ('Security') {
            parallel {
                stage('Delius Security Groups') {
                    steps {
                        script {
                          println("terraform security-groups")
                          do_terraform(project.config, environment_name, project.dcore, 'security-groups')
                        }
                    }
                }

                stage('Delius Keys and Profiles') {
                    steps {
                        script {
                          println("terraform key_profile")
                          do_terraform(project.config, environment_name, project.dcore, 'key_profile')
                        }
                    }
                }
            }
        }


        stage ('Data') {
            parallel {
                stage('Delius Database') {
                    steps {
                        script {
                            println("terraform database_failover")
                            do_terraform(project.config, environment_name, project.dcore, 'database_failover')
                        }
                    }
                }

                stage('Delius Database StandBy1') {
                    when {expression { db_high_availability_count == 1 ||  db_high_availability_count == 2 }}
                    steps {
                        script {
                            println("terraform database_standbydb1")
                            do_terraform(project.config, environment_name, project.dcore, 'database_standbydb1')
                        }
                    }
                }

                stage('Delius Database StandBy2') {
                    when {expression { db_high_availability_count == 2 }}
                    steps {
                        script {
                            println("terraform database_standbydb2")
                            do_terraform(project.config, environment_name, project.dcore, 'database_standbydb2')
                        }
                    }
                }

                stage('Delius Application LDAP') {
                    steps {
                        script {
                          println("terraform application/ldap")
                          do_terraform(project.config, environment_name, project.dcore, 'application/ldap')
                        }
                    }
                }
            }
        }

        stage('Check Oracle Software Patches on Primary') {
            when {expression { db_patch_check == "true" }}
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    println("Check Oracle Software Patches on Primary")
                    build job: "Ops/Oracle_Operations/Patch_Oracle_Software", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"],[$class: 'StringParameterValue', name: 'target_host', value: 'delius_primarydb'],[$class: 'BooleanParameterValue', name: 'install_absent_patches', value: false],[$class: 'StringParameterValue', name: 'patch_id', value: 'ALL']]
                }
            }
        }

        stage ('Apps') {
            parallel {
                stage('Delius LoadRunner') {
                    steps {
                        script {
                          println("terraform loadrunner")
                          do_terraform(project.config, environment_name, project.dcore, 'loadrunner')
                        }
                    }
                }

                stage('Delius Management Server') {
                    steps {
                        script {
                          println("terraform management")
                          do_terraform(project.config, environment_name, project.dcore, 'management')
                        }
                    }
                }

                stage ('Delius Password Self-Service Tool') {
                    steps {
                        script {
                          println("terraform pwm")
                          do_terraform(project.config, environment_name, project.dcore, 'pwm')
                        }
                    }
                }
            }
        }

        stage ('Delius Apps') {
            parallel {
                stage('Delius Application NDelius') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            println("application/ndelius")
                            do_terraform(project.config, environment_name, project.dcore, 'application/ndelius')
                        }
                    }
                }

                stage('Delius Application SPG') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            println("application/spg")
                            do_terraform(project.config, environment_name, project.dcore, 'application/spg')
                        }
                    }
                }

                stage('Delius Application Interface') {
                    steps {
                      catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            println("application/interface")
                            do_terraform(project.config, environment_name, project.dcore, 'application/interface')
                        }
                    }
                }
            }
        }

        stage ('Delius Micro-services') {
            parallel {
                stage('Delius User Management Tool') {
                    steps {
                        script {
                          println("terraform application/umt")
                          do_terraform(project.config, environment_name, project.dcore, 'application/umt')
                        }
                    }
                }

                stage('Delius Approved Premises Tracker API') {
                    steps {
                        script {
                          println("terraform application/aptracker-api")
                          do_terraform(project.config, environment_name, project.dcore, 'application/aptracker-api')
                        }
                    }
                }

                stage('Delius GDPR') {
                    steps {
                        script {
                          println("terraform application/gdpr")
                          do_terraform(project.config, environment_name, project.dcore, 'application/gdpr')
                        }
                    }
                }
            }
        }

        stage ('Monitoring and Batch') {
            parallel {
                stage ('Delius DSS Batch Job') {
                    steps{
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            println("batch/dss")
                            do_terraform(project.config, environment_name, project.dcore, 'batch/dss')
                        }
                    }
                }

                // Skipping this stage, due to Pingdom credentials issue. May need to review whether we need the checks at all.
//                stage('Pingdom checks') {
//                    steps {
//                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
//                            println("terraform pingdom")
//                            do_terraform(project.config, environment_name, project.dcore, 'pingdom')
//                        }
//                    }
//                }

                stage('Monitoring and Alerts') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                          println("terraform monitoring")
                          do_terraform(project.config, environment_name, project.dcore, 'monitoring')
                        }
                    }
                }
            }
        }

        stage('Build Delius Database High Availibilty') {
            when {expression { (db_high_availability_count == 1 || db_high_availability_count == 2) && deploy_DATABASE_HA == "true" }}
            steps {
              println("Build Database High Availibilty")
              build job: "DAMS/Environments/${environment_name}/Delius/Build_Oracle_DB_HA", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"]]
            }
        }

        stage ('Check Oracle Software and Patches on HA') {
            parallel {

                stage('Check Oracle Software Patches on HA 1') {
                    when {expression { (db_high_availability_count == 1 || db_high_availability_count == 2) && db_patch_check == "true" }}
                    steps {
                       catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                         println("Check Oracle Software Patcheson HA 1")
                         build job: "Ops/Oracle_Operations/Patch_Oracle_Software", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"],[$class: 'StringParameterValue', name: 'target_host', value: 'delius_standbydb1'],[$class: 'BooleanParameterValue', name: 'install_absent_patches', value: false],[$class: 'StringParameterValue', name: 'patch_id', value: 'ALL']]
                       }
                    }
                }

                stage('Check Oracle Software Patches on HA 2') {
                    when {expression { db_high_availability_count == 2 && db_patch_check == "true" }}
                    steps {
                       catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                         println("Check Oracle Software Patcheson HA 2")
                         build job: "Ops/Oracle_Operations/Patch_Oracle_Software", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"],[$class: 'StringParameterValue', name: 'target_host', value: 'delius_standbydb2'],[$class: 'BooleanParameterValue', name: 'install_absent_patches', value: false],[$class: 'StringParameterValue', name: 'patch_id', value: 'ALL']]
                       }
                    }
                }
            }
        }

        stage('Smoke test') {
            steps {
              println("Smoke test")
              build job: "DAMS/Environments/${environment_name}/Delius/Smoke test", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"]]
            }
        }
    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "\"Apply\" of \"${project.dcore_version}\" completed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good')
        }
        failure {
            slackSend(message: "\"Apply\" of \"${project.dcore_version}\" failed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger')
        }
    }

}
