[{
    "name": "${app_name}",
    "image": "tomcat:${tomcat_version}",
    "essential": true,
    "command": ["sh", "-c", "echo '${script}' | base64 -d > startup.sh && chmod +x startup.sh && ./startup.sh"],
    "environment": [
        { "name": "PWM_APPLICATIONPATH", "value": "/usr/local/pwm" },
        { "name": "PWM_CONFIG_PASSWORD_HASH", "value": "${config_password_hash}" }
    ],
    "secrets": [
        { "name": "PWM_SECURITY_KEY",       "valueFrom": "${ssm_prefix}/pwm/pwm/security_key" },
        { "name": "PWM_CONFIG_PASSWORD",    "valueFrom": "${ssm_prefix}/pwm/pwm/config_password" },
        { "name": "PWM_LDAP_BIND_PASSWORD", "valueFrom": "${ssm_prefix}/apacheds/apacheds/ldap_admin_password" }
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