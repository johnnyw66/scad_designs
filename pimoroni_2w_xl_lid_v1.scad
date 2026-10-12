// =====================================================================
// Pimoroni Pico Plus 2 W XL - Snap-In Lid with Modular Cutouts
// Features: QW/ST+DEBUG, SP/CE, BOOT/PWR buttons, and 3 Status LEDs
// =====================================================================

$fn = 40;

// =====================================================================
// --- USER TWEAK CONSTANTS: CONNECTOR & BUTTON PUNCHES ---
// =====================================================================

// --- 1. Boot & Power/Reset Button Holes (Referenced from USB-C End) ---
btn_enable          = true;    // Set to false to disable both button holes
btn_dist_from_usbc  = 14.0;    // [FIXED] Caliper-locked distance from USB-C PCB edge inward along X
btn_spacing_y       = 6.3;     // Centre-to-centre distance between the two buttons across Y
btn_radius          = 1.75;    // Radius of button access holes (3.5 mm diameter)

// --- 2. QW/ST + DEBUG Combined Punch (From JST End) ---
qwst_debug_enable   = true;
qwst_debug_dist     = 12.5;    // X start (13.0 mm - 0.5 mm clearance)
qwst_debug_len      = 7.5;     // X length (covers 13.0 to 19.5 mm + clearance)
qwst_debug_wid      = 11.0;    // Y width (10.03 mm body + ~1.0 mm clearance)
qwst_debug_offset_y = 0.0;     // Centered on board midline

// --- 3. SP/CE Connector Punch (From JST End) ---
spce_enable         = true;
spce_dist           = 32.5;    // X start (33.0 mm - 0.5 mm clearance)
spce_len            = 4.6;     // X length (covers 33.00 to 36.57 mm + clearance)
spce_wid            = 11.0;    // Y width (10.03 mm body + ~1.0 mm clearance)
spce_offset_y       = 0.0;     // Centered on board midline

// --- 4. [NEW INCLUSION] 3x Status LED Light Holes (Referenced from USB-C End) ---
led_enable          = true;    // Set to false to disable LED holes
led_dist_from_usbc  = 8.73;    // Distance from USB-C PCB edge inward along X
led_pitch_y         = 3.70;    // Pitch between adjacent LED centres across Y (total span 7.4 mm)
led_radius          = 0.75;    // Radius of LED light holes (1.5 mm diameter)


// =====================================================================
// --- BASE & ENCLOSURE GEOMETRY (Matching Case) ---
// =====================================================================
pcb_len        = 77.0;
pcb_wid        = 21.0;
pcb_thick      = 1.45;
pcb_clearance  = 0.40;   // Cavity: 77.4 x 21.4 mm
wall_thick     = 2.0;
outer_radius   = 3.0;
board_headroom = 4.5;    // Inside depth from case rim down to PCB surface

// --- Lid & Snap Parameters ---
lid_top_thick  = 2.0;    // Thickness of outer top plate
lid_play       = 0.20;   // Sliding clearance per side
clamp_rail_w   = 1.80;   // Down-pressure rail over PCB edges

snap_bead_h    = 0.40;   // Snap bead protrusion
snap_bead_len  = 12.0;   // Snap bead length

pry_overhang   = 1.50;   // Fingernail tab overhang past outer wall
pry_tab_len    = 16.0;   // Fingernail tab length along X

jst_window_w   = 9.0;    // JST-PH connector cutout width (Y)
jst_window_l   = 9.5;    // JST-PH connector cutout length (X)
usbc_hood_drop = 1.0;    // USB-C collar drop clearance

// --- Derived Coordinates ---
cavity_x   = pcb_len + pcb_clearance;
cavity_y   = pcb_wid + pcb_clearance;
outer_x    = cavity_x + (2 * wall_thick);
outer_y    = cavity_y + (2 * wall_thick);

plug_x     = cavity_x - (2 * lid_play);
plug_y     = cavity_y - (2 * lid_play);

// Physical reference edges of the PCB inside the cavity
pcb_jst_edge_x  =  cavity_x / 2; // +X end
pcb_usbc_edge_x = -cavity_x / 2; // -X end

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

// =====================================================================
// --- MODULAR CUTOUT ROUTINES ---
// =====================================================================

