LIGO_VERSION=0.73.0
LIGO=docker run --rm -v "C:\Users\alexh\OneDrive\Bureau\ESGI\5eme annee\Tezos\tezos_tp":/home/usr/ligo -w /home/usr/ligo ligolang/ligo:$(LIGO_VERSION)
#LIGO=docker run --rm -v $(PWD):/home/usr/ligo -w /home/usr/ligo ligolang/ligo:$(LIGO_VERSION)

image=oxheadalpha/flextesa:20230901
script=nairobibox

###################################

help:
	@echo "Ceci est la section d'aide"

###################################

all: install compile test run-deploy
	@echo "Compiling, testing and deploying code"

###################################

install:
#@npm install
#@yarn --cwd ./scripts/ install
	@$(LIGO) install

###################################

compile: contracts/main.mligo
	@echo "Compiling Tezos Contract..."
	@$(LIGO) compile contract $^ --output-file compiled/main.tz
	@$(LIGO) compile contract contracts/main.mligo --michelson-format json --output-file compiled/main.json

###################################

test:
	@echo "Running tests on Tezos Contract..."
	@$(LIGO) run test ./tests/ligo/main.test.mligo

###################################

run-deploy:
	@npm run deploy

###################################

sandbox-start:
	@docker run --rm --name flextesa-sandbox --detach -p 20000:20000 \
            -e block_time=3 \
            -e flextesa_node_cors_origin='*' \
            $(image) $(script) start

sandbox-stop:
	@docker stop flextesa-sandbox

sandbox-exec:
	@docker exec flextesa-sandbox octez-client gen keys mike
	@docker exec flextesa-sandbox octez-client list known addresses
	@docker exec flextesa-sandbox octez-client get balance for alice
	@docker exec flextesa-sandbox octez-client get balance for bob