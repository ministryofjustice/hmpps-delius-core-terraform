{
      "Version": "2012-10-17",
      "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "batch:SubmitJob"
                ],
                "Resource": [
                    "${job_queue_arn}",
                    "${job_definition_arn}"
                ]
            }
        ]
}