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
  'ldap'
]

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
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan -detailed-exitcode --out ${env_name}.plan" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
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
        bash -c "\
            source env_configs/${env_name}/${env_name}.properties; \
            cd ${submodule_name}; \
            terragrunt apply ${env_name}.plan"
        set -e
        """
    }
}

def taint_submodule(config_dir, env_name, git_project_dir, submodule_name, taint_action, resource_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF TAINT for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${env_name}/${env_name}.properties; \
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

def do_terraform(config_dir, env_name, git_project, component) {
    if (plan_submodule(config_dir, env_name, git_project, component) == "2") {
        confirm()
        if (env.Continue == "true") {
            apply_submodule(config_dir, env_name, git_project, component)
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
              dir( project.config ) {
                git url: 'git@github.com:ministryofjustice/' + project.config, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
              }
              dir( project.dcore ) {
                git url: 'git@github.com:ministryofjustice/' + project.dcore, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
              }
                prepare_env()
            }
        }

        stage('Taint resource') {
          steps {
            script {
              taint_submodule(project.config, environment_name, project.dcore, 'application/' + resource_name, taint_action, '-module="' + resource_name + '" aws_instance.wls' + resource_name)
            }
          }
        }

        stage('Plan & Apply change') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.dcore, 'application/ldap')
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
