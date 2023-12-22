Basic rdkafka_performance (from librdkafka/examples) benchmark.

It produces (no consumption) a fixed amount of data to a single partition topic, 
in a second phase consumes it with a single consumer. 

### Usage

Just run `./bench`.

If you check the top of the script there are a few tunables you can override with 
environment variables.
