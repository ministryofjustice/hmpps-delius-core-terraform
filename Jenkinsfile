def project = [
		source        : 'hmpps-delius-core-terraform',
		source_version: '',
		config        : 'hmpps-env-configs',
		config_version: ''
];

String get_parameter(GString key, String defaultValue="", String prefix="") {
	String value = sh(script: "aws ssm get-parameter --name ${key} --query Parameter.Value --region eu-west-2 --output text || true", returnStdout: true).trim()
	return value != ""? prefix + value: defaultValue
}

String get_config_yaml(GString file, String key, String defaultValue="") {
	return sh(script: """
			cat '${file}' | \
			shyaml --quiet get-value '${key}' '${defaultValue}'
			""", returnStdout: true).trim()
}

boolean confirm(String component) {
	if (!params.confirmation) return true;
	def changes = sh(script: "grep 'Plan:' '${component}/.terraform/out/${env.ENVIRONMENT}.tg.log' | col -b | sed -E 's/[0-9]+m//g", returnStdout: true).trim()
	try {
		timeout(time: 15, unit: 'MINUTES') {
			return input(message: "Apply changes to ${component}?", parameters: [[$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: changes]])
		}
	} catch (err) { // timeout reached or input false
		String user = err.getCauses()[0].getUser()
		if ('SYSTEM' == user) error("Confirmation timed out") else echo "Aborted by [${user}]"
		return false;
	}
}

void do_terraform(String repo, String component) {
	dir(repo) {
		def plan_status = sh(script: "COMPONENT=${component} ./run.sh plan", returnStatus: true)
		// 0 = No changes, 1 = Error, 2 = Changes
		if (plan_status == 1) error("Error generating plan for ${component}")
		if (plan_status == 0 || (plan_status == 2 && confirm(component))) {
			def apply_status = sh(script: "COMPONENT=${component} ./run.sh apply", returnStatus: true)
			if (apply_status != 0) error("Error applying changes to ${component}")
			if (params.run_tests && fileExists("inspec_profiles/${component}/inspec.yml")) {
				def test_status = sh(script: "COMPONENT=${component} ./test.sh", returnStatus: true)
				if (test_status != 0) error("Test failures in ${component}")
			}
		}
	}
}

