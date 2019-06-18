[{
    "name": "${container_name}",
    "image": "${image_url}:${version}",
    "essential": true,
    "portMappings": [{
        "hostPort": 8080,
        "containerPort": 8080
    }],
    "memory": 2048
}]