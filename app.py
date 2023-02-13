import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis.default.svc.cluster.local', port=6379, db=0, password='v3ng34nc3')

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

@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
