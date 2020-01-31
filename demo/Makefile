#############################################################
# Lance une instance du serveur sur localhost (port 8080)

LEARN_OCAML_FLAGS=-v
REPO=.
DIR=$(REPO)/www
SYNC=sync

all:	build serve

build:
	learn-ocaml build -o $(DIR) --repo $(REPO) $(LEARN_OCAML_FLAGS) --timeout 4
serve:
	learn-ocaml serve -o $(DIR) --port 8080 $(LEARN_OCAML_FLAGS) --timeout 4
clean:
	rm -r $(DIR)
	rm -r $(SYNC)