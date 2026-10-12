// =====================================================================
// BMETERS GSD8-RFM Friction-Fit Hooded Through-Beam Cap (No Bolt)
// Calibrated for Kingbright L-934 (Emitter) & L-932 (Phototransistor)
// Bore: 10.80mm ID | Turret Socket: 7.0mm
// Units: millimetres (mm)
// =====================================================================

$fn = 90;

/* [Mode Selection] */
// 1 = Mat Only, 2 = Turret Only, 3 = Mat + Turret (One Piece)
print_mode         = 2;      // [1:Mat Only, 2:Turret Only, 3:Mat + Turret]

/* [Mat Mask Dimensions] */
mat_od             = 18.0;   // Outer diameter of the glare mat
mat_id             = 10.8;   // Central aperture diameter
mat_thickness      = 0.20;   // Mat thickness (mm)

/* [Turret Geometry - Calibrated] */
turret_od          = 10.68;  // Measured turret outer diameter
turret_h           = 7.0;    // Turret height from lens face
fit_clearance      = 0.12;   // Slip/push fit (drop to 0.05 for tighter grip)

/* [Enclosure & Light Hood] */
roof_th            = 1.5;    // Solid light-blocking roof on top
collar_wall        = 2.2;    // Collar structural wall thickness
total_h            = turret_h + roof_th; // 8.5mm overall height

/* [Kingbright 3mm Optical Channels] */
optical_beam_z     = 3.5 - 1;    // Beam height halfway bar 1mm and 1the 7.0mm turret
led_barrel_d       = 3.4;    // Body clearance bore (Kingbright barrel is 3.0mm)
flange_d           = 4.1;    // Flange clearance recess (Kingbright flange is 3.8mm)
flange_depth       = 2.0;    // Depth from outside face to seat the base flange

// Derived variables
inner_r      = (turret_od / 2) + fit_clearance;
collar_r     = inner_r + collar_wall;
optic_boss_r = collar_r + 3.2;

// Standalone Mat Module
module glare_mat() {
    difference() {
        cylinder(d = mat_od, h = mat_thickness);
        translate([0, 0, -0.1])
            cylinder(d = mat_id, h = mat_thickness + 0.2);
    }
}

// Unmodified Turret Module
module gsd8_friction_cap() {
    difference() {
        union() {
            // 1. Main hooded cylindrical body
            cylinder(r = collar_r, h = total_h);

            // 2. Lateral optical housing bosses (along Y-axis)
            translate([-collar_r * 0.5, -optic_boss_r, 0])
                cube([collar_r, optic_boss_r * 2, total_h]);
        }

        // --- SUBTRACTIONS ---

        // A. Internal blind socket for 7.0mm turret (stops at Z = 7.0mm)
        translate([0, 0, -0.1])
            cylinder(r = inner_r, h = turret_h + 0.1);

        // B. Through-beam barrel bore (3.4mm passes all the way through)
        translate([0, -optic_boss_r - 1.0, optical_beam_z])
            rotate([-90, 0, 0])
            cylinder(d = led_barrel_d, h = optic_boss_r * 2 + 2.0);

        // C. Flange counterbores on outer faces (seats the 3.8mm base lips flush)
        // -Y side (Emitter entry)
        translate([0, -optic_boss_r - 0.1, optical_beam_z])
            rotate([-90, 0, 0])
            cylinder(d = flange_d, h = flange_depth + 0.1);

        // +Y side (Receiver entry)
        translate([0, optic_boss_r - flange_depth, optical_beam_z])
            rotate([-90, 0, 0])
            cylinder(d = flange_d, h = flange_depth + 0.1);
    }
}

// Integrated Combined Assembly (Option 3)
module combined_cap_and_mat() {
    union() {
        // Mat base seated on the build plate (Z: 0 -> mat_thickness)
        glare_mat();

        // Exact turret lifted up to sit directly on the top surface of the mat
        translate([0, 0, mat_thickness])
            gsd8_friction_cap();
    }
}

// --- Render Switch ---
if (print_mode == 1) {
    glare_mat();
} else if (print_mode == 2) {
    gsd8_friction_cap();
} else if (print_mode == 3) {
    combined_cap_and_mat();
}