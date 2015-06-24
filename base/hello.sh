#!/bin/sh
erl -noshell -pa /home/zhaozw\
    -s hello start -s init stop
