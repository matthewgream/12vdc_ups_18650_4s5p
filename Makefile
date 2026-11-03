
OPENSCAD ?= openscad
XVFB_RUN ?= xvfb-run
CLANG_FMT?= clang-format-22

# ===========================================================================
# 12 VDC UPS enclosure (4s5p 18650) + cell-pack welding / assembly jig.
#
#   housing_ups_12vdc.scad        -> base + cover (export one part at a time with
#                                    -D part="..."), plus assembly-preview PNGs
#   harness_cell_pack_18650.scad  -> footer (full welding tray) + spacer
#                                    (inter-cell anti-compression spacer, print x2)
#
# OpenSCAD v2021.01 (emits ASCII STL). STL export runs headless; the PNG previews
# need a GL context, so those recipes wrap OpenSCAD in `xvfb-run` (a silent 0-byte
# PNG otherwise). Each file is modelled in print orientation -> STL goes straight
# to the slicer. Tunables live at the top of each .scad.
# ===========================================================================

HOUSING       = housing_ups_12vdc
HOUSING_PARTS = base cover
HOUSING_VIEWS = assembly plan
HOUSING_STL   = $(foreach p,$(HOUSING_PARTS),$(HOUSING)_$(p).stl)
HOUSING_PNG   = $(foreach p,$(HOUSING_VIEWS),$(HOUSING)_$(p).png)

HARNESS       = harness_cell_pack_18650
HARNESS_PARTS = footer spacer
HARNESS_STL   = $(foreach p,$(HARNESS_PARTS),$(HARNESS)_$(p).stl)

.PHONY: all stl png clean format
all: stl png

stl: $(HOUSING_STL) $(HARNESS_STL)

png: $(HOUSING_PNG)

$(HOUSING)_%.stl: $(HOUSING).scad
	$(OPENSCAD) -o $@ -D 'part="$*"' $<

$(HOUSING)_assembly.png: $(HOUSING).scad
	$(XVFB_RUN) -a $(OPENSCAD) -o $@ --imgsize=1300,1400 --projection=p --viewall --autocenter --camera=0,0,0,62,0,210,0 -D 'part="assembly"' $<

$(HOUSING)_plan.png: $(HOUSING).scad
	$(XVFB_RUN) -a $(OPENSCAD) -o $@ --imgsize=1100,1700 --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 -D 'part="assembly"' $<

$(HARNESS)_%.stl: $(HARNESS).scad
	$(OPENSCAD) -o $@ -D 'part="$*"' $<

format:
	$(CLANG_FMT) -i $(HOUSING).scad $(HARNESS).scad

clean:
	rm -f $(HOUSING_STL) $(HOUSING_PNG) $(HARNESS_STL)
