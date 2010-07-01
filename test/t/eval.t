# vi:filetype=perl

use lib 'lib';
use Test::Nginx::Socket;

repeat_each(2);

plan tests => repeat_each() * (blocks() * 3);

worker_connections(128);
run_tests();

no_diff();

__DATA__

=== TEST 1: sanity
--- http_config
    upstream database {
        postgres_server     127.0.0.1 dbname=test user=monty password=some_pass;
    }

    server {
        listen  8100;

        location / {
           echo -n  "it works!";
        }
    }
--- config
    location /eval {
        eval_subrequest_in_memory  off;

        eval $backend {
            postgres_pass    database;
            postgres_query   "select 'http://127.0.0.1:8100'";
            postgres_output  value 0 0;
        }

        proxy_pass $backend;
    }
--- request
GET /eval
--- error_code: 200
--- response_headers
Content-Type: text/plain
--- response_body eval
"it works!"
--- timeout: 10
--- skip_nginx: 3: >= 0.8.42