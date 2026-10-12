// =====================================================================
// Pimoroni Pico Plus 2 W XL - Flat-Base Tactile Button Plungers
// =====================================================================

$fn = 60;

// --- Plunger Dimensions ---
stem_dia    = 2.90;   // Stem diameter (fits inside 3.5 mm lid hole)
stem_h      = 4.80;   // Stem height extending above the flange plate
flange_dia  = 5.20;   // Retaining base disc diameter
flange_t    = 1.00;   // Base disc thickness (sits under the lid)

module button_plunger() {
    // 1. Bottom Retaining Flange (flat on build plate)
    cylinder(d = flange_dia, h = flange_t);

    // 2. Main Stem (pokes up through lid)
    translate([0, 0, flange_t])
        cylinder(d = stem_dia, h = stem_h);
}

// Render two plungers side-by-side
translate([-4, 0, 0]) button_plunger();
translate([ 4, 0, 0]) button_plunger();