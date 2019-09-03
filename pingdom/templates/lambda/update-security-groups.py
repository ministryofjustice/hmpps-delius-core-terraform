import base64
import json
import urllib2

import boto3

PINGDOM_URL = 'https://api.pingdom.com/api/2.1/probes'

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    # Load the probes from the url
    probes = json.loads(get_probes_json())

    # extract ip ranges for the EU region
    eu_ranges = get_ranges_for_region(probes, 'EU')

    # update the security groups
    ec2 = boto3.client('ec2')
    security_group = ec2.describe_security_groups(GroupIds=['${security_group_id}'])['SecurityGroups'][0]
    print('Security group: ' + str(security_group))
    result = update_security_group(ec2, security_group, eu_ranges, 443)

    return result

def get_probes_json():
    print("Fetching creds")
    # TODO params need to be pulled from engineering-dev account
    # ssm = boto3.client('ssm')
    # username = ssm.get_parameter(Name='/engineering-dev/engineering/pingdom/admin/username', WithDecryption=True)['Parameter']['Value']
    # password = ssm.get_parameter(Name='/engineering-dev/engineering/pingdom/admin/password', WithDecryption=True)['Parameter']['Value']
    # api_key = ssm.get_parameter(Name='/engineering-dev/engineering/pingdom/admin/api_key', WithDecryption=True)['Parameter']['Value']
    # account_email = ssm.get_parameter(Name='/engineering-dev/engineering/pingdom/admin/account_email', WithDecryption=True)['Parameter']['Value']
    username = "${username}"
    password = "${password}"
    api_key = "${api_key}"
    account_email = "${account_email}"

    print("Updating from " + PINGDOM_URL)
    request = urllib2.Request(PINGDOM_URL, headers={
        "Authorization": "Basic " + str(base64.b64encode((username + ":" + password).encode("utf-8"))),
        "App-Key": api_key,
        "Account-Email": account_email
    })
    response = urllib2.urlopen(request)
    probes_json = response.read()

    return probes_json

def get_ranges_for_region(ranges, region):
    region_ranges = list()
    for probe in ranges['probes']:
        if probe['region'] == region:
            print('Found ' + str(probe['id']) + ' ' + probe['name'] + '. region: ' + probe['region'] + '. range: ' + probe['ip'])
            region_ranges.append(probe['ip'] + '/32')

    return region_ranges

def update_security_group(client, group, new_ranges, port):
    added = 0
    removed = 0

    if len(group['IpPermissions']) > 0:
        for permission in group['IpPermissions']:
            if permission['FromPort'] <= port and permission['ToPort'] >= port :
                old_prefixes = list()
                to_revoke = list()
                to_add = list()
                for range in permission['IpRanges']:
                    cidr = range['CidrIp']
                    old_prefixes.append(cidr)
                    if new_ranges.count(cidr) == 0:
                        to_revoke.append(range)
                        print(group['GroupId'] + ": Revoking " + cidr + ":" + str(permission['ToPort']))

                for range in new_ranges:
                    if old_prefixes.count(range) == 0:
                        to_add.append({ 'CidrIp': range })
                        print(group['GroupId'] + ": Adding " + range + ":" + str(permission['ToPort']))

                removed += revoke_permissions(client, group, permission, to_revoke)
                added += add_permissions(client, group, permission, to_add)
    else:
        to_add = list()
        for range in new_ranges:
            to_add.append({ 'CidrIp': range })
            print(group['GroupId'] + ": Adding " + range + ":" + str(port))
        permission = { 'ToPort': port, 'FromPort': port, 'IpProtocol': 'tcp'}
        added += add_permissions(client, group, permission, to_add)

    print (group['GroupId'] + ": Added " + str(added) + ", Revoked " + str(removed))
    return (added > 0 or removed > 0)

def revoke_permissions(client, group, permission, to_revoke):
    if len(to_revoke) > 0:
        revoke_params = {
            'ToPort': permission['ToPort'],
            'FromPort': permission['FromPort'],
            'IpRanges': to_revoke,
            'IpProtocol': permission['IpProtocol']
        }

        client.revoke_security_group_ingress(GroupId=group['GroupId'], IpPermissions=[revoke_params])

    return len(to_revoke)

def add_permissions(client, group, permission, to_add):
    if len(to_add) > 0:
        add_params = {
            'ToPort': permission['ToPort'],
            'FromPort': permission['FromPort'],
            'IpRanges': to_add,
            'IpProtocol': permission['IpProtocol']
        }

        client.authorize_security_group_ingress(GroupId=group['GroupId'], IpPermissions=[add_params])

    return len(to_add)
