[{
    "name": "${container_name}",
    "image": "${image_url}",
    "essential": true,
    "memory": ${memory},
    "cpu": ${cpu},
    "portMappings": [{ "hostPort": 80, "containerPort": 80 }],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    },
    "command": ["sh", "-c", "echo '${nginx_config}' > /etc/nginx/conf.d/default.conf && echo \"${angular_config}\" > /usr/share/nginx/html/assets/config/config.js && chmod +r -R /usr/share/nginx/html && exec nginx -g 'daemon off;'"]
}]