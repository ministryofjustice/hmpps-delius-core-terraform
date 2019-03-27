def project = [:]
project.config    = 'hmpps-env-configs'
project.network   = 'hmpps-delius-network-terraform'
project.dcore     = 'hmpps-delius-core-terraform'
project.alfresco  = 'hmpps-delius-alfresco-shared-terraform'
project.spg       = 'hmpps-spg-terraform'
//project.ndmis     = 'hmpps-ndmis-terraform' //

def environment_type = ""

// Add environments to the list in alphabetical order
def environments = [
  '-- choose environment --',
  'delius-core-sandpit',
  'delius-core-dev',
  'delius-test',
  'delius-perf',
  'delius-stage',
  'delius-mis-test',
  'delius-po-test1',
  'delius-po-test2',
  'delius-training',
  'delius-training-test'
  // 'delius-pre-prod',
  // 'delius-prod'
]

def taint_actions = [
  'destroy'
]

def resources = [
  'loadrunner',
  'application/interface',
  'application/ndelius',
  'application/spg',
  'application/ldap',
  'database',
  'database_failover'
]

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder:latest
    '''

}

def destroy_submodule(config_dir, env_name, git_project_dir, submodule_name, taint_action) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF DESTROY for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${env_name}/${env_name}.properties; \
            cd ${submodule_name}; \
            terragrunt destroy -auto-approve"
        set -e
        """
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

    parameters {
        choice(
          name: 'environment_name',
          choices: environments,
          description: 'Select environment for creation or updating.'
        )

        choice(
          name: 'taint_action',
          choices: taint_actions,
          description: 'Select resource for tainting.'
        )

        choice(
          name: 'resource_name',
          choices: resources,
          description: 'Select resource for tainting.'
        )
    }

    stages {

        stage('setup') {
            steps {
              slackSend(message: "\"${taint_action}\" of \"${resource_name}\" started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

              dir( project.config ) {
                git url: 'git@github.com:ministryofjustice/' + project.config, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
              }
              dir( project.dcore ) {
                git url: 'git@github.com:ministryofjustice/' + project.dcore, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
              }
                prepare_env()
            }
        }

        stage('Destroy resource') {
          steps {
            script {
              destroy_submodule(project.config, environment_name, project.dcore, 'application/' + resource_name, taint_action)
            }
          }
        }

        stage('debug_env') {
            steps {
                script {
                    debug_env()
                }
            }
        }

    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "\"${taint_action}\" of \"${resource_name}\" completed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good')
        }
        failure {
            slackSend(message: "\"${taint_action}\" of \"${resource_name}\" failed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger')
        }
    }

}
