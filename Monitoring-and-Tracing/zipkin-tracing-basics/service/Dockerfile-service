FROM envoyproxy/envoy-alpine:v1.21-latest

ADD repositories /etc/apk/repositories
RUN apk update && apk --no-cache -U add py3-pip bash curl
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && \
  pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple -q Flask==0.12.4 requests==2.21.0
RUN mkdir /code
ADD ./service.py /code
ADD ./start_service.sh /usr/local/bin/start_service.sh
RUN chmod u+x /usr/local/bin/start_service.sh
ENTRYPOINT ["/bin/sh", "/usr/local/bin/start_service.sh"]
