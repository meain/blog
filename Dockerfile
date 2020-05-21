FROM jekyll/jekyll:latest

RUN gem install bourbon jekyll-turbolinks

# COPY . /data
VOLUME /data
WORKDIR /data

CMD jekyll serve
