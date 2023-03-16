import time

import redis
from flask import Flask

application = Flask(__name__)
cache = redis.Redis(host='redis-16709.c264.ap-south-1-1.ec2.cloud.redislabs.com', port=16709, db=0, password='PiXz0qWVgER188r9uHjDHh3rjvEx4XYf')

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@application.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
