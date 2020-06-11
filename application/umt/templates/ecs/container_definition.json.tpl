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
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    },
    "environment": [
        { "name": "TZ",                                     "value": "Europe/London" },
        { "name": "SERVER_USE-FORWARD-HEADERS",             "value": "true" },
        { "name": "SERVER_FORWARD-HEADERS-STRATEGY",        "value": "native" },
        { "name": "SPRING_DATASOURCE_URL",                  "value": "${database_url}" },
        { "name": "SPRING_DATASOURCE_USERNAME",             "value": "${database_username}" },
        { "name": "SPRING_DATASOURCE_TYPE",                 "value": "oracle.jdbc.pool.OracleDataSource" },
        { "name": "SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT","value": "org.hibernate.dialect.Oracle10gDialect" },
        { "name": "SPRING_JPA_HIBERNATE_DDL-AUTO",          "value": "none" },
        { "name": "SPRING_LDAP_URLS",                       "value": "${ldap_url}" },
        { "name": "SPRING_LDAP_USERNAME",                   "value": "${ldap_username}" },
        { "name": "SPRING_LDAP_BASE",                       "value": "${ldap_base}" },
        { "name": "SPRING_LDAP_USEORACLEATTRIBUTES",        "value": "false" },
        { "name": "SPRING_REDIS_HOST",                      "value": "${redis_host}" },
        { "name": "SPRING_REDIS_PORT",                      "value": "${redis_port}" },
        { "name": "SPRING_REDIS_CLUSTER_NODES",             "value": "${redis_host}:${redis_port}" },
        { "name": "REDIS_CONFIGURE_NO-OP",                  "value": "true" },
        { "name": "DELIUS_PASSWORD-RESET_URL",              "value": "${password_reset_url}" },
        { "name": "DELIUS_LDAP_BASE_USERS",                 "value": "${ldap_base_users}" },
        { "name": "DELIUS_LDAP_BASE_CLIENTS",               "value": "${ldap_base_clients}" },
        { "name": "DELIUS_LDAP_BASE_ROLES",                 "value": "${ldap_base_roles}" },
        { "name": "DELIUS_LDAP_BASE_ROLE-GROUPS",           "value": "${ldap_base_role_groups}" },
        { "name": "DELIUS_LDAP_BASE_GROUPS",                "value": "${ldap_base_groups}" },
        { "name": "LOGGING_LEVEL_UK_CO_BCONLINE_NDELIUS",   "value": "${ndelius_log_level}" },

        { "name": "OID_URLS",               "value": "${ldap_url}" },
        { "name": "OID_USERNAME",           "value": "${ldap_username}" },
        { "name": "OID_BASE",               "value": "${ldap_base_users},${ldap_base}" },
        { "name": "OID_USEORACLEATTRIBUTES","value": "false" }
    ],
    "secrets": [
        { "name": "JWT_SECRET", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/umt/umt/jwt_secret" },
        { "name": "DELIUS_SECRET", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/umt/umt/delius_secret" },
        { "name": "SPRING_DATASOURCE_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/delius-database/db/delius_app_schema_password" },
        { "name": "SPRING_LDAP_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password" },
        { "name": "OID_PASSWORD", "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password" }
    ]
}]