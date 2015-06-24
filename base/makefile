.SUFFIXES:.erl .beam

.erl.beam:erlc -W $<

ERL=erl -boot start_clean 

MODS=hello shop
    
all:compile
    ${ERL} -pa '/home/zhaozw/Erlang' -s shop start    
compile:${MODS:%=%.beam}

clean:rm -rf *.beam erl_crash.dump
