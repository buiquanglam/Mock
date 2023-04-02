import os
import time
from flask_wtf.csrf import CSRFProtect

import redis
from flask import Flask, render_template

application = Flask(__name__, static_url_path='',
                    static_folder='web/static',
                    template_folder='web/templates',)
csrf = CSRFProtect()
csrf.init_app(application)  # Compliant

if os.getenv('REDIS_MODE', 'STANDALONE') == 'CLUSTER':
    cache = redis.cluster.RedisCluster(host=os.getenv('REDIS_HOST'), port=int(os.getenv('REDIS_PORT')))
else:
    cache = redis.Redis(host=os.getenv('REDIS_HOST'), port=int(os.getenv('REDIS_PORT')),
                        db=int(os.getenv('REDIS_DB')), password=os.getenv('REDIS_PASSWORD'))


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
    # return 'Hello World 1! I have been seen {} times.\n'.format(count)
    return render_template('index.html', count=count)
