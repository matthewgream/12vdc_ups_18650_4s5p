// housing_ups_12vdc.scad — wall-mount enclosure for a 12 VDC UPS.
//
// Two printed parts (export one at a time with -D part="..."):
//   * base  — a back plate with four raised sides that screws to the wall (4 corner
//             holes). Top & bottom sides fully grilled; the LEFT side grilled over its
//             bottom half (the RIGHT side is kept solid for a fuse carrier). The right
//             side carries a panel DC socket at the top, 6 DC-out lead holes below it,
//             and the outline of a fuse-carrier standoff block lower down; the top side
//             carries 3 panel-mount LEDs. Interior "furniture" (no full dividers): corner
//             brackets that grip a 4s5p 18650 pack on one side, side-grip walls +
//             standoffs for a BMS, and four screw posts for a power board above it.
//             mirror_lr flips the whole layout left<->right (pack on the right by default).
//   * cover — a front panel with a short lip that slots INSIDE the base walls, retained
//             by 4 snap lugs that seat in holes in the base side walls. Release: push a
//             lug in through its hole with a screwdriver and lift. Bottom half grilled.
//
// House style: AE logo embossed on a visible face of each part; one quiet einstein "hat"
// monotile, debossed small on the cover. External vertical corners rounded.
//
// Model orientation: the BASE is modelled back-down = print orientation. The COVER is
// modelled panel-down = its print orientation (lip + lugs point up); "assembly" flips it.
//
// !! FIT: the stated pack (70 x 225 x 35) does NOT fit the stated box (125 x 210 x 40):
//    taller than the interior, and pack+board wider than the interior, and deeper than
//    the box once a standoff is added. echo() warnings below compute the shortfalls.
//    Bump ext_w / ext_h / ext_d (≈135 x 235 x 48) and the furniture re-places itself.

// === FLAGS ===
part = "all";   // "base" | "cover" | "all" (apart) | "assembly" (cover on base)
mirror_lr = true;   // mirror the whole part left<->right: pack on the RIGHT, BMS/board/cables/DC/fuse on the LEFT

$fn = $preview ? 48 : 128;

// === Enclosure shell ===
ext_w   = 135;   // X width  (bumped from 125 so the board posts clear the right side)
ext_h   = 225;   // Y height (bumped from 210 for the pack + the lifted BMS/board stack)
ext_d   = 48;    // Z depth  (bumped from 40 so the pack + 5 mm standoff fit)
wall    = 2.5;     // side wall thickness
back_t  = 2.5;     // back plate thickness
cover_t = 2.5;     // cover front-panel thickness
corner_r = 4;    // rounded external vertical corners

base_wall_h = ext_d - cover_t;   // 37: base sides rise this far; cover panel completes ext_d

// === Cover lip + snap lugs ===
cover_lip_h = 5;    // how far the cover lip slots down inside the base walls
lip_t       = 2.5;   // lip wall thickness
lip_clear   = 0.4;   // lip-to-base-wall slide clearance
lug_w       = 12;    // lug width (along the wall)
lug_t       = 2.5;     // lug height along Z (the catch depth)
lug_from_rim = 2.5;    // lug band, measured in from the cover rim (where it catches the wall hole)
lug_ys      = [ext_h * 0.10, ext_h * 0.90];   // 2 lugs per long (left/right) wall; tuned to clear the right-wall DC/leads/fuse
lug_reach   = wall + lip_clear + 0.2 - 2;          // protrude to just past the outer wall face
lug_hole_clr = 0.6;

// === Grills (parallel stadium slots) ===
grill_slot  = 2.5;   // slot width
grill_pitch = 6;     // slot pitch
grill_marg  = 9;     // solid margin kept at wall ends / rims

