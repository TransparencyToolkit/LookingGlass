FROM ruby:2.4.1
RUN apt-get update -qq && apt-get install -y build-essential 
RUN mkdir /lookingglass
WORKDIR /lookingglass
ADD * /lookingglass/
RUN bundle install
ADD . /lookingglass