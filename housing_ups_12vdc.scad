// housing_ups_12vdc.scad — wall-mount enclosure for a 12 VDC UPS.
//
// Two printed parts (export one at a time with -D part="..."):
//   * base  — a back plate with four raised sides that screws to the wall (4 corner
//             holes). Top & bottom sides fully grilled; the LEFT side grilled over its
//             bottom half (the RIGHT side is kept solid, to back an optional external fuse
//             carrier). The right side carries a panel DC socket at the top, 6 DC-out lead
//             holes below it, and — only with fuse_holder_external — the mounting holes +
//             feed slot + outline of a fuse-carrier standoff block lower down; the top side
//             is fully grilled, or carries panel LEDs when led_side is set. Interior
//             "furniture" (no full dividers): corner brackets that grip a 4s5p 18650
//             pack on one side, side-grip walls + standoffs for a BMS, and four screw
//             posts for a power board above it.
//             mirror_lr flips the whole layout left<->right (pack on the right by default).
//   * cover — a front panel with a short lip that slots INSIDE the base walls, retained
//             by 4 snap lugs that seat in holes in the base side walls. Release: push a
//             lug in through its hole with a screwdriver and lift. Bottom half grilled.
//
// House style: one quiet einstein "hat" monotile, debossed small on the cover. External
// vertical corners rounded.
//
// Model orientation: the BASE is modelled back-down = print orientation. The COVER is
// modelled panel-down = its print orientation (lip + lugs point up); "assembly" flips it.
//
// !! FIT: watch the echo() warnings at the bottom — they flag the pack overrunning the box
//    length, the BMS/board column overrunning the right wall, or the pack depth + standoff
//    exceeding ext_d. Bump ext_w / ext_h / ext_d and the furniture re-places itself.

// ---------------------------------------------------------------------------
// CONFIGURATION — the gross-level choices, in one place (defaults in [brackets]).
// Each flag is defined with its own group below; override on the CLI with
// -D 'name=value' (e.g. openscad -D 'fuse_holder_external=true' ...).
//   part                 "base" | "cover" | "all" | "assembly"  — which part(s) to emit / preview
//   mirror_lr            [true]   L↔R mirror: true = pack on the RIGHT (BMS/board/DC/fuse LEFT)
//   fuse_holder_external [false]  false = internal inline fuses (nothing printed);
//                                 true  = external fuse carrier on the right wall
//                                         (bolt holes + feed slot + wall outline + assembly block)
//   led_side             [false]  false = no top-wall LEDs, top grill runs full width
//                                         (LEDs go elsewhere, e.g. the front panel);
//                                 true  = panel LEDs drilled in the top wall, top grill left half
//   show_components      [true]   assembly view: colour block stand-ins for the fitted parts
//   meter_on, led_cover_on [true] front-panel meter window + relocated LED holes (on the cover)
//   cover_wall_h         [20]     raised side wall on the cover for extra depth (0 = flat cover)

// ==========================================================================
//  PARAMETERS
// ==========================================================================

part = "all";           // "base" | "cover" | "all" (apart) | "assembly" (cover on base)
mirror_lr = true;       // mirror the whole part left<->right: pack RIGHT, BMS/board/DC/fuse LEFT
show_components = true; // "assembly": colour block stand-ins for the fitted parts (illustration, NOT printed)
$fn = $preview ? 48 : 128;

ext_w = 135;                   // X width  (bumped from 125 so the board posts clear the right side)
ext_h = 220;                   // Y height (bumped from 210 for the pack + the lifted BMS/board stack)
ext_d = 55;                    // Z depth
wall = 2.5;                    // side wall thickness
back_t = 2.5;                  // back plate thickness
cover_t = 2.5;                 // cover front-panel thickness
corner_r = 4;                  // rounded external vertical corners
base_wall_h = ext_d - cover_t; // base sides rise this far; cover panel completes ext_d

grill_slot = 2.5; // slot width
grill_pitch = 6;  // slot pitch
grill_marg = 9;   // solid margin kept at wall ends / rims

// -------------------------------- BASE ------------------------------------