// === Side-wall apertures ===
// RIGHT wall, top -> bottom: DC socket, 6 DC-out lead holes, then the fuse-block outline.
dc_d        = 8;                 // panel DC socket (top of the RIGHT wall)
dc_y        = ext_h - wall - 24;
lead_d      = 5;                 // each DC-out lead = 18AWG 2-core + sheath (~5 mm); 6 of them
lead_n      = 5;
lead_pitch  = 10;                // lead-hole centre-to-centre
lead_dc_gap = 20;                // from the DC socket down to the first (topmost) lead
lead_y0     = dc_y - lead_dc_gap;// topmost lead; the rest step DOWN by lead_pitch
led_d      = 16;                // 3 panel LEDs through the TOP wall (big bezels)
led_n      = 2;
led_offset = 24;                // first (rightmost) LED centre, measured in from the right (ext_w) edge
led_pitch  = 24;                // LED centre-to-centre; the rest step left from the first

// === Fuse carrier (standoff block mounted against the RIGHT wall; outline on the wall's inner face) ===
fuse_on        = true;
fuse_block_len = 94;                        // along the wall (Y)
fuse_block_w   = 40;                        // up the wall (Z)
fuse_block_y   = 80;                        // centre Y on the wall (below the lead holes)
fuse_block_z   = back_t + fuse_block_w/2 + 1;   // centre Z (block rests on the back plate)
fuse_screw_d   = 4.25;     // wall through-holes for the carrier's 2 mounting bolts (carrier holes are Ø6)
fuse_screw_cc  = 76.5;  // bolt centre-to-centre, along the block's long (Y) axis
fuse_slot_y    = 15;    // fuse-lead feed-through slot: length along the long (Y) axis
fuse_slot_z    = 10;    // ... and height up the wall (Z); centred on the fuse block

// === Back-plate wall screws (one per corner) ===
screw_d     = 4.5;
screw_inset = 7.5;
screw_shift = 15;   // move the 4 wall-screws this far toward centre IN X (clears the pack brackets,
                    //   keeps them near the top/bottom edges and clear of the BMS/board)

// === Interior: 4s5p 18650 pack (LEFT), gripped at its corners ===
// pack_w / pack_h are the ACTUAL pack footprint (cells + weld strips + insulation) = the clear slot
// between opposing bracket INNER faces. The L-bracket walls (br_t) sit OUTSIDE this, within pack_gap,
// so they no longer eat into the usable width/height.
pack_w     = 68;  // X  (measured pack width; add clearance here for a looser slot)
pack_h     = 207.5; // Y  (measured pack length)
pack_depth = 35;    // Z  (!! + standoff > ext_d -> see echo)
pack_gap   = 2;     // gap from the wall to the bracket's outer leg
br_leg     = 25;  // corner-bracket leg length
br_t       = 2.5;   // bracket wall thickness
br_h       = 25;    // bracket height
pad_h      = 5;     // raised floor under each corner -> pack sits proud for airflow
sup_pad_n   = 2;    // extra mid-span floor pads under the pack (between the corner pads), evenly spaced along Y
sup_pad_len = 25;   // Y length of each mid-span pad (spans the full pack width in X, pad_h tall)

pack_x0 = wall + pack_gap + br_t;                     // pack left edge (bracket leg sits in the gap, outside this)
pack_y0 = wall + pack_gap + br_t;                     // pack bottom edge
pack_x1 = pack_x0 + pack_w;                           // pack right edge
pack_y1 = min(pack_y0 + pack_h, ext_h - wall - br_t); // pack top edge (clamped into the box)

rcol_cx = (pack_x1 + br_t + ext_w - wall) / 2;   // centre of the right column (BMS/board), clear of the pack brackets

// === Interior: BMS (bottom-right), side-gripped + stood off ===
bms_w       = 34.5; // X  (measured)
bms_h       = 61;   // Y  (measured)
bms_grip_h  = 50;   // grip-wall height (5 of the 6 cm)
bms_standoff = 5;   // proud of the back wall (Z)
bms_lift    = 20;   // raise the BMS off the bottom wall for wire clearance underneath (the strings)
grip_t      = 2.5;
grip_z      = back_t + bms_standoff + 12;   // how tall the side grips stand in Z