// Generic rectangular punch measured from JST edge inward (-X)
module punch_window_from_jst(from_jst_edge, length_x, width_y, offset_y) {
    punch_center_x = pcb_jst_edge_x - from_jst_edge - (length_x / 2);
    translate([punch_center_x, offset_y, -1.0]) {
        cube([length_x, width_y, lid_top_thick + board_headroom + 2.0], center = true);
    }
}

module punch_qwst_debug() {
    if (qwst_debug_enable) {
        punch_window_from_jst(qwst_debug_dist, qwst_debug_len, qwst_debug_wid, qwst_debug_offset_y);
    }
}

module punch_spce() {
    if (spce_enable) {
        punch_window_from_jst(spce_dist, spce_len, spce_wid, spce_offset_y);
    }
}

// Dual round hole punch for Boot & Power buttons measured from USB-C edge inward (+X)
module punch_boot_pwr_buttons() {
    if (btn_enable) {
        btn_center_x = pcb_usbc_edge_x + btn_dist_from_usbc;
        
        for (side = [-1, 1]) {
            translate([btn_center_x, side * (btn_spacing_y / 2), -1.0]) {
                cylinder(r = btn_radius, h = lid_top_thick + board_headroom + 2.0);
            }
        }
    }
}

// [NEW INCLUSION] Trio of Status LED access holes measured from USB-C edge inward (+X)
module punch_status_leds() {
    if (led_enable) {
        led_center_x = pcb_usbc_edge_x + led_dist_from_usbc;
        
        for (pos = [-1, 0, 1]) {
            translate([led_center_x, pos * led_pitch_y, -1.0]) {
                cylinder(r = led_radius, h = lid_top_thick + board_headroom + 2.0);
            }
        }
    }
}

// =====================================================================
// --- MAIN LID ASSEMBLY ---
// =====================================================================
module pico_plus_2w_xl_lid() {
    difference() {
        union() {
            // 1. Top Cover Plate
            linear_extrude(height = lid_top_thick) {
                rounded_rect(outer_x, outer_y, outer_radius);
            }

            // 2. Dual Fingernail Pry Tabs (protrude on both long Y sides)
            linear_extrude(height = lid_top_thick) {
                hull() {
                    rounded_rect(pry_tab_len, outer_y + (2 * pry_overhang), 1.5);
                }
            }

            // 3. Inner Plug Body (enters the case cavity)
            translate([-plug_x/2, -plug_y/2, lid_top_thick]) {
                cube([plug_x, plug_y, board_headroom]);
            }

            // 4. Snap-fit Detent Beads
            for (side = [-1, 1]) {
                translate([
                    -snap_bead_len / 2, 
                    side * (plug_y / 2 + (side > 0 ? 0 : -snap_bead_h)), 
                    lid_top_thick + (board_headroom * 0.55)
                ]) {
                    cube([snap_bead_len, snap_bead_h, 1.2]);
                }
            }
        }

        // --- SUBTRACTIONS ---

        // A. Central Underside Hollowing (leaves side clamping rails)
        translate([
            -(plug_x + 0.1)/2, 
            -(plug_y - 2 * clamp_rail_w)/2, 
            lid_top_thick
        ]) {
            cube([plug_x + 0.1, plug_y - 2 * clamp_rail_w, board_headroom + 0.1]);
        }

        // B. End JST-PH Connector Window (+X end)
        translate([
            (plug_x / 2) - jst_window_l, 
            -jst_window_w / 2, 
            -0.1
        ]) {
            cube([jst_window_l + wall_thick + 1.0, jst_window_w, lid_top_thick + board_headroom + 0.2]);
        }

        // C. USB-C Overmold Hood Relief (-X end)
        translate([
            -(plug_x / 2 + wall_thick + 0.5), 
            -11.0 / 2, 
            lid_top_thick + board_headroom - usbc_hood_drop
        ]) {
            cube([wall_thick + 1.0, 11.0, usbc_hood_drop + 0.1]);
        }

        // D. Modular Connector Punches
        punch_qwst_debug();
        punch_spce();

        // E. Modular Button Access Holes
        punch_boot_pwr_buttons();

        // F. [NEW INCLUSION] Modular Status LED Access Holes
        punch_status_leds();
    }
}

pico_plus_2w_xl_lid();