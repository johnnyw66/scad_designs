// =====================================================================
// Pimoroni Pico Plus 2 W XL - Open Carrier Case (Fixed Floor)
// PCB Footprint: 77.0 x 21.0 x 1.45 mm
// =====================================================================

$fn = 40;

// --- Board & Fit Parameters ---
pcb_len        = 77.0;   // PCB length (X)
pcb_wid        = 21.0;   // PCB width (Y)
pcb_thick      = 1.45;   // PCB thickness (Z)
pcb_clearance  = 0.40;   // Total XY clearance (0.2 mm per side for slip fit)

// --- Enclosure Parameters ---
wall_thick     = 2.0;    // Case wall thickness
floor_thick    = 2.0;    // Solid floor thickness at bottom
outer_radius   = 3.0;    // Outer corner fillet radius

floor_lift     = 3.0;    // Gap between inside floor and shelf top
ledge_width    = 2.5;    // Long-edge shelf width (both Y sides)
board_headroom = 4.5;    // Wall height above the PCB top surface

// --- Port Cutout Parameters ---
usbc_cut_w     = 10.5;   // USB-C width (Y)
usbc_cut_h     = 5.5;    // USB-C height (Z)
usbc_sub_drop  = 0.5;    // Extra depth below top surface of PCB

jst_cut_w      = 8.0;    // JST-PH width (Y)
jst_cut_h      = 6.5;    // JST-PH height (Z)
jst_sub_drop   = 0.5;    // Extra depth below top surface of PCB

// --- Derived Dimensions ---
cavity_x   = pcb_len + pcb_clearance;
cavity_y   = pcb_wid + pcb_clearance;
case_h     = floor_thick + floor_lift + pcb_thick + board_headroom;

outer_x    = cavity_x + (2 * wall_thick);
outer_y    = cavity_y + (2 * wall_thick);

pcb_z_base = floor_thick + floor_lift; // Shelf top surface (Z = 5.0 mm)

// --- Helper: 2D Rounded Rectangle ---
module rounded_rect(w, l, r) {
    hull() {
        for (dx = [-w/2 + r, w/2 - r]) {
            for (dy = [-l/2 + r, l/2 - r]) {
                translate([dx, dy]) circle(r = r);
            }
        }
    }
}

// --- Main Enclosure Model ---
module pico_plus_2w_xl_case() {
    difference() {
        // 1. Solid rounded outer body (Z: 0 -> case_h)
        linear_extrude(height = case_h) {
            rounded_rect(outer_x, outer_y, outer_radius);
        }

        // 2. Central lower drop between the ledges (Z: floor_thick -> pcb_z_base)
        // Preserves the 2.0 mm solid floor below and leaves 2.5 mm ledges on the sides
        translate([-(cavity_x + 0.1)/2, -(cavity_y - 2 * ledge_width)/2, floor_thick]) {
            cube([cavity_x + 0.1, cavity_y - 2 * ledge_width, floor_lift + 0.01]);
        }

        // 3. Upper PCB well and component chamber (Z: pcb_z_base -> top)
        translate([-cavity_x/2, -cavity_y/2, pcb_z_base]) {
            cube([cavity_x, cavity_y, case_h - pcb_z_base + 1.0]);
        }

        // 4. Centred USB-C Cutout (at -X end)
        translate([
            -(cavity_x / 2 + wall_thick * 1.5), 
            -usbc_cut_w / 2, 
            pcb_z_base + pcb_thick - usbc_sub_drop
        ]) {
            cube([wall_thick * 2, usbc_cut_w, usbc_cut_h]);
        }

        // 5. Centred JST-PH Cutout (at +X end)
        translate([
            cavity_x / 2 - 0.1, 
            -jst_cut_w / 2, 
            pcb_z_base + pcb_thick - jst_sub_drop
        ]) {
            cube([wall_thick * 2, jst_cut_w, jst_cut_h]);
        }
    }
}

pico_plus_2w_xl_case();