Basic rdkafka_performance (from librdkafka/examples) benchmark.

In phase 1 it produces (no consumption during this phase) a fixed amount of data to a single partition topic, 
then in a second phase consumes it (no producton) with a single consumer. 

### Usage

Just run `./bench`.

If you check the top of the script there are a few tunables you can override with 
environment variables.
