// =====================================================================
// Parametric Glue Paddle / Crafting Spatula with Top Grip Handle
// Units: millimeters (mm)
// =====================================================================

$fn = 64; // Surface smoothness

// --- Shaft / Stem Parameters ---
shaft_length = 40.0;   // Length of the central shaft (Y axis)
shaft_width  = 5.0;    // Width of the shaft (X axis)
shaft_thick  = 3.0;    // Thickness of the shaft (Z axis)

// --- Top Grip / Handle Parameters ---
// Forms a comfortable T-style grip or rounded paddle cap
top_handle_width  = 16.0;  // Total width across the top grip (X axis)
top_handle_length = 8.0;   // Depth / height along Y axis
top_handle_thick  = 3.0;   // Thickness (Z axis - keep matched to shaft for flat printing)
top_handle_radius = 2.0;   // Corner rounding radius for comfort

// --- Blade / Spade Parameters ---
blade_width       = 15.0;  // Width across the paddle (X axis)
blade_length      = 10.0;  // Length extending forward (Y axis)
blade_thick_start = 3.0;   // Thickness at the shaft junction (Z axis)
blade_thick_tip   = 1.0;   // Tapered edge thickness at the working tip (Z axis)

// --- Optional Features ---
add_hanging_hole = true;  // Set true to add a pegboard/lanyard hole in the grip
hole_diameter    = 3.0;

// =====================================================================
// Helper: 2D Rounded Rectangle (for extruded smooth shapes)
// =====================================================================
module rounded_rect_2d(w, l, r) {
    hull() {
        translate([-w/2 + r, -l/2 + r]) circle(r = r);
        translate([ w/2 - r, -l/2 + r]) circle(r = r);
        translate([-w/2 + r,  l/2 - r]) circle(r = r);
        translate([ w/2 - r,  l/2 - r]) circle(r = r);
    }
}

// =====================================================================
// Main Model
// =====================================================================
module glue_paddle() {
    difference() {
        union() {
            // 1. Central Shaft
            translate([-shaft_width / 2, 0, 0])
                cube([shaft_width, shaft_length, shaft_thick]);

            // 2. Top Grip Handle (Centered at top end of shaft)
            translate([0, shaft_length + top_handle_length / 2, 0])
                linear_extrude(height = top_handle_thick)
                    rounded_rect_2d(top_handle_width, top_handle_length, top_handle_radius);

            // 3. Smooth Transition / Fillet between Shaft and Top Grip
            hull() {
                translate([-shaft_width / 2, shaft_length - 2, 0])
                    cube([shaft_width, 2, shaft_thick]);
                translate([-top_handle_width / 2 + top_handle_radius, shaft_length, 0])
                    cube([top_handle_width - (top_handle_radius * 2), 2, top_handle_thick]);
            }

            // 4. Tapered Spade Blade (Extends forward along -Y)
            hull() {
                // Junction at Y = 0
                translate([-blade_width / 2, -0.01, 0])
                    cube([blade_width, 0.01, blade_thick_start]);

                // Thin working edge at tip
                translate([-blade_width / 2, -blade_length, 0])
                    cube([blade_width, 0.01, blade_thick_tip]);
            }
        }

        // Optional Lanyard / Peg Hole in the Top Grip
        if (add_hanging_hole) {
            translate([0, shaft_length + top_handle_length / 2, -1])
                cylinder(d = hole_diameter, h = top_handle_thick + 2);
        }
    }
}

glue_paddle();