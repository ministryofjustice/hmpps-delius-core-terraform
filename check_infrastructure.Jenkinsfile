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
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan > tf.plan.out; \
                exitcode=\\\"\\\$?\\\"; \
                cat tf.plan.out; \
                if [ \\\"\\\$exitcode\\\" == '1' ]; then exit 1; fi; \
                parse-terraform-plan -i tf.plan.out | jq '.changedResources[] | (.action != \\\"update\\\") or (.changedAttributes | to_entries | map(.key != \\\"tags.source-hash\\\") | reduce .[] as \\\$item (false; . or \\\$item))' | jq -e -s 'reduce .[] as \\\$item (false; . or \\\$item) == false'" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
    }
}

pipeline {

    agent { label "jenkins_slave" }

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

        stage('Delius Core') {
            parallel {
                stage('Plan Delius Security Groups')        { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'security-groups')}}}
                stage('Plan Delius Backups bucket')         { steps { script {plan_submodule(project.config, environment_name, project.dcore, 's3buckets')}}}
                stage('Plan Delius Keys and Profiles')      { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'key_profile')}}}
                stage('Plan Delius LoadRunner')             { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'loadrunner')}}}
                stage('Plan Delius Database')               { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'database_failover')}}}
                stage('Plan Delius Management Server')      { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'management')}}}
                stage('Plan Delius Application LDAP')       { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'application/ldap')}}}
                stage('Plan Delius Password Self-Service')  { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'pwm')}}}
                stage('Plan Delius User Management Tool')   { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'application/umt')}}}
                stage('Plan Delius Application NDelius')    { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'application/ndelius')}}}
                stage('Plan Delius Application SPG')        { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'application/spg')}}}
                stage('Plan Delius Application Interface')  { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'application/interface')}}}
                stage('Plan Delius DSS Batch Job')          { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'batch/dss')}}}
                stage('Plan Delius Pingdom Checks')         { steps { script {plan_submodule(project.config, environment_name, project.dcore, 'pingdom')}}}
            }
        }
    }

    post {
        always {
            deleteDir()

        }
    }

}
