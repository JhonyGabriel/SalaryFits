FROM ruby:3.0.1

ENV BUNDLER_VERSION=2.2.15

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

WORKDIR /app
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
