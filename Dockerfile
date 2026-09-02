FROM ruby:3.3.7-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev postgresql-client curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN chmod +x bin/*

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