// === Interior: power board (above the BMS), on 4 screw posts ===
pb_w        = 50;   // X
pb_h        = 110;  // Y
pb_hole_dx  = 43;   // mounting-hole spacing, X
pb_hole_dy  = 103;  // mounting-hole spacing, Y
pb_post_d   = 7;    // post OD
pb_post_h   = 5;    // standoff height (airflow under the board)
pb_pilot    = 3.3;  // pilot for an M4 self-tapping screw
pb_gap_bms  = 10;   // clear gap above the BMS

// === Placement outlines (raised border on the back wall marking where each board sits) ===
outline_on = true;
border_t   = 1;      // outline line thickness
border_h   = 1;     // outline raised height

// === Logo / monotile ===
logo_file  = "ae_stencil_one.svg";
logo_w     = 22;
logo_sink  = 0.8;
logo_raise = 0.6;
mono_w     = 24;    // debossed hat width on the cover
mono_sink  = 0.8;

// ---------------------------------------------------------------------------
// Helpers
module rrect(w, h, r) offset(r) offset(-r) square([w, h], center = true);
module stadium2d(len, thick)
    hull() for (s = [-1, 1]) translate([s * (len / 2 - thick / 2), 0]) circle(d = thick);

// slot cutters (long axis / thin axis / extruded-through axis):
module xslot(len, thick, ythr) rotate([90, 0, 0]) linear_extrude(ythr) stadium2d(len, thick);   // long X, thin Z, thru Y
module yslot(len, thick, xthr) rotate([0, -90, 0]) linear_extrude(xthr) rotate([0, 0, 90]) stadium2d(len, thick); // long Y, thin Z, thru X
module zslot(len, thick, zthr) linear_extrude(zthr) stadium2d(len, thick);                        // long X, thin Y, thru Z

// AE logo as a 2D outline, sized to logo_w, "ae" reading upward (spun 90).
module logo2d() resize([logo_w, 0, 0], auto = true) rotate([0, 0, 90]) import(logo_file, center = true);

// einstein "hat" monotile, centred on its ink, sized to mono_w wide.
module monotile2d()
    resize([mono_w, 0, 0], auto = true)
        translate([-27.785, -40.02])
            polygon(points = [[40.04,78.63],[54.16,70.45],[54.15,37.83],[40.01,29.67],
                              [48.15,15.53],[40.00,1.41],[25.87,9.58],[25.88,25.89],
                              [9.56,25.90],[1.41,40.04],[15.54,48.19],[15.55,64.51],[31.86,64.50]]);

// ---------------------------------------------------------------------------
// BASE
module base_shell() difference() {
    linear_extrude(base_wall_h) translate([ext_w/2, ext_h/2]) rrect(ext_w, ext_h, corner_r);
    translate([0, 0, back_t])
        linear_extrude(base_wall_h + 1)
            translate([ext_w/2, ext_h/2]) rrect(ext_w - 2*wall, ext_h - 2*wall, max(0.5, corner_r - wall));
}

// grills: top & bottom walls full; left & right walls over their bottom half
module base_grills() {
    zs  = [for (z = [back_t + grill_marg : grill_pitch : base_wall_h - grill_marg]) z];
    // top wall (+Y) -- LEFT half only (right reserved for the LEDs)
    tg_x0 = grill_marg; tg_x1 = ext_w/2 - 4; tg_len = tg_x1 - tg_x0;
    for (z = zs) translate([(tg_x0 + tg_x1)/2, ext_h + 1, z]) xslot(tg_len, grill_slot, wall + 2);
    // bottom wall (-Y) -- full width
    bw_len = ext_w - 2*grill_marg;
    for (z = zs) translate([ext_w/2, wall + 1, z]) xslot(bw_len, grill_slot, wall + 2);
    // LEFT wall only -- bottom half (RIGHT wall left solid to back the fuse carrier)
    ly_c = (wall + grill_marg + ext_h/2) / 2;
    ly_l = ext_h/2 - wall - grill_marg;
    for (z = zs)
        translate([wall + 1, ly_c, z]) yslot(ly_l, grill_slot, wall + 2);   // left (-X)
}

