def project = [:]
project.network   = 'hmpps-delius-network-terraform'
project.dcore     = 'hmpps-delius-core-terraform'
project.alfresco  = 'hmpps-delius-alfresco-shared-terraform'
project.spg       = 'hmpps-spg-terraform'
//project.ndmis     = 'hmpps-ndmis-terraform' //

def environment_type = ""

// Add environments to the list in alphabetical order
def environments = [
  'delius-core-sandpit',
  'delius-core-dev',
  'delius-test',
  'delius-perf',
  'delius-stage',
  // 'delius-pre-prod',
  // 'delius-prod'
]

def taint_actions = [
  'taint',
  'untaint'
]

def resources = [
  '-module="interface" aws_instance.wls',
  '-module="ndelius" aws_instance.wls',
  '-module="oid" aws_instance.wls',
  '-module="spg" aws_instance.wls',
  '-module="delius_db" aws_instance.oracle_db',
  '-module="oid_db" aws_instance.oracle_db'
]

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder:latest
    '''

}

def plan_submodule(config_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF PLAN for ${config_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cd "${git_project_dir}"
        docker run --rm \
            -v `pwd`:/home/tools/data \
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
            bash -c "\
                source env_configs/${config_name}.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan -detailed-exitcode --out ${config_name}.plan" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
    }
}

def apply_submodule(config_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF APPLY for ${config_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${config_name}.properties; \
            cd ${submodule_name}; \
            terragrunt apply ${config_name}.plan"
        set -e
        """
    }
}

def taint_submodule(config_name, git_project_dir, submodule_name, taint_action, resource_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF TAINT for ${config_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${config_name}.properties; \
            cd ${submodule_name}; \
            terragrunt ${taint_action} ${resource_name}"
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

def do_terraform(config_name, git_project, component) {
    if (plan_submodule(config_name, git_project, component) == "2") {
        confirm()
        if (env.Continue == "true") {
            apply_submodule(config_name, git_project, component)
        }
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
                // dir( project.network ) {
                //   git url: 'git@github.com:ministryofjustice/hmpps-delius-network-terraform.git', branch: 'feature/delius_test_perf_stage_pre-prod_prod_JenkinsFile', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                // }
                dir( project.dcore ) {
                  git url: 'git@github.com:ministryofjustice/hmpps-delius-core-terraform', branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                // dir( project.alfresco ) {
                //   git url: 'git@github.com:ministryofjustice/hmpps-delius-alfresco-shared-terraform', branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                // }
                prepare_env()
            }
        }

        stage('Taint resource') {
          steps {
            script {
              taint_submodule(environment_name, project.dcore, 'application', taint_action, resource_name)
            }
          }
        }

        stage('Plan & Apply change') {
          steps {
            script {
              do_terraform(environment_name, project.dcore, 'application')
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
    }

}