screw_d = 4.5;
screw_inset = 5.5;
screw_shift = 30; // move the 4 wall-screws this far toward centre in X (clears the pack brackets)

dc_z_frac = 0.60; // Z centre of the side-wall holes as a fraction of the wall depth (back_t..base_wall_h); 0.5 = mid

dc_input_d = 8; // panel DC socket (top of the RIGHT wall)
dc_input_y = ext_h - wall - 24 - 32;

dc_output_d = 5; // each DC-out lead = 18AWG 2-core + sheath (~5 mm)
dc_output_n = 5;
dc_output_pitch = 10;                         // lead-hole centre-to-centre
dc_output_dc_gap = 20;                        // from the DC socket down to the first (topmost) lead
dc_output_y0 = dc_input_y - dc_output_dc_gap; // topmost lead; the rest step DOWN by dc_output_pitch

led_side = false; // LEDs in the TOP wall? false -> no LED holes (led_* ignored), top grill full width; true -> drill the LEDs, top grill left half only
led_side_d = 16;  // panel LEDs through the TOP wall (big bezels) -- only when led_side
led_side_n = 2;
led_side_offset = 24; // first (rightmost) LED centre, measured in from the right (ext_w) edge
led_side_pitch = 24;  // LED centre-to-centre; the rest step left from the first

fuse_holder_external = false;
fuse_holder_len = 94;                           // along the wall (Y)
fuse_holder_w = 40;                             // up the wall (Z)
fuse_holder_y = 80;                             // centre Y on the wall (below the lead holes)
fuse_holder_z = back_t + fuse_holder_w / 2 + 1; // centre Z (block rests on the back plate)
fuse_holder_screw_d = 4.25;                     // wall through-holes for the carrier's 2 mounting bolts (carrier holes are Ø6)
fuse_holder_screw_cc = 76.5;                    // bolt centre-to-centre, along the block's long (Y) axis
fuse_holder_slot_y = 15;                        // fuse-lead feed-through slot: length along the long (Y) axis
fuse_holder_slot_z = 10;                        // ... and height up the wall (Z); centred on the fuse block

pack_w = 68;                                               // X  (measured pack width; add clearance here for a looser slot)
pack_h = 202.5;                                            // Y  (measured pack length)
pack_depth = 40;                                           // Z  (!! + standoff > ext_d -> see echo)
pack_gap_x = 2.5;                                          // gap from the wall to the bracket's outer leg
pack_gap_y = 2.5;                                          // gap from the wall to the bracket's outer leg
pack_br_leg = 25;                                          // corner-bracket leg length
pack_br_t = 2.5;                                           // bracket wall thickness
pack_br_h = 25;                                            // bracket height
pack_pad_h = 5;                                            // raised floor under each corner -> pack sits proud for airflow
pack_sup_pad_n = 2;                                        // extra mid-span floor pads under the pack (between the corner pads), evenly spaced along Y
pack_sup_pad_len = 25;                                     // Y length of each mid-span pad (spans the full pack width in X, pack_pad_h tall)
pack_sup_pad_tie_w = 5;                                    // zip-tie channel width  (Y) cut straight through each mid-span pad in X
pack_sup_pad_tie_h = 2.5;                                  // zip-tie channel height (Z) of each mid-span pad's zip-tie channel
pack_sup_pad_tie_z = 0.75;                                 // channel's clearance above the pad floor (0 = on the base; 1.25 = centred in pack_pad_h)
pack_x0 = wall + pack_gap_x + pack_br_t;                   // pack left edge (bracket leg sits in the gap, outside this)
pack_y0 = wall + pack_gap_y + pack_br_t;                   // pack bottom edge
pack_x1 = pack_x0 + pack_w;                                // pack right edge
pack_y1 = min(pack_y0 + pack_h, ext_h - wall - pack_br_t); // pack top edge (clamped into the box)

rcol_cx = (pack_x1 + pack_br_t + ext_w - wall) / 2; // centre of the right column (BMS/board), clear of the brackets

