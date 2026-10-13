SCAD := bookshelf.scad
PARTS := half_shell test_coupon
VIEWS := assembly exploded half_shell test_coupon
PNG_OPTS := --imgsize=1200,900 --viewall --autocenter --colorscheme=Tomorrow

# --init がないと、コンテナ内の xvfb-run が Xvfb の起動待ちのまま止まる
ifdef USE_DOCKER
OPENSCAD := docker run --rm --init -v "$(CURDIR)":/work -w /work openscad/openscad:2021.01 xvfb-run -a openscad
else
OPENSCAD ?= openscad
endif

.PHONY: all stl png clean
all: stl png
stl: $(PARTS:%=stl/%.stl)
png: $(VIEWS:%=docs/%.png)

stl/%.stl: $(SCAD)
	@mkdir -p $(@D)
	$(OPENSCAD) -D 'part="$*"' -o $@ $<

docs/%.png: $(SCAD)
	@mkdir -p $(@D)
	$(OPENSCAD) -D 'part="$*"' $(VIEW_OPTS) $(PNG_OPTS) -o $@ $<

docs/exploded.png: VIEW_OPTS := -D cols=1 -D rows=1
docs/test_coupon.png: VIEW_OPTS := --camera=0,0,0,35,0,0,0

clean:
	rm -f $(PARTS:%=stl/%.stl) $(VIEWS:%=docs/%.png)
