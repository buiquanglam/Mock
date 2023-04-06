# syntax=docker/dockerfile:1
FROM python:3.7-alpine
WORKDIR /code
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
ENV FLASK_APP=application.py
ENV FLASK_RUN_HOST=0.0.0.0
#ENV REDIS_MODE=CLUSTER
#ENV REDIS_HOST=redis-node-0.redis-cluster.default.svc.cluster.local
#ENV REDIS_PORT=6379
#ENV REDIS_DB=0
ENV REDIS_MODE=STANDALONE
ENV REDIS_HOST=redis-16709.c264.ap-south-1-1.ec2.cloud.redislabs.com
ENV REDIS_PORT=16709
ENV REDIS_DB=0
ENV REDIS_PASSWORD=PiXz0qWVgER188r9uHjDHh3rjvEx4XYf
CMD ["flask", "run"]