VERSION 0.6
ARG ELIXIR=1.13.4
ARG OTP=25.1.2

setup-base:
  FROM hexpm/elixir:$ELIXIR-erlang-$OTP-alpine-3.16.2
  RUN apk add --no-progress --update git build-base
  ENV ELIXIR_ASSERT_TIMEOUT=10000
  WORKDIR /src

  RUN mix local.hex --force && mix local.rebar --force

  COPY mix.exs mix.lock ./
  COPY config config
  RUN mix do deps.get, deps.compile

  COPY . .

  RUN mix compile --warnings-as-errors

linter-test:
  FROM +setup-base

  RUN mix format --check-formatted
  RUN mix credo --strict
  RUN mix dialyzer

  ENV MIX_ENV=test
  RUN mix test --trace
  RUN mix coveralls
