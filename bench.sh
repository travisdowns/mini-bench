#!/bin/bash

set -euo pipefail

echo "GB_TO_PRODUCE=${GB_TO_PRODUCE:=20}"
echo "NODES=${NODES:=3}"
echo "SIZE=${SIZE:=150000}"
echo "REPLICAS=${REPLICAS:=3}"
echo "PARTITIONS=${PARTITIONS:=1}"

MESSAGES=$((GB_TO_PRODUCE * 10**9 / SIZE))

BENCH=./librdkafka/examples/rdkafka_performance

if [ ! -f $BENCH ]; then
  git clone https://github.com/confluentinc/librdkafka && ( cd librdkafka && ./configure && make -j $(nproc) ) && echo "Build librdkafka"
fi

if [ ! -f ./rpk ]; then
  if [ ! -f ./rpk-linux-amd64.zip ]; then
    curl -L 'https://github.com/redpanda-data/redpanda/releases/download/v23.2.21/rpk-linux-amd64.zip' > rpk.zip
  fi
  unzip rpk.zip
fi

./rpk container purge
./rpk container start --nodes=$NODES --set 'rpk.additional_start_flags=[--smp=1,--memory=4G]' --retries=10 > start_out

BROKERS=$(grep 'RPK_BROKERS' start_out | grep -Eo '127[0-9:,.]*')
echo "BROKERS=$BROKERS"
export RPK_BROKERS=$BROKERS

./rpk cluster info
./rpk topic delete t1
./rpk topic create t1 -p"$PARTITIONS" -r"$REPLICAS"

sleep 3s

echo "Writing $GB_TO_PRODUCE GB ($MESSAGES messages x $SIZE bytes)"

( set -x; $BENCH -P -t t1 -s $SIZE -p0 -u -b$BROKERS -c $MESSAGES )

echo "Consuming $GB_TO_PRODUCE GB ($MESSAGES messages x $SIZE bytes)"

( set -x; $BENCH -C -t t1 -p0 -u -b$BROKERS -c$MESSAGES )
