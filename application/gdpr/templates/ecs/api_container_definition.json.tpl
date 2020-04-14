[{
    "name": "${container_name}",
    "image": "${image_url}",
    "essential": true,
    "memory": ${memory},
    "cpu": ${cpu},
    "portMappings": [{ "hostPort": 8080, "containerPort": 8080 }],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    },
    "entryPoint": ["java","-Duser.timezone=Europe/London","-jar","/app.jar"],
    "environment": [
        { "name": "SERVER_SERVLET_CONTEXT_PATH", "value": "/gdpr/api/" },
        { "name": "SPRING_DATASOURCE_JDBC-URL", "value": "${gdpr_database_url}" },
        { "name": "SPRING_DATASOURCE_USERNAME", "value": "${gdpr_database_username}" },
        { "name": "SPRING_DATASOURCE_DRIVER-CLASS-NAME", "value": "org.postgresql.Driver" },
        { "name": "SPRING_SECOND-DATASOURCE_JDBC-URL", "value": "${delius_database_url}" },
        { "name": "SPRING_SECOND-DATASOURCE_USERNAME", "value": "${delius_database_username}" },
        { "name": "SPRING_SECOND-DATASOURCE_TYPE", "value": "oracle.jdbc.pool.OracleDataSource" },
        { "name": "SPRING_JPA_HIBERNATE_DDL-AUTO", "value": "update" },
        { "name": "SPRING_BATCH_JOB_ENABLED", "value": "false" },
        { "name": "SPRING_BATCH_INITIALIZE-SCHEMA", "value": "always" },
        { "name": "ALFRESCO_DMS-PROTOCOL", "value": "https" },
        { "name": "ALFRESCO_DMS-HOST", "value": "${alfresco_host}" },
        { "name": "SCHEDULE_IDENTIFYDUPLICATES", "value": "${cron_identifyduplicates}" },
        { "name": "SCHEDULE_RETAINEDOFFENDERS", "value": "${cron_retainedoffenders}" },
        { "name": "SCHEDULE_RETAINEDOFFENDERSIICSA", "value": "${cron_retainedoffendersiicsa}" },
        { "name": "SCHEDULE_ELIGIBLEFORDELETION", "value": "${cron_eligiblefordeletion}" },
        { "name": "SCHEDULE_DELETEOFFENDERS", "value": "${cron_deleteoffenders}" },
        { "name": "SCHEDULE_DESTRUCTIONLOGCLEARING", "value": "${cron_destructionlogclearing}" },
        { "name": "SECURITY_OAUTH2_RESOURCE_ID", "value": "NDelius" },
        { "name": "SECURITY_OAUTH2_CLIENT_CLIENT-ID", "value": "GDPR-API" },
        { "name": "SECURITY_OAUTH2_RESOURCE_TOKEN-INFO-URI", "value": "${oauth_token_uri}" },
        { "name": "LOGGING_LEVEL_UK_GOV_JUSTICE", "value": "${log_level}" }
    ],
    "secrets": [
        { "name": "SPRING_DATASOURCE_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/delius-gdpr-database/db/admin_password" },
        { "name": "SPRING_SECOND-DATASOURCE_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/${delius_database_password_key}" },
        { "name": "SECURITY_OAUTH2_CLIENT_CLIENT-SECRET", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/gdpr/api/client_secret" }
    ]
}]