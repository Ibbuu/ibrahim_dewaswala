#!/bin/bash
sudo yum update -y
sudo yum install python3 -y
sudo yum install python3-pip -y
sudo pip install flask
sudo pip install pymysql
sudo cat > backend.py << EOL
from flask import Flask, request,jsonify
import pymysql
import argparse


parser = argparse.ArgumentParser(description ='DB CREDS')

parser.add_argument('--host')
parser.add_argument('--user')
parser.add_argument('--db')
parser.add_argument('--password')
args = parser.parse_args()
db = pymysql.connect(args.host, args.user, args.password, args.db)

app = Flask(__name__)

@app.route('/')
def default_health():
    return "Hello"


@app.route('/get_records')
def get_records():
    cursor = db.cursor()
    sql = "SELECT * FROM test"
    cursor.execute(sql)
    results = cursor.fetchall()
    return jsonify(data=results)

if __name__ == '__main__':
    app.run(debug=True,port=80)

EOL
python backend.py --host ${host} --db ${db} --user ${user} --password ${password}