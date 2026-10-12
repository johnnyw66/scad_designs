// ==========================================
// PARAMETRIC LUGGAGE TAG WITH NFC & QR CAVITY
// ==========================================

$fn = 64;

/* [Tag Dimensions] */
tag_length    = 85.0; // Standard credit-card length scale
tag_width     = 54.0;
tag_thickness = 3.2;  // Total thickness
corner_radius = 6.0;

/* [Strap Slot] */
slot_width     = 14.0; // Fits standard 12mm luggage strap or loop
slot_height    = 3.5;
slot_margin_x  = 7.0;  // Distance from tag edge to slot

/* [NFC Pocket (Internal Cavity)] */
nfc_diameter  = 26.0; // For standard 25mm circular NFC sticker (+1mm clearance)
nfc_depth     = 0.6;  // Accommodates 0.2mm sticker + adhesive without nozzle collision
nfc_floor_z   = 1.0;  // Solid plastic thickness beneath the sticker

/* [QR Code Inset] */
qr_size       = 32.0; // Square recessed window for QR decal or dual-extrusion tile
qr_recess     = 0.6;  // Depth from top face down
qr_margin_x   = 10.0; // Offset from right edge

// ==========================================
// GEOMETRY MODULES
// ==========================================

module rounded_rect(w, l, h, r) {
    translate([r, r, 0])
        minkowski() {
            cube([w - 2*r, l - 2*r, h / 2]);
            cylinder(r=r, h=h / 2);
        }
}

module luggage_tag() {
    difference() {
        // Main Tag Body
        rounded_rect(tag_length, tag_width, tag_thickness, corner_radius);

        // Strap Slot (Through-hole)
        translate([slot_margin_x, (tag_width - slot_width) / 2, -0.5])
            hull() {
                translate([slot_height/2, slot_height/2, 0])
                    cylinder(d=slot_height, h=tag_thickness + 1);
                translate([slot_height/2, slot_width - slot_height/2, 0])
                    cylinder(d=slot_height, h=tag_thickness + 1);
            }

        // Internal NFC Pocket (Enclosed inside the print)
        // Positioned in the center-left body area
        translate([tag_length * 0.42, tag_width / 2, nfc_floor_z])
            cylinder(d=nfc_diameter, h=nfc_depth);

        // Top QR Code Inset (Debossed window on upper surface)
        translate([tag_length - qr_size - qr_margin_x, (tag_width - qr_size) / 2, tag_thickness - qr_recess])
            cube([qr_size, qr_size, qr_recess + 0.1]);
    }
}

// Render the model
luggage_tag();