bms_w = 34.5;                          // X  (measured)
bms_h = 61;                            // Y  (measured)
bms_lift_z = 5;                        // proud of the back wall (Z)
bms_lift_y = 15;                       // raise the BMS off the bottom wall for wire clearance underneath
bms_tie_w = 5;                         // zip-tie channel width (X) through each BMS standoff pad; bored along Y
bms_tie_h = 2.5;                       // channel height (Z)
bms_tie_z = 0.75;                      // channel clearance above the pad floor (0 = on the back wall)
bms_grip_len = 50;                     // grip-wall length (Y); centred on the BMS outline
bms_grip_t = 2.5;                      // grip-wall thickness (X)
bms_grip_z = back_t + bms_lift_z + 12; // grip-wall height (Z)

bms_power_gap = 15; // clear gap above the BMS

power_w = 50;        // X
power_h = 110;       // Y
power_hole_dx = 43;  // mounting-hole spacing, X
power_hole_dy = 103; // mounting-hole spacing, Y
power_post_d = 7;    // post OD
power_post_h = 5;    // standoff height (airflow under the board)
power_pilot = 3.3;   // pilot for an M4 self-tapping screw

outline_on = true;
outline_t = 0.75; // outline line thickness
outline_h = 0.75; // outline raised height

// -------------------------------- COVER -----------------------------------

// Optional raised side wall on the cover: a flush skirt (same section as the base wall) that
// stacks on the base's top rim to add interior depth WITHOUT touching the already-printed base.
// The lip + lugs below it are unchanged, so the cover still seats the same. 0 = flat cover.
cover_wall_h = 20; // height (Z) of the cover's own side wall; adds this much enclosure depth

lip_h = 5;       // how far the cover lip slots down inside the base walls
lip_t = 2.5;     // lip wall thickness
lip_clear = 0.4; // lip-to-base-wall slide clearance

lug_w = 12;                              // lug width (along the wall)
lug_t = 2.5;                             // lug height along Z (the catch depth)
lug_from_rim = 2.5;                      // lug band, measured in from the cover rim (where it catches the wall hole)
lug_ys = [ ext_h * 0.25, ext_h * 0.75 ]; // 2 lugs per long wall; also drives the matching base holes
lug_reach = wall + lip_clear + 0.2 - 1;  // protrude to just past the outer wall face
lug_hole_clr = 0.6;

meter_on = true;  // rectangular display/meter window through the front panel
meter_w = 60;     // window width  (X)
meter_h = 30;     // window height (Y)
meter_x_in = 5;   // gap from the DC-side edge to the window's near edge
meter_y_in = 25;  // gap from the top edge to the window's top edge
meter_depth = 10; // meter body depth under the panel (assembly clearance block only)
meter_rot = 90;   // rotate the window about its centre (deg); 90 stands it on end (30 wide x 60 tall)

led_cover_on = true;  // vertical pair of relocated LED holes, just outboard of the meter
led_cover_d = 6;      // LED hole Ø
led_cover_x = 10;   // LED column centre, in from the DC-side edge (sits between meter & edge)
led_cover_y1 = 15;    // first (upper) LED centre, down from the top edge
led_cover_pitch = 10; // next LED this far below the first (centre-to-centre)
led_cover_n = 2;      // LEDs in the column
led_cover_rot = 0;    // rotate the LED column about the first LED (deg); 90 lays it horizontal

mono_on = false;
mono_w = 24;     // debossed hat width on the cover
mono_sink = 0.8; // deboss depth
mono_x = 0.55;   // hat centre X as a fraction of ext_w
mono_y = 0.885;  // hat centre Y as a fraction of ext_h
mono_rot = -90;  // hat rotation (deg)

// ------------------------- ASSEMBLY (illustration) ------------------------

pack_body_h = pack_depth; // 18650 pack block height (Z), sits on the pads
bms_body_h = 12;          // BMS board + components thickness (Z)
power_body_h = 15;        // power board + components thickness (Z)
fuse_body_d = 22;         // fuse carrier depth proud of the wall (X, into the box)
dc_body_len = 16;         // DC socket barrel length into the box (X)
led_body_len = 10;        // LED body length into the box (Y)

// ==========================================================================
//  HELPERS
// ==========================================================================

module rrect(w, h, r) offset(r) offset(-r) square([ w, h ], center = true);
module stadium2d(len, thick) hull() for (s = [ -1, 1 ]) translate([ s * (len / 2 - thick / 2), 0 ]) circle(d = thick);

