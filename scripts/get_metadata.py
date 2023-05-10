import boto3
import argparse

parser = argparse.ArgumentParser()

parser.add_argument("--id","-i",help="EC2 instance id")
parser.add_argument("--key","-k",help="Key to retrieve value for from metadata")
args = parser.parse_args()


ec2 = boto3.client('ec2')
response = ec2.describe_instances(InstanceIds=[args.id])

def get_value(res, key):
    if type(res) == dict:
        if key in res:
            return res[key]
        for value in res.values():
            result = get_value(value, key)
            if result is not None:
                return result
    elif type(res) == list:
        for item in res:
            result = get_value(item, key)
            if result is not None:
                return result
    return None

print(get_value(response,args.key))