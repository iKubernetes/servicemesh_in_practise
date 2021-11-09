#FROM python:3-alpine
FROM alpine:3

ADD service/repositories /etc/apk/repositories
RUN apk update && apk --no-cache -U add py3-pip

RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && \
  pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple -q Flask==0.12.4 requests==2.21.0
COPY . ./app
CMD ["python3", "/app/service/server.py"]
