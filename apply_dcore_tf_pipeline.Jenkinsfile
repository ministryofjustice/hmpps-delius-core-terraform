def project = [:]
project.config    = 'hmpps-env-configs'
project.dcore     = 'hmpps-delius-core-terraform'

// Parameters required for job
// parameters:
//     choice:
//       name: 'environment_name'
//       description: 'Environment name.'
//     booleanParam:
//       name: 'confirmation'
//       description: 'Whether to require manual confirmation of terraform plans.'


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

def confirm() {
    try {
        timeout(time: 15, unit: 'MINUTES') {

            env.Continue = input(
                id: 'Proceed1', message: 'Apply plan?', parameters: [
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
           confirm()
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

def debug_env() {
    sh '''
    #!/usr/env/bin bash
    pwd
    ls -al
    '''
}

pipeline {

    agent { label "jenkins_slave" }


    stages {

        stage('setup') {
            steps {
                slackSend(message: "\"Apply\" started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

                dir( project.config ) {
                  git url: 'git@github.com:ministryofjustice/' + project.config, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                dir( project.dcore ) {
                  git url: 'git@github.com:ministryofjustice/' + project.dcore, branch: 'delius-stage_to_prod_access_build', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }

                prepare_env()
            }
        }

        stage ('Security') {
            parallel {
                stage('Delius Security Groups') {
                    steps {
                        script {
                            do_terraform(project.config, environment_name, project.dcore, 'security-groups')
                        }
                    }
                }

                stage('Delius Keys and Profiles') {
                    steps {
                        script {
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
                            do_terraform(project.config, environment_name, project.dcore, 'database_failover')
                        }
                    }
                }

                stage('Delius Application LDAP') {
                    steps {
                        script {
                            do_terraform(project.config, environment_name, project.dcore, 'application/ldap')
                        }
                    }
                }
            }
        }

        stage ('Apps') {
            parallel {
                stage('Delius LoadRunner') {
                    steps {
                        script {
                            do_terraform(project.config, environment_name, project.dcore, 'loadrunner')
                        }
                    }
                }

                stage('Delius Management Server') {
                    steps {
                        script {
                            do_terraform(project.config, environment_name, project.dcore, 'management')
                        }
                    }
                }

                stage ('Delius Password Self-Service Tool') {
                    steps{
                        script {
                            do_terraform(project.config, environment_name, project.dcore, 'pwm')
                        }
                    }
                }

                stage ('Delius User Management Tool') {
                    steps{
                        script {
                            do_terraform(project.config, environment_name, project.dcore, 'application/umt')
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

        stage ('Monitoring and ') {
            parallel {
                stage ('Delius DSS Batch Job') {
                    steps{
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            println("batch/dss")
                            do_terraform(project.config, environment_name, project.dcore, 'batch/dss')
                        }
                    }
                }

                stage('Pingdom checks') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            do_terraform(project.config, environment_name, project.dcore, 'pingdom')
                        }
                    }
                }

                stage('Monitoring and Alerts') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            do_terraform(project.config, environment_name, project.dcore, 'monitoring')
                        }
                    }
                }
            }
        }

        stage('Build Delius Database High Availibilty') {
            steps {
                println("batch/dss")
                build job: "DAMS/Environments/${environment_name}/Delius/Build_Oracle_DB_HA", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"]]
            }
        }

        stage('Smoke test') {
            steps {
                build job: "DAMS/Environments/${environment_name}/Delius/Smoke test", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"]]
            }
        }
    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "\"Apply\" completed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good')
        }
        failure {
            slackSend(message: "\"Apply\" failed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger')
        }
    }

}
