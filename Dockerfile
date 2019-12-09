FROM ruby:2.6.3

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN gem install bundler
RUN bundle install --system

ADD . /app
RUN bundle install --system

EXPOSE 4567

HEALTHCHECK CMD curl --fail http://localhost:4567?term=project || exit 1
CMD ["ruby", "search.rb"]
