#!/bin/sh
exec erl \
    -pa ebin deps/*/ebin \
    -boot start_sasl \
    -sname qs_dev \
    -s qs \
    -s reloader
