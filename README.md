Distributed-jmeter
===

To run test:

Pre-requisite:
    1. Install docker and docker-compose

1. Script to run test:

        $ run.sh <thread_count> <script_path> <slave_count>

    e.g. To simulate 10 threads running a .jmx script on 5 slaves

        $ run.sh 10 script/sample.jmx 5

2. stop and remove master, slave instances

        $ docker-compose stop && docker-compose rm -f

3. Results will be availabe in the _results_ folder