// slot cutters (long axis / thin axis / extruded-through axis):
module xslot(len, thick, ythr) rotate([ 90, 0, 0 ]) linear_extrude(ythr) stadium2d(len, thick);                       // long X, thin Z, thru Y
module yslot(len, thick, xthr) rotate([ 0, -90, 0 ]) linear_extrude(xthr) rotate([ 0, 0, 90 ]) stadium2d(len, thick); // long Y, thin Z, thru X
module zslot(len, thick, zthr) linear_extrude(zthr) stadium2d(len, thick);                                            // long X, thin Y, thru Z

// einstein "hat" monotile, centred on its ink, sized to mono_w wide.
module monotile2d() resize([ mono_w, 0, 0 ], auto = true) translate([ -27.785, -40.02 ]) polygon(points = [
    [ 40.04, 78.63 ], [ 54.16, 70.45 ], [ 54.15, 37.83 ], [ 40.01, 29.67 ], [ 48.15, 15.53 ], [ 40.00, 1.41 ], [ 25.87, 9.58 ], [ 25.88, 25.89 ], [ 9.56, 25.90 ], [ 1.41, 40.04 ], [ 15.54, 48.19 ], [ 15.55, 64.51 ], [ 31.86, 64.50 ]
]);

// ==========================================================================
//  BASE
// ==========================================================================

module base_shell() difference() {
    linear_extrude(base_wall_h) translate([ ext_w / 2, ext_h / 2 ]) rrect(ext_w, ext_h, corner_r);
    translate([ 0, 0, back_t ]) linear_extrude(base_wall_h + 1) translate([ ext_w / 2, ext_h / 2 ]) rrect(ext_w - 2 * wall, ext_h - 2 * wall, max(0.5, corner_r - wall));
}

module base_grills() {
    zs = [for (z = [back_t + grill_marg:grill_pitch:base_wall_h - grill_marg]) z];
    // top wall (+Y) -- full width, unless led_side reserves the right half for the panel LEDs
    tg_x0 = grill_marg;
    tg_x1 = led_side ? ext_w / 2 - 4 : ext_w - grill_marg;
    tg_len = tg_x1 - tg_x0;
    for (z = zs)
        translate([ (tg_x0 + tg_x1) / 2, ext_h + 1, z ]) xslot(tg_len, grill_slot, wall + 2);
    // bottom wall (-Y) -- full width
    bw_len = ext_w - 2 * grill_marg;
    for (z = zs)
        translate([ ext_w / 2, wall + 1, z ]) xslot(bw_len, grill_slot, wall + 2);
    // LEFT wall only -- bottom half (RIGHT wall left solid to back the fuse carrier)
    ly_c = (wall + grill_marg + ext_h / 2) / 2;
    ly_l = ext_h / 2 - wall - grill_marg;
    for (z = zs)
        translate([ wall + 1, ly_c, z ]) yslot(ly_l, grill_slot, wall + 2); // left (-X)
}

