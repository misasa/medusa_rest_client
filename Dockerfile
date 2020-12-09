FROM ruby:2.7
RUN gem install bundler
#RUN bundle config --global frozen 1
WORKDIR /usr/src/app
COPy ./data/dotorochirc /root/.orochirc
COPY . .
RUN bundle install
RUN rm -r pkg | bundle exec rake build medusa_rest_client.gemspec
RUN gem install pkg/medusa_rest_client-*.gem
CMD ["/bin/bash"]
#ENTRYPOINT ["medusa"]