pipeline {
	agent { label "jenkins_agent" }
	options { ansiColor('xterm') }

	parameters {
		string(name: 'CONFIG_BRANCH', description: "Target Branch for hmpps-env-configs", defaultValue: 'master')
		string(name: 'SOURCE_BRANCH', description: "Target Branch for hmpps-delius-core-terraform", defaultValue: 'master')
		booleanParam(name: 'deploy_DATABASE_HA', description: 'Deploy/update Database High Availibilty?', defaultValue: true)
		booleanParam(name: 'db_patch_check', description: 'Check Oracle DB patches?', defaultValue: true)
		booleanParam(name: 'confirmation', description: 'Confirm Terraform changes?', defaultValue: true)
	}

	environment {
		CONTAINER = 'mojdigitalstudio/hmpps-terraform-builder-0-12'
		ENVIRONMENT = sh(script: 'basename $(dirname $(dirname $(pwd)))', returnStdout: true).trim()
	}

	stages {
		stage('setup') {
			steps {
//                slackSend(message: "\"Apply\" of \"${project.source_version}\" started on \"${env.ENVIRONMENT}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

				script {
					project.source_version = get_parameter("/versions/delius-core/repo/${project.source}/${env.ENVIRONMENT}", params.SOURCE_BRANCH)
					project.config_version = get_parameter("/versions/delius-core/repo/${project.config}/${env.ENVIRONMENT}", params.CONFIG_BRANCH)
				}

				dir(project.config) { checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'git@github.com:ministryofjustice/' + project.config, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a' ]], branches: [[name: project.config_version]]], poll: false }
				dir(project.source) { checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'git@github.com:ministryofjustice/' + project.source, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a' ]], branches: [[name: project.source_version]]], poll: false }

				script {
					env.TF_VAR_db_aws_ami = get_parameter("/versions/delius-core/ami/db-ami/${env.ENVIRONMENT}")
					env.TF_VAR_high_availability_count = get_config_yaml("${project.config}/${env.ENVIRONMENT}/ansible/group_vars/all.yml", 'database.delius.high_availability_count', '0')
				}

				sh('docker pull "${CONTAINER}"')
			}
		}

		stage ('Security') {
			parallel {
				stage('Security Groups') { steps { do_terraform(project.source, 'security-groups') } }
				stage('Keys & Profiles') { steps { do_terraform(project.source, 'key_profile') } }
			}
		}

		stage ('Data') {
			parallel {
				stage('LDAP') { steps { do_terraform(project.source, 'application/ldap') } }
				stage('Primary Database') { steps { do_terraform(project.source, 'database_failover') } }
				stage('Standby Database 1') {
					when { expression { +env.TF_VAR_high_availability_count >= 1 } }
					steps { do_terraform(project.source, 'database_standbydb1') }
				}
				stage('Standby Database 2') {
					when { expression { +env.TF_VAR_high_availability_count >= 2 } }
					steps { do_terraform(project.source, 'database_standbydb2') }
				}
			}
		}

		stage('Check Oracle Software Patches on Primary') {
			when { expression { env.db_patch_check == "true" } }
			steps {
				catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
					println('Check Oracle Software Patches on Primary')
					build job: "Ops/Oracle_Operations/Patch_Oracle_Software", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${environment_name}"],[$class: 'StringParameterValue', name: 'target_host', value: 'delius_primarydb'],[$class: 'BooleanParameterValue', name: 'install_absent_patches', value: false],[$class: 'StringParameterValue', name: 'patch_id', value: 'ALL']]
				}
			}
		}

		stage ('Tools') {
			parallel {
				stage('LoadRunner') { steps { do_terraform(project.source, 'loadrunner') } }
				stage('Management Server') { steps { do_terraform(project.source, 'management') } }
				stage('Password Reset Tool') { steps { do_terraform(project.source, 'application/pwm') } }
			}
		}

		stage ('Core Services') {
			parallel {
				stage('Front-End App - ndelius') { steps { do_terraform(project.source, 'application/ndelius') } }
				stage('Message Queue - spg') { steps { do_terraform(project.source, 'application/spg') } }
				stage('API Endpoints - interface') { steps { do_terraform(project.source, 'application/interface') } }
				stage('DSS Batch Job') { steps { do_terraform(project.source, 'batch/dss') } }
			}
		}

		stage ('Micro-Services') {
			parallel {
				stage('GDPR') { steps { do_terraform(project.source, 'application/gdpr') } }
				stage('User Management') { steps { do_terraform(project.source, 'application/umt') } }
				stage('Approved Premises Tracker API') { steps { do_terraform(project.source, 'application/aptracker-api') } }
			}
		}

		stage ('Monitoring') {
			parallel {
				stage('Monitoring') { steps { do_terraform(project.source, 'monitoring') } }
			}
		}

		stage('Database High Availibilty') {
			when { expression { params.deploy_DATABASE_HA && +env.TF_VAR_high_availability_count >= 1 } }
			steps {
				println('Build Database High Availibilty')
				build job: "DAMS/Environments/${env.ENVIRONMENT}/Delius/Build_Oracle_DB_HA", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${env.ENVIRONMENT}"],[$class: 'StringParameterValue', name: 'high_availability_count', value: db_high_availability_count]]
			}
		}

		stage ('Check Oracle Software and Patches on standbys') {
			parallel {
				stage('Check Standby 1') {
					when { expression { params.db_patch_check && +env.TF_VAR_high_availability_count >= 1 } }
					steps {
						catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
							println('Check Oracle Software Patches on Standby 1')
							build job: "Ops/Oracle_Operations/Patch_Oracle_Software", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${env.ENVIRONMENT}"],[$class: 'StringParameterValue', name: 'target_host', value: 'delius_standbydb1'],[$class: 'BooleanParameterValue', name: 'install_absent_patches', value: false],[$class: 'StringParameterValue', name: 'patch_id', value: 'ALL']]
						}
					}
				}
				stage('Check Standby 2') {
					when { expression { params.db_patch_check && +env.TF_VAR_high_availability_count >= 2 } }
					steps {
						catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
							println('Check Oracle Software Patches on Standby 2')
							build job: "Ops/Oracle_Operations/Patch_Oracle_Software", parameters: [[$class: 'StringParameterValue', name: 'environment_name', value: "${env.ENVIRONMENT}"],[$class: 'StringParameterValue', name: 'target_host', value: 'delius_standbydb2'],[$class: 'BooleanParameterValue', name: 'install_absent_patches', value: false],[$class: 'StringParameterValue', name: 'patch_id', value: 'ALL']]
						}
					}
				}
			}
		}

		stage('Smoke test') { steps { build job: "DAMS/Environments/${env.ENVIRONMENT}/Delius/Smoke test" } }
	}

	post {
		always { deleteDir() }
//		success { slackSend(message: "\"Apply\" of \"${project.source_version}\" completed on \"${env.ENVIRONMENT}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good') }
//		failure { slackSend(message: "\"Apply\" of \"${project.source_version}\" failed on \"${env.ENVIRONMENT}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger') }
	}

}
