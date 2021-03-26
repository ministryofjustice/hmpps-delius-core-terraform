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
        { "name": "SERVER_SERVLET_CONTEXT_PATH", "value": "/merge/api/" },
        { "name": "SPRING_DATASOURCE_JDBC-URL", "value": "${merge_database_url}" },
        { "name": "SPRING_DATASOURCE_USERNAME", "value": "${merge_database_username}" },
        { "name": "SPRING_DATASOURCE_DRIVER-CLASS-NAME", "value": "org.postgresql.Driver" },
        { "name": "SPRING_SECOND-DATASOURCE_JDBC-URL", "value": "${delius_database_url}" },
        { "name": "SPRING_SECOND-DATASOURCE_USERNAME", "value": "${delius_database_username}" },
        { "name": "SPRING_SECOND-DATASOURCE_TYPE", "value": "oracle.jdbc.pool.OracleDataSource" },
        { "name": "SCHEDULE_MERGEUNMERGE", "value": "-" },
        { "name": "SPRING_JPA_HIBERNATE_DDL-AUTO", "value": "update" },
        { "name": "SPRING_BATCH_JOB_ENABLED", "value": "false" },
        { "name": "SPRING_BATCH_INITIALIZE-SCHEMA", "value": "always" },
        { "name": "ALFRESCO_DMS-PROTOCOL", "value": "https" },
        { "name": "ALFRESCO_DMS-HOST", "value": "${alfresco_host}" },
        { "name": "SPRING_SECURITY_OAUTH2_RESOURCESERVER_OPAQUE-TOKEN_CLIENT-ID", "value": "Merge-API" },
        { "name": "SPRING_SECURITY_OAUTH2_RESOURCESERVER_OPAQUE-TOKEN_INTROSPECTION-URI", "value": "${oauth_token_uri}" },
        { "name": "LOGGING_LEVEL_UK_GOV_JUSTICE", "value": "${log_level}" }
    ],
    "secrets": [
        { "name": "SPRING_DATASOURCE_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/merge/db/admin_password" },
        { "name": "SPRING_SECOND-DATASOURCE_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/${delius_database_password_key}" },
        { "name": "SPRING_SECURITY_OAUTH2_RESOURCESERVER_OPAQUE-TOKEN_CLIENT-SECRET", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/merge/api/client_secret" }
    ]
}]