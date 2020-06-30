[{
    "name": "${app_name}",
    "image": "${image}",
    "essential": true,
    "secrets": [
        { "name": "SECURITY_KEY",       "valueFrom": "${ssm_prefix}/pwm/pwm/security_key" },
        { "name": "CONFIG_PASSWORD",    "valueFrom": "${ssm_prefix}/pwm/pwm/config_password" },
        { "name": "LDAP_PASSWORD",      "valueFrom": "${ssm_prefix}/apacheds/apacheds/ldap_admin_password" }
    ],
    "portMappings": [{ "hostPort": 8080, "containerPort": 8080 }],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${app_name}"
        }
    },
    "cpu": ${cpu},
    "memory": ${memory}
}]