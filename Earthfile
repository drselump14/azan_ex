VERSION 0.6

ARG ELIXIR=1.13.4
ARG OTP=25.1.2
FROM hexpm/elixir:$ELIXIR-erlang-$OTP-alpine-3.16.2
WORKDIR /src

setup-mix:
  RUN apk add --no-progress --update git build-base
  ENV ELIXIR_ASSERT_TIMEOUT=10000

  RUN mix local.hex --force && mix local.rebar --force

deps-get:
  FROM +setup-mix
  COPY mix.exs mix.lock ./
  COPY config config
  RUN mix do deps.get, deps.compile

  RUN mix hex.audit
  RUN mix deps.unlock --check-unused

  RUN mix dialyzer --plt
  SAVE ARTIFACT /src/deps
  SAVE ARTIFACT /src/_build
  SAVE IMAGE --push ghcr.io/drselump14/azan_ex:deps-plts

linter:
  FROM +setup-mix
  COPY +deps-get/deps /src/deps
  COPY +deps-get/_build /src/_build

  COPY . .

  RUN mix deps.audit
  RUN mix format --dry-run --check-formatted
  RUN mix credo --strict

  SAVE IMAGE --push ghcr.io/drselump14/azan_ex:linter
  # TODO add Documentation
  # RUN mix doctor

dialyzer:
  FROM +linter

  RUN mix compile --all-warnings --warnings-as-errors
  RUN mix dialyzer --halt-exit-status
  SAVE IMAGE --push ghcr.io/drselump14/azan_ex:compile

test:
  FROM +linter

  ENV MIX_ENV=test
  RUN mix compile --all-warnings --warning-as-errors
  RUN mix test --trace
  RUN mix coveralls
  SAVE IMAGE --push ghcr.io/drselump14/azan_ex:compile_test