module base_apertures() {
    zc = (back_t + base_wall_h) * dc_z_frac; // centre of the wall depth (tunable via dc_z_frac)
    // RIGHT wall: DC socket (top), then 6 DC-out lead holes stepping down (cylinders along X)
    translate([ ext_w - wall - 1, dc_input_y, zc ]) rotate([ 0, 90, 0 ]) cylinder(h = wall + 2, d = dc_input_d);
    for (i = [0:dc_output_n - 1])
        translate([ ext_w - wall - 1, dc_output_y0 - i * dc_output_pitch, zc ]) rotate([ 0, 90, 0 ]) cylinder(h = wall + 2, d = dc_output_d);
    // TOP wall: panel LEDs (cylinders along Y), stepping left from the right end -- only when led_side
    if (led_side)
        for (i = [0:led_side_n - 1])
            translate([ ext_w - led_side_offset - i * led_side_pitch, ext_h - wall - 1, zc ]) rotate([ -90, 0, 0 ]) cylinder(h = wall + 2, d = led_side_d);
    // RIGHT wall: fuse-carrier mounting-bolt holes (2, along Y) + lead feed-through slot, centred on the block
    if (fuse_holder_external) {
        for (s = [ -1, 1 ])
            translate([ ext_w - wall - 1, fuse_holder_y + s * fuse_holder_screw_cc / 2, fuse_holder_z ]) rotate([ 0, 90, 0 ]) cylinder(h = wall + 2, d = fuse_holder_screw_d);
        translate([ ext_w - wall - 1, fuse_holder_y, fuse_holder_z ]) rotate([ 0, 90, 0 ]) linear_extrude(wall + 2) rrect(fuse_holder_slot_z, fuse_holder_slot_y, 3); // 10(Z) x 15(Y) rounded slot
    }
    // BACK plate: 4 wall-screws, shifted toward centre in X to clear the pack brackets
    for (sx = [ screw_inset + screw_shift, ext_w - screw_inset - screw_shift ], sy = [ screw_inset, ext_h - screw_inset ])
        translate([ sx, sy, -1 ]) cylinder(h = back_t + 2, d = screw_d);
    // lug holes in the LEFT & RIGHT walls (centre of the lug band, in from the rim)
    for (y = lug_ys) {
        lz = base_wall_h - lug_from_rim - lug_t / 2;
        translate([ wall / 2, y, lz ]) cube([ wall + 2, lug_w + 2 * lug_hole_clr, lug_t + 2 * lug_hole_clr ], center = true);         // left
        translate([ ext_w - wall / 2, y, lz ]) cube([ wall + 2, lug_w + 2 * lug_hole_clr, lug_t + 2 * lug_hole_clr ], center = true); // right
    }
}

// --- interior furniture ---

module corner_bracket() { // L at origin, legs along +X and +Y, raised floor pad
    linear_extrude(pack_br_h) difference() {
        square([ pack_br_leg, pack_br_leg ]);
        translate([ pack_br_t, pack_br_t ]) square([ pack_br_leg, pack_br_leg ]);
    }
    cube([ pack_br_leg, pack_br_leg, pack_pad_h ]); // raised floor so the pack sits proud
}

module pack_mount() {
    translate([ 0, 0, back_t ]) {                                                                          // each L's inner crook lands exactly on a pack corner -> clear slot = pack_w x pack_h
        translate([ pack_x0 - pack_br_t, pack_y0 - pack_br_t, 0 ]) corner_bracket();                       // bottom-left
        translate([ pack_x1 + pack_br_t, pack_y0 - pack_br_t, 0 ]) rotate([ 0, 0, 90 ]) corner_bracket();  // bottom-right
        translate([ pack_x0 - pack_br_t, pack_y1 + pack_br_t, 0 ]) rotate([ 0, 0, -90 ]) corner_bracket(); // top-left
        translate([ pack_x1 + pack_br_t, pack_y1 + pack_br_t, 0 ]) rotate([ 0, 0, 180 ]) corner_bracket(); // top-right
    }
    L = pack_y1 - pack_y0;
    translate([ 0, 0, back_t ]) for (i = [1:pack_sup_pad_n]) translate([ pack_x0, pack_y0 + i * L / (pack_sup_pad_n + 1) - pack_sup_pad_len / 2, 0 ]) difference() {
        cube([ pack_w, pack_sup_pad_len, pack_pad_h ]);
        translate([ -1, (pack_sup_pad_len - pack_sup_pad_tie_w) / 2, pack_sup_pad_tie_z ]) cube([ pack_w + 2, pack_sup_pad_tie_w, pack_sup_pad_tie_h ]); // tunnel: over-long in X for a clean through-cut
    }
}

