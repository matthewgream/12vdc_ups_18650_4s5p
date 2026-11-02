
OPENSCAD ?= openscad

# ===========================================================================
# 12 VDC UPS enclosure (4s5p 18650) + cell-pack welding / assembly jig.
#
#   housing_ups_12vdc.scad        -> base + cover (export one part at a time with
#                                    -D part="..."), plus assembly-preview PNGs
#   18650-cell-pack-harness.scad  -> footer (full welding tray) + spacer
#                                    (inter-cell anti-compression spacer, print x2)
#
# OpenSCAD v2021.01 (emits ASCII STL). STL export runs headless; the PNG previews
# need a GL context, so those recipes wrap OpenSCAD in `xvfb-run` (a silent 0-byte
# PNG otherwise). Each file is modelled in print orientation -> STL goes straight
# to the slicer. Tunables live at the top of each .scad.
# ===========================================================================

UPS          = housing_ups_12vdc
UPS_PARTS    = base cover
UPS_STL      = $(foreach p,$(UPS_PARTS),$(UPS)_$(p).stl)
UPS_IMG      = $(UPS)_assembly.png $(UPS)_plan.png

HARNESS       = 18650-cell-pack-harness
HARNESS_PARTS = footer spacer
HARNESS_STL   = $(foreach p,$(HARNESS_PARTS),$(HARNESS)_$(p).stl)

.PHONY: all stl images clean
all: stl images

stl: $(UPS_STL) $(HARNESS_STL)

images: $(UPS_IMG)

$(UPS)_%.stl: $(UPS).scad
	$(OPENSCAD) -o $@ -D 'part="$*"' $<

$(UPS)_assembly.png: $(UPS).scad
	xvfb-run -a $(OPENSCAD) -o $@ --imgsize=1300,1400 --projection=p --viewall --autocenter --camera=0,0,0,62,0,210,0 -D 'part="assembly"' $<

$(UPS)_plan.png: $(UPS).scad
	xvfb-run -a $(OPENSCAD) -o $@ --imgsize=1100,1700 --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 -D 'part="assembly"' $<

$(HARNESS)_%.stl: $(HARNESS).scad
	$(OPENSCAD) -o $@ -D 'part="$*"' $<

clean:
	rm -f $(UPS_STL) $(UPS_IMG) $(HARNESS_STL)
