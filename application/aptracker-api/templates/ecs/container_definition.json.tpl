[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "memory": ${memory},
    "cpu": ${cpu},
    "portMappings": [{
        "hostPort": 8080,
        "containerPort": 8080
    }],
    "healthCheck": {
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "command": [ "CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:8080/aptracker-api/actuator/health || exit 1" ]
    },
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    },
    "entryPoint": ["java","-Duser.timezone=Europe/London","-jar","/app/app.jar"],
    "environment": [
        { "name": "SPRING_DATASOURCE_URL", "value": "${database_url}" },
        { "name": "SPRING_DATASOURCE_USERNAME", "value": "${database_username}" },
        { "name": "SPRING_DATASOURCE_TYPE", "value": "oracle.jdbc.pool.OracleDataSource" },
        { "name": "SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT", "value": "org.hibernate.dialect.Oracle10gDialect" },
        { "name": "SPRING_JPA_HIBERNATE_DDL-AUTO", "value": "none" },

        { "name": "SPRING_LDAP_URLS", "value": "${ldap_url}" },
        { "name": "SPRING_LDAP_USERNAME", "value": "${ldap_username}" },
        { "name": "SPRING_LDAP_BASE", "value": "${ldap_base}" },

        { "name": "LOGGING_LEVEL_COM_UNILINK_DELIUS", "value": "${log_level}" }
    ],
    "secrets": [
        {
            "name": "SPRING_DATASOURCE_PASSWORD",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/delius-database/db/delius_app_schema_password"
        },
        {
            "name": "SPRING_LDAP_PASSWORD",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password"
        }
    ]
}]