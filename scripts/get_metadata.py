import boto3
import argparse
import json
from datetime import datetime

parser = argparse.ArgumentParser()

parser.add_argument("--id","-i",help="EC2 instance id")
parser.add_argument("--key","-k",help="Key to retrieve value for from metadata", default="InstanceId")
parser.add_argument('--all',help="If all of metadata is needed." , action='store_true')
args = parser.parse_args()


def convert_datetime_values_to_string(obj):
    if isinstance(obj, dict):
        for key, value in obj.items():
            obj[key] = convert_datetime_values_to_string(value)  # Recursive call for nested dictionaries
    elif isinstance(obj, list):
        for i in range(len(obj)):
            obj[i] = convert_datetime_values_to_string(obj[i])  # Recursive call for nested lists
    elif isinstance(obj, datetime):
        obj = obj.strftime('%Y-%m-%d %H:%M:%S')  # Convert datetime to string representation

    return obj

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

def metadata(args):
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(InstanceIds=[args.id])
    if args.all:
        return json.dumps(convert_datetime_values_to_string(response))
    else:
        return get_value(response,args.key)


print(metadata(args))