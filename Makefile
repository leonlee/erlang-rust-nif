ERLANG_SRC_DIR ?= /home/erszcz/.kerl/builds/17.0/otp_src_17.0
ERLANG_PLATFORM ?= x86_64-unknown-linux-gnu

ERLNIF_INCLUDES := \
	-I ${ERLANG_SRC_DIR}/erts/emulator/beam \
	-I ${ERLANG_SRC_DIR}/erts/include/${ERLANG_PLATFORM}

## Just for now. Lame but works...
priv/er.so: c_src/er.o rust_src/target/liberrust.so
	-mkdir priv
	${CC} -fPIC -shared -L rust_src/target/ $< -o $@ -l errust

c_src/er.o: c_src/er.c
	${CC} ${ERLNIF_INCLUDES} -fPIC -c -o $@ $<

rust_src/target/liberrust.so: rust_src/src/c.rs
	cd rust_src && cargo build && cd target && ln -s liber-*.so liberrust.so

ERL_NIF_H := ${ERLANG_SRC_DIR}/erts/emulator/beam/erl_nif.h

BINDGEN ?= bindgen

rust_src/src/c.rs: ${ERL_NIF_H}
	${BINDGEN} ${ERLNIF_INCLUDES} $< -o $@