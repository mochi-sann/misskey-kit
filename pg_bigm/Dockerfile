FROM public.ecr.aws/docker/library/postgres:15-trixie AS pg_bigm

RUN apt-get update
RUN  apt-get install -y --no-install-recommends \
  ca-certificates git make gcc postgresql-server-dev-15 libicu-dev \
  && update-ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN git clone -b REL1_2_STABLE --depth 1 https://github.com/pgbigm/pg_bigm.git
WORKDIR /pg_bigm
RUN make USE_PGXS=1 && make USE_PGXS=1 install

FROM public.ecr.aws/docker/library/postgres:15-trixie

RUN apt-get update \
  && apt-get install -y --no-install-recommends pgbackrest \
  && rm -rf /var/lib/apt/lists/*

COPY --from=pg_bigm /usr/share/postgresql/15/extension/* /usr/share/postgresql/15/extension/
COPY --from=pg_bigm /usr/lib/postgresql/15/lib/*         /usr/lib/postgresql/15/lib/
COPY --chmod=755 pgbackrest-env /usr/local/bin/pgbackrest-env
# init 時に CREATE EXTENSION するのが確実