module base_apertures() {
    zc = (back_t + base_wall_h) / 2;   // centre of the wall depth
    // RIGHT wall: DC socket (top), then 6 DC-out lead holes stepping down (cylinders along X)
    translate([ext_w - wall - 1, dc_y, zc]) rotate([0, 90, 0]) cylinder(h = wall + 2, d = dc_d);
    for (i = [0 : lead_n - 1])
        translate([ext_w - wall - 1, lead_y0 - i*lead_pitch, zc]) rotate([0, 90, 0]) cylinder(h = wall + 2, d = lead_d);
    // TOP wall: 3 LEDs (cylinders along Y), stepping left from the right end
    for (i = [0 : led_n - 1])
        translate([ext_w - led_offset - i * led_pitch, ext_h - wall - 1, zc]) rotate([-90, 0, 0]) cylinder(h = wall + 2, d = led_d);
    // RIGHT wall: fuse-carrier mounting-bolt holes (2, along Y) + lead feed-through slot, centred on the block
    if (fuse_on) {
        for (s = [-1, 1])
            translate([ext_w - wall - 1, fuse_block_y + s*fuse_screw_cc/2, fuse_block_z])
                rotate([0, 90, 0]) cylinder(h = wall + 2, d = fuse_screw_d);
        translate([ext_w - wall - 1, fuse_block_y, fuse_block_z])
            rotate([0, 90, 0]) linear_extrude(wall + 2) rrect(fuse_slot_z, fuse_slot_y, 3);  // 10(Z) x 15(Y) rounded slot
    }
    // BACK plate: 4 wall-screws, shifted toward centre in X to clear the pack brackets
    for (sx = [screw_inset + screw_shift, ext_w - screw_inset - screw_shift], sy = [screw_inset, ext_h - screw_inset])
        translate([sx, sy, -1]) cylinder(h = back_t + 2, d = screw_d);
    // lug holes in the LEFT & RIGHT walls (centre of the lug band, in from the rim)
    for (y = lug_ys) {
        lz = base_wall_h - lug_from_rim - lug_t/2;
        translate([wall/2,         y, lz]) cube([wall + 2, lug_w + 2*lug_hole_clr, lug_t + 2*lug_hole_clr], center = true);  // left
        translate([ext_w - wall/2, y, lz]) cube([wall + 2, lug_w + 2*lug_hole_clr, lug_t + 2*lug_hole_clr], center = true);  // right
    }
}

// --- interior furniture -----------------------------------------------------
module corner_bracket() {   // L at origin, legs along +X and +Y, raised floor pad
    linear_extrude(br_h) difference() {
        square([br_leg, br_leg]);
        translate([br_t, br_t]) square([br_leg, br_leg]);
    }
    cube([br_leg, br_leg, pad_h]);   // raised floor so the pack sits proud
}
module battery_brackets()
    translate([0, 0, back_t]) {   // each L's inner crook lands exactly on a pack corner -> clear slot = pack_w x pack_h
        translate([pack_x0 - br_t, pack_y0 - br_t, 0])                     corner_bracket();   // bottom-left
        translate([pack_x1 + br_t, pack_y0 - br_t, 0]) rotate([0, 0, 90])  corner_bracket();   // bottom-right
        translate([pack_x0 - br_t, pack_y1 + br_t, 0]) rotate([0, 0, -90]) corner_bracket();   // top-left
        translate([pack_x1 + br_t, pack_y1 + br_t, 0]) rotate([0, 0, 180]) corner_bracket();   // top-right
    }

