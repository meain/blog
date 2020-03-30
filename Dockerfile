FROM jekyll/jekyll:latest

RUN gem install bourbon

# COPY . /data
VOLUME /data
WORKDIR /data

CMD jekyll serve