module bms_mount() {
    bx0 = rcol_cx - bms_w / 2;
    bx1 = rcol_cx + bms_w / 2;
    y0 = wall + bms_lift_y;                 // lifted off the bottom wall -> wire clearance underneath
    gy = y0 + bms_h / 2 - bms_grip_len / 2; // grip Y start, centred on the BMS length
    translate([ 0, 0, back_t ]) {
        // side grips (just outside the BMS edges), centred on the BMS outline
        translate([ bx0 - bms_grip_t, gy, 0 ]) cube([ bms_grip_t, bms_grip_len, bms_grip_z ]);
        translate([ bx1, gy, 0 ]) cube([ bms_grip_t, bms_grip_len, bms_grip_z ]);
        // standoff pads (BMS back rests on these -> proud of the back wall), each with a
        // zip-tie channel bored right through along Y to lash the BMS down
        for (py = [ y0 + 8, y0 + bms_h - 15 ])
            translate([ rcol_cx - 8, py, 0 ]) difference() {
                cube([ 16, 8, bms_lift_z ]);
                translate([ (16 - bms_tie_w) / 2, -1, bms_tie_z ]) cube([ bms_tie_w, 8 + 2, bms_tie_h ]); // tunnel along Y, over-long for a clean through-cut
            }
    }
}

module power_mount() {
    by0 = wall + bms_lift_y + bms_h + bms_power_gap; // board bottom (above the lifted BMS)
    cy = by0 + power_h / 2;                          // board centre Y
    translate([ 0, 0, back_t ]) for (hx = [ rcol_cx - power_hole_dx / 2, rcol_cx + power_hole_dx / 2 ], hy = [ cy - power_hole_dy / 2, cy + power_hole_dy / 2 ]) translate([ hx, hy, 0 ]) difference() {
        cylinder(h = power_post_h, d = power_post_d);
        translate([ 0, 0, 1 ]) cylinder(h = power_post_h, d = power_pilot);
    }
}

// --- placement outlines ---

module footprint_outline(cx, cy, w, h) // outline sized to the EXACT footprint (grows inward, so the part hides it)
    translate([ 0, 0, back_t ]) linear_extrude(outline_h) difference() {
    translate([ cx, cy ]) square([ w, h ], center = true);
    translate([ cx, cy ]) square([ w - 2 * outline_t, h - 2 * outline_t ], center = true);
}

// raised rectangular outline on the inner face of the RIGHT wall (leny along Y, lenz up Z)
module wall_outline_r(cy, cz, leny, lenz) translate([ ext_w - wall - outline_h / 2, cy, cz ]) difference() {
    cube([ outline_h, leny, lenz ], center = true);
    cube([ outline_h + 0.2, leny - 2 * outline_t, lenz - 2 * outline_t ], center = true);
}

module placement_outlines() {
    footprint_outline((pack_x0 + pack_x1) / 2, (pack_y0 + pack_y1) / 2, pack_w, pack_y1 - pack_y0);        // 18650 pack
    footprint_outline(rcol_cx, wall + bms_lift_y + bms_h / 2, bms_w, bms_h);                               // BMS
    footprint_outline(rcol_cx, wall + bms_lift_y + bms_h + bms_power_gap + power_h / 2, power_w, power_h); // power board
    if (fuse_holder_external)
        wall_outline_r(fuse_holder_y, fuse_holder_z, fuse_holder_len, fuse_holder_w); // external fuse carrier (on the right wall)
}

module base() {
    difference() {
        union() {
            base_shell();
            pack_mount();
            bms_mount();
            power_mount();
            if (outline_on)
                placement_outlines();
        }
        base_grills();
        base_apertures();
    }
}

// ==========================================================================
//  COVER  (modelled panel-DOWN = print orientation: panel on the bed, lip + lugs up)
// ==========================================================================

module cover_lip() { // frame that slots inside the base walls
    ow = ext_w - 2 * wall - 2 * lip_clear;
    oh = ext_h - 2 * wall - 2 * lip_clear;
    translate([ 0, 0, cover_t ]) linear_extrude(lip_h + cover_wall_h) difference() { // runs the full cover height so the lip stays rooted on the panel; only the top lip_h enters the base
        translate([ ext_w / 2, ext_h / 2 ]) rrect(ow, oh, max(0.5, corner_r - wall));
        translate([ ext_w / 2, ext_h / 2 ]) rrect(ow - 2 * lip_t, oh - 2 * lip_t, max(0.5, corner_r - wall - lip_t));
    }
}

