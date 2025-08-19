This Lambda function is used to notify the probation-migritaions-team Slack Channel when an ECS task is scheduled for retirement.

The lambda layer must be built in order to run local terragrunt plans. This can be done by running:
```shell
pip3 install -r ./python/requirements.txt -t ./lambda_layer/python/lib/python3.9/site-packages

cd ./python

zip -r ../assets/slack_sdk_layer.zip .
```

