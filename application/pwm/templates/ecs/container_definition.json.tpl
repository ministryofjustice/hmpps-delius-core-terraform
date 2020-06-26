[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "memory": ${memory},
    "portMappings": [{
        "hostPort": 8080,
        "containerPort": 8080
    }],
    "mountPoints": [{
        "sourceVolume": "pwm",
        "containerPath": "${config_location}"
    }],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    }
}]