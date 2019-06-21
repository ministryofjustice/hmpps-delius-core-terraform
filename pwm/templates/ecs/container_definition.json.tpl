[{
    "name": "pwm",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "memory": 2048,
    "portMappings": [{
        "hostPort": 8080,
        "containerPort": 8080
    }],
    "mountPoints": [{
        "sourceVolume": "pwm",
        "containerPath": "${config_location}"
    }]
}]