module cover_wall() // flush raised skirt: same section as the base wall, stacked on its top rim (print: up from the panel)
    translate([ 0, 0, cover_t ]) linear_extrude(cover_wall_h) difference() {
    translate([ ext_w / 2, ext_h / 2 ]) rrect(ext_w, ext_h, corner_r);
    translate([ ext_w / 2, ext_h / 2 ]) rrect(ext_w - 2 * wall, ext_h - 2 * wall, max(0.5, corner_r - wall));
}

module lug_prism(reach, zlo, zhi, w)                                                                                          // local: shelf at zlo (-> +Z/pull-off after the cover flips), ramp above
    rotate([ 90, 0, 0 ]) translate([ 0, 0, -w / 2 ]) linear_extrude(w) polygon([ [ -1, zlo ], [ reach, zlo ], [ -1, zhi ] ]); // -1 embeds into the lip to fuse

module cover_lugs() { // on the lip outer faces, left & right; print-orientation z = up from panel
    zlo = cover_t + cover_wall_h + lug_from_rim;
    zhi = zlo + lug_t;
    for (y = lug_ys) {
        translate([ ext_w - wall - lip_clear, y, 0 ]) lug_prism(lug_reach, zlo, zhi, lug_w);             // right (+X)
        translate([ wall + lip_clear, y, 0 ]) mirror([ 1, 0, 0 ]) lug_prism(lug_reach, zlo, zhi, lug_w); // left (-X)
    }
}

module cover_grill() { // bottom half of the panel
    ys = [for (y = [wall + grill_marg:grill_pitch:ext_h / 2]) y];
    len = ext_w - 2 * grill_marg;
    for (y = ys)
        translate([ ext_w / 2, y, -1 ]) zslot(len, grill_slot, cover_t + 2);
}

module cover_mono() // one quiet hat, debossed; placement/orientation via mono_x / mono_y / mono_rot
    translate([ ext_w * mono_x, ext_h *mono_y, -0.01 ]) linear_extrude(mono_sink) rotate([ 0, 0, mono_rot ]) monotile2d();

module cover_meter() translate([ meter_x_in + meter_w / 2, ext_h - meter_y_in - meter_h / 2, -1 ]) linear_extrude(cover_t + 2) rotate(meter_rot) square([ meter_w, meter_h ], center = true);

module cover_leds() translate([ led_cover_x, ext_h - led_cover_y1, 0 ]) rotate([ 0, 0, led_cover_rot ]) for (i = [0 :led_cover_n - 1]) translate([ 0, -i *led_cover_pitch, -1 ]) cylinder(h = cover_t + 2, d = led_cover_d);

module cover() {
    difference() {
        union() {
            linear_extrude(cover_t) translate([ ext_w / 2, ext_h / 2 ]) rrect(ext_w, ext_h, corner_r);
            if (cover_wall_h > 0)
                cover_wall();
            cover_lip();
            cover_lugs();
        }
        cover_grill();
        if (mono_on)
            cover_mono();
        if (meter_on)
            cover_meter();
        if (led_cover_on)
            cover_leds();
    }
}

// ==========================================================================
//  ASSEMBLY — mock component blocks (illustration only, NOT printed)
// ==========================================================================
// Each block is placed in the model frame exactly where its furniture seats it, so wrapping
// components() in the same mir() as the base keeps every part aligned after the L<->R flip.

module comp_block(x, y, z, sx, sy, sz, col) // axis-aligned block by min-corner + size
    color(col) translate([ x, y, z ]) cube([ sx, sy, sz ]);

