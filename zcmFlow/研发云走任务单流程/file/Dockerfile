FROM 10.45.80.1/public/nginx:1.16.0

LABEL maintainer=cai.zhengluan

# 与 Tomcat 镜像保持一致
EXPOSE 8080

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY dist /srv/http
