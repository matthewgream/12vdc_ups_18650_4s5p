// 18650-cell-pack-harness.scad — welding jig + anti-compression spacer for an 18650 pack.
//
// Two printed parts (export one at a time with -D part="..."):
//   * footer — the full seating tray (unchanged): cells drop into Ø(cell) pockets, rest on a thin
//              bottomLip, with a reduced-Ø electrode window through the floor so the bottom caps can
//              be spot-welded. Holds the cells square while welding.
//   * spacer — JUST the inter-cell webbing, chopped spacerInset INSIDE the cell envelope so it sits
//              within the pack perimeter. No bottomLip and no reduced-Ø window — full-diameter holes
//              straight through, because it's an intermediate spacer the cells pass through. Print
//              two: they drop between the welded cells as a hard stop so the cells can't be pushed
//              together and stress the weld joints.
//
// Model orientation: both parts sit flat on the bed (body-down), holes vertical -> print as-is.

// === FLAGS ===
part = "all"; // "footer" | "spacer" | "all" (side by side)

// Number of cells
height = 10;
width = 2;

// Cell size - only works for 18650 cells at the moment
cellDiameter = 18;
cellHeight = 65;

// Cell diameter tolerance - applied as a factor to adjust for printer tolerances
cellDiameterTolerance = 0.03;

// Spacing between cells
cellSpacing = 1.7;

// Height of the body of the harness (mm)
bodyHeight = 8;

// Outside border of the harness (mm)
outerBorder = 2;

// Height of the bottom lip (mm) -- FOOTER only
bottomLip = 0.6;

// Diameter of the hole surrounding the electrodes -- FOOTER only
cellHoleDiameter = 14;

// How far INSIDE the cell envelope the spacer is chopped (mm) -- SPACER only
spacerInset = 2.5;

$fn = $preview ? 48 : 256;

/////////////////////////////////////////////////////////////////////////////////

actualCellDiameter = cellDiameter + (cellDiameter * cellDiameterTolerance);
cornerRadius = 12;

function get_cell_x(row, col) = ((row + 1) * 1.0) + (row * (actualCellDiameter / 2) + cellSpacing) + (actualCellDiameter / 2) + (col * (actualCellDiameter + cellSpacing));
function get_cell_y(row, col) = (actualCellDiameter / 2) + outerBorder + (row * actualCellDiameter * 0.92);

module cell() cylinder(r = actualCellDiameter / 2.0, h = cellHeight, center = false);
module cell_hole() cylinder(r = cellHoleDiameter / 2.0, h = cellHeight, center = false);

// place children at every cell centre (x,y; z left at 0)
module for_each_cell() for (row = [0 :height - 1]) for (col = [0 :width - 1]) translate([ get_cell_x(row, col), get_cell_y(row, col) ]) children();

module main_body() {
    top_left_x = ((height + 1) * 1.0) + (height * (actualCellDiameter / 2) + cellSpacing) + (actualCellDiameter / 2) + (0 * (actualCellDiameter + cellSpacing)) - (actualCellDiameter / 2) - outerBorder;
    top_left_y = get_cell_y(height - 1, 0) - 0.6;
    top_right_x = (((height - 1) + 1) * 1.2) + ((height - 1) * (actualCellDiameter / 2) + cellSpacing) + (actualCellDiameter / 2) + ((width - 1) * (actualCellDiameter + cellSpacing));
    bottom_right_x = (((0 - 1) + 1) * 1.2) + ((0 - 1) * (actualCellDiameter / 2) + cellSpacing) + (actualCellDiameter / 2) + ((width - 1) * (actualCellDiameter + cellSpacing)) + (actualCellDiameter / 2) + outerBorder;
    hull() {
        translate([ cornerRadius, cornerRadius ]) cylinder(r = cornerRadius, h = bodyHeight);
        translate([ top_left_x, top_left_y, 0 ]) cylinder(r = cornerRadius, h = bodyHeight);
        translate([ top_right_x, top_left_y, 0 ]) cylinder(r = cornerRadius, h = bodyHeight);
        translate([ bottom_right_x, cornerRadius, 0 ]) cylinder(r = cornerRadius, h = bodyHeight);
    }
}

// --- FOOTER: full tray, seating lip + reduced-Ø electrode window --------------
module footer() difference() {
    main_body();
    for_each_cell() translate([ 0, 0, bottomLip ]) cell(); // cell pockets (sit on the lip)
    for_each_cell() translate([ 0, 0, -10 ]) cell_hole();  // electrode windows through the floor
}

// --- SPACER: inter-cell webbing only; full-Ø through holes; chopped inside the envelope --------
module cell_envelope_2d() // convex outline tangent to the outer cells
    hull() for_each_cell() circle(r = actualCellDiameter / 2);

module spacer() intersection() {
    difference() {
        main_body();
        for_each_cell() translate([ 0, 0, -1 ]) cylinder(r = actualCellDiameter / 2, h = bodyHeight + 2); // full-Ø, straight through: no lip, no reduced window
    }
    translate([ 0, 0, -1 ]) linear_extrude(bodyHeight + 2) offset(delta = -spacerInset) cell_envelope_2d();
}

// === Dispatch ===
if (part == "footer")
    footer();
else if (part == "spacer")
    spacer();
else { // "all" -- spacer stacked below the footer
    footer();
    translate([ 0, -(get_cell_y(height - 1, 0) + cornerRadius + 15), 0 ]) spacer();
}
