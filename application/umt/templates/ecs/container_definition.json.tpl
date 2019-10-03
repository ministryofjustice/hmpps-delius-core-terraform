[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "memory": ${memory},
    "portMappings": [{
        "hostPort": 8080,
        "containerPort": 8080
    }],
    "healthCheck": {
        "command": [ "CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:8080/umt/actuator/health || exit 1" ]
    },
    "mountPoints": [{
        "sourceVolume": "config",
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