// extra floor pads spanning the full pack width, spaced along its length to support the
// middle (the corner pads alone leave the long pack unsupported mid-span). Same pad_h as the
// corner pads so the pack sits level on all six points.
module support_pads() {
    L = pack_y1 - pack_y0;
    translate([0, 0, back_t])
        for (i = [1 : sup_pad_n])
            translate([pack_x0, pack_y0 + i * L / (sup_pad_n + 1) - sup_pad_len/2, 0])
                cube([pack_w, sup_pad_len, pad_h]);
}

module bms_mount() {
    bx0 = rcol_cx - bms_w/2; bx1 = rcol_cx + bms_w/2;
    y0  = wall + bms_lift;   // lifted off the bottom wall -> wire clearance underneath
    translate([0, 0, back_t]) {
        // side grips (just outside the BMS edges)
        translate([bx0 - grip_t, y0, 0]) cube([grip_t, bms_grip_h, grip_z]);
        translate([bx1,          y0, 0]) cube([grip_t, bms_grip_h, grip_z]);
        // standoff pads (BMS back rests on these -> proud of the back wall)
        for (py = [y0 + 8, y0 + bms_h - 15])
            translate([rcol_cx - 8, py, 0]) cube([16, 8, bms_standoff]);
    }
}

module power_posts() {
    by0 = wall + bms_lift + bms_h + pb_gap_bms;      // board bottom (above the lifted BMS)
    cy  = by0 + pb_h/2;                              // board centre Y
    translate([0, 0, back_t])
        for (hx = [rcol_cx - pb_hole_dx/2, rcol_cx + pb_hole_dx/2], hy = [cy - pb_hole_dy/2, cy + pb_hole_dy/2])
            translate([hx, hy, 0]) difference() {
                cylinder(h = pb_post_h, d = pb_post_d);
                translate([0, 0, 1]) cylinder(h = pb_post_h, d = pb_pilot);
            }
}

module footprint_outline(cx, cy, w, h)   // outline sized to the EXACT footprint (grows inward, so the part hides it)
    translate([0, 0, back_t]) linear_extrude(border_h) difference() {
        translate([cx, cy]) square([w, h], center = true);
        translate([cx, cy]) square([w - 2*border_t, h - 2*border_t], center = true);
    }
// raised rectangular outline on the inner face of the RIGHT wall (leny along Y, lenz up Z)
module wall_outline_r(cy, cz, leny, lenz)
    translate([ext_w - wall - border_h/2, cy, cz]) difference() {
        cube([border_h,       leny,              lenz],              center = true);
        cube([border_h + 0.2, leny - 2*border_t, lenz - 2*border_t], center = true);
    }

module placement_outlines() {
    footprint_outline((pack_x0 + pack_x1)/2, (pack_y0 + pack_y1)/2, pack_w, pack_y1 - pack_y0);      // 18650 pack
    footprint_outline(rcol_cx, wall + bms_lift + bms_h/2, bms_w, bms_h);                              // BMS
    footprint_outline(rcol_cx, wall + bms_lift + bms_h + pb_gap_bms + pb_h/2, pb_w, pb_h);            // power board
    if (fuse_on) wall_outline_r(fuse_block_y, fuse_block_z, fuse_block_len, fuse_block_w);            // fuse carrier (on the right wall)
}

module base_logo() {   // on the LEFT wall outer face, upper (solid) half
    translate([logo_sink - logo_raise, ext_h * 0.78, (back_t + base_wall_h)/2])
        rotate([90, 0, -90]) linear_extrude(logo_sink + logo_raise) logo2d();
}

module base() {
    difference() {
        union() {
            base_shell();
            battery_brackets();
            support_pads();
            bms_mount();
            power_posts();
            if (outline_on) placement_outlines();
        }
        base_grills();
        base_apertures();
    }
}

