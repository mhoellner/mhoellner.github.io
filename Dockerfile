FROM ruby:2.7.4-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc g++ make patch \
    nodejs python3-pygments \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

COPY ./Gemfile ./
# COPY ./Gemfile.lock ./
RUN bundle install

WORKDIR /blog

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