module components() {
    // 18650 pack — rests on the corner + mid-span floor pads
    comp_block(pack_x0, pack_y0, back_t + pack_pad_h, pack_w, pack_y1 - pack_y0, pack_body_h, [ 0.26, 0.34, 0.46 ]);
    // BMS — on its standoff pads, lifted off the floor for wire clearance
    comp_block(rcol_cx - bms_w / 2, wall + bms_lift_y, back_t + bms_lift_z, bms_w, bms_h, bms_body_h, [ 0.15, 0.35, 0.78 ]);
    // power board — on its 4 posts, above the BMS
    comp_block(rcol_cx - power_w / 2, wall + bms_lift_y + bms_h + bms_power_gap, back_t + power_post_h, power_w, power_h, power_body_h, [ 0.16, 0.52, 0.27 ]);
    // fuse carrier — mounts on the OUTSIDE of the solid RIGHT wall; its 2 bolts + the lead slot
    // pass through the wall. Block sits proud of the exterior face, aligned to the wall outline.
    if (fuse_holder_external)
        comp_block(ext_w, fuse_holder_y - fuse_holder_len / 2, back_t + 1, fuse_body_d, fuse_holder_len, fuse_holder_w, [ 0.88, 0.47, 0.11 ]);
    // DC socket — barrel poking in through the RIGHT wall
    color([ 0.12, 0.12, 0.12 ]) translate([ ext_w - wall - dc_body_len, dc_input_y, (back_t + base_wall_h) * dc_z_frac ]) rotate([ 0, 90, 0 ]) cylinder(h = dc_body_len, d = dc_input_d + 3);
    // LEDs — bodies poking in through the TOP wall (only when led_side)
    if (led_side)
        for (i = [0:led_side_n - 1])
            color([ 0.90, 0.22, 0.20 ]) translate([ ext_w - led_side_offset - i * led_side_pitch, ext_h - wall - led_body_len, (back_t + base_wall_h) * dc_z_frac ]) rotate([ -90, 0, 0 ]) cylinder(h = led_body_len, d = led_side_d);
    // meter body — hangs under the front panel; check it clears the pack top (pack top vs base_wall_h)
    if (meter_on)
        translate([ ext_w - meter_x_in - meter_w / 2, ext_h - meter_y_in - meter_h / 2, base_wall_h - meter_depth ]) rotate([ 0, 0, meter_rot ]) comp_block(-meter_w / 2, -meter_h / 2, 0, meter_w, meter_h, meter_depth, [ 0.55, 0.35, 0.65 ]);
}

// ==========================================================================
//  FIT CHECK
// ==========================================================================

echo(str("UPS interior (W x H x D) = ", ext_w - 2 * wall, " x ", ext_h - 2 * wall, " x ", ext_d - back_t + cover_wall_h, " (incl. cover wall ", cover_wall_h, ")"));
if (pack_y0 + pack_h > ext_h - wall - pack_br_t)
    echo(str("WARNING: pack length ", pack_h, " overruns the box (top bracket clamped); raise ext_h ~", pack_y0 + pack_h + wall + pack_br_t + 2));
if (rcol_cx + max(power_w, bms_w) / 2 > ext_w - wall)
    echo(str("WARNING: BMS/board column (right edge ", rcol_cx + max(power_w, bms_w) / 2, ") overruns the right wall at ", ext_w - wall, "; reduce pack_w/power_w or raise ext_w"));
if (pack_depth + pack_pad_h + back_t > ext_d + cover_wall_h)
    echo(str("WARNING: pack depth+standoff ", pack_depth + pack_pad_h + back_t, " > available ", ext_d + cover_wall_h, " (raise ext_d/cover_wall_h ~", pack_depth + pack_pad_h + back_t + cover_t + 2 - (ext_d + cover_wall_h), " more)"));

// ==========================================================================
//  DISPATCH
// ==========================================================================
// mir() reflects a part about its own X mid-plane when mirror_lr is set (applied innermost,
// so the base and the flipped cover stay aligned in X).

module mir() {
    if (mirror_lr)
        translate([ ext_w, 0, 0 ]) mirror([ 1, 0, 0 ]) children();
    else
        children();
}

if (part == "base")
    mir() base();
else if (part == "cover")
    mir() cover();
else if (part == "assembly") {
    color("Gainsboro") mir() base();
    if (show_components)
        mir() components(); // block stand-ins, seated in place, flipped with the base
    // flip the (panel-down) cover LEFT/RIGHT (about its long Y axis) onto the base front — this is
    // how it is assembled, so cover cutouts placed on the DC side land by the DC after the flip
    color("LightSteelBlue", 0.6) translate([ ext_w, 0, base_wall_h + cover_wall_h + cover_t ]) rotate([ 0, 180, 0 ]) mir() cover();
} else { // "all" -- side by side
    mir() base();
    translate([ ext_w + 25, 0, 0 ]) color("LightSteelBlue") mir() cover();
}