// ---------------------------------------------------------------------------
// COVER  (modelled panel-DOWN = print orientation: panel on the bed, lip + lugs up)
module cover_lip() {   // frame that slots inside the base walls
    ow = ext_w - 2*wall - 2*lip_clear;
    oh = ext_h - 2*wall - 2*lip_clear;
    translate([0, 0, cover_t]) linear_extrude(cover_lip_h) difference() {
        translate([ext_w/2, ext_h/2]) rrect(ow, oh, max(0.5, corner_r - wall));
        translate([ext_w/2, ext_h/2]) rrect(ow - 2*lip_t, oh - 2*lip_t, max(0.5, corner_r - wall - lip_t));
    }
}
module lug_prism(reach, zlo, zhi, w)   // local: shelf at zlo (-> +Z/pull-off after the cover flips), ramp above
    rotate([90, 0, 0]) translate([0, 0, -w/2]) linear_extrude(w) polygon([[-1, zlo], [reach, zlo], [-1, zhi]]);  // -1 embeds into the lip to fuse

module cover_lugs() {   // on the lip outer faces, left & right; print-orientation z = up from panel
    zlo = cover_t + lug_from_rim; zhi = zlo + lug_t;
    for (y = lug_ys) {
        translate([ext_w - wall - lip_clear, y, 0]) lug_prism(lug_reach, zlo, zhi, lug_w);               // right (+X)
        translate([wall + lip_clear,         y, 0]) mirror([1, 0, 0]) lug_prism(lug_reach, zlo, zhi, lug_w); // left (-X)
    }
}
module cover_grill() {   // bottom half of the panel
    ys  = [for (y = [wall + grill_marg : grill_pitch : ext_h/2]) y];
    len = ext_w - 2*grill_marg;
    for (y = ys) translate([ext_w/2, y, -1]) zslot(len, grill_slot, cover_t + 2);
}
module cover_logo()  // AE on the panel front face (upper half), debossed (prints on the bed side)
    translate([ext_w * 0.32, ext_h * 0.72, -0.01]) linear_extrude(logo_sink) logo2d();
module cover_mono()  // one quiet hat, debossed, upper area
    translate([ext_w * 0.62, ext_h * 0.80, -0.01]) linear_extrude(mono_sink) monotile2d();

module cover() {
    difference() {
        union() {
            linear_extrude(cover_t) translate([ext_w/2, ext_h/2]) rrect(ext_w, ext_h, corner_r);
            cover_lip();
            cover_lugs();
        }
        cover_grill();
        cover_mono();
    }
}

// ---------------------------------------------------------------------------
// Fit check
echo(str("UPS interior (W x H x D) = ", ext_w - 2*wall, " x ", ext_h - 2*wall, " x ", ext_d - back_t));
if (pack_y0 + pack_h > ext_h - wall - br_t)
    echo(str("WARNING: pack length ", pack_h, " overruns the box (top bracket clamped); raise ext_h ~", pack_y0 + pack_h + wall + br_t + 2));
if (rcol_cx + max(pb_w, bms_w)/2 > ext_w - wall)
    echo(str("WARNING: BMS/board column (right edge ", rcol_cx + max(pb_w, bms_w)/2, ") overruns the right wall at ", ext_w - wall, "; reduce pack_w/pb_w or raise ext_w"));
if (pack_depth + pad_h + back_t > ext_d)
    echo(str("WARNING: pack depth+standoff ", pack_depth + pad_h + back_t, " > ext_d ", ext_d, " (raise ext_d ~", pack_depth + pad_h + back_t + cover_t + 2, ")"));

// === Dispatch ===
// mir() reflects a part about its own X mid-plane when mirror_lr is set (applied innermost,
// so the base and the flipped cover stay aligned in X).
module mir() {
    if (mirror_lr) translate([ext_w, 0, 0]) mirror([1, 0, 0]) children();
    else children();
}

if (part == "base") mir() base();
else if (part == "cover") mir() cover();
else if (part == "assembly") {
    color("Gainsboro") mir() base();
    // flip the (panel-down) cover onto the base front
    color("LightSteelBlue", 0.6) translate([0, ext_h, base_wall_h + cover_t]) rotate([180, 0, 0]) mir() cover();
}
else {   // "all" -- side by side
    mir() base();
    translate([ext_w + 25, 0, 0]) color("LightSteelBlue") mir() cover();
}
