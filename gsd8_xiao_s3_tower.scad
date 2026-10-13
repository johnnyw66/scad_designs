// ===================================================================
// BMeters GSD8-RFM DN20 - Low-Profile (45-50mm) Tower for XIAO ESP32S3 Sense
// ===================================================================

$fn = 90;

// --- Part Selector ---
part = "clamp"; // ["assembled", "tower", "clamp"]

// --- Meter Dimensions (Calibrated) ---
d_top       = 64.6;   // Top rim inner bore (measured 64.34mm + clearance)
d_shelf     = 68.5;   // Lower skirt inner bore (measured 68.11mm + clearance)
h_drop      = 5.52;   // Drop height to the shelf
h_skirt     = 5.0;    // Skirt height below shelf
collar_h    = h_drop + h_skirt; // Total collar height (~10.5mm)

wall_th     = 4.0;
r_out       = (d_shelf / 2) + wall_th;
clamp_gap   = 1.5;    // Mating gap per side for tension

// --- Elevation & Tower ---
tower_h     = 45.0;   // Lens/plate height above meter base (~50mm total)
leg_w       = 8.0;    // Support strut width
leg_th      = 3.5;    // Strut thickness

// --- Seeed Studio XIAO ESP32S3 Sense Cradle ---
xiao_w      = 18.2;   // Board width (+ tolerance)
xiao_l      = 21.5;   // Board length (+ tolerance)
xiao_depth  = 4.5;    // Depth for board + camera daughterboard sandwich
lens_dia    = 9.5;    // Lens through-hole
tray_wall   = 2.5;

tray_ext_w  = xiao_w + (tray_wall * 2);
tray_ext_l  = xiao_l + (tray_wall * 2);

// --- Fasteners (M3) ---
bolt_d      = 3.4;
nut_w       = 6.2;
nut_h       = 2.8;
lug_w       = 10.0;

// ===================================================================
// Top-Level Assembly Dispatcher
// ===================================================================

if (part == "assembled") {
    color("DimGray") tower_half();
    color("SlateGray") clamp_half();
} else if (part == "tower") {
    tower_half();
} else if (part == "clamp") {
    rotate([0, 0, 180]) clamp_half();
}

// ===================================================================
// Module: Tower Half (Collar + Struts + XIAO Tray)
// ===================================================================
module tower_half() {
    difference() {
        union() {
            // Front collar half
            intersection() {
                cylinder(r = r_out, h = collar_h);
                translate([-r_out - 10, clamp_gap / 2, 0])
                    cube([(r_out + 10) * 2, r_out + 10, collar_h]);
            }
            collar_lugs(rear = false);

            // Angled support struts
            support_leg(angle = 45, with_wire_channel = true);
            support_leg(angle = 135, with_wire_channel = false);

            // Elevated XIAO Sense Platform
            translate([0, 8.0, tower_h]) // 8mm forward offset to center over numbers
                xiao_tray();
        }

        // Calibrated stepped bore
        stepped_meter_bore();

        // M3 bolt holes
        lug_holes(rear = false);
    }
}

// ===================================================================
// Module: Clamp Half (Rear Collar)
// ===================================================================
module clamp_half() {
    difference() {
        union() {
            // Rear collar half
            intersection() {
                cylinder(r = r_out, h = collar_h);
                translate([-r_out - 10, -r_out - 10 - (clamp_gap / 2), 0])
                    cube([(r_out + 10) * 2, r_out + 10, collar_h]);
            }
            collar_lugs(rear = true);
        }

        stepped_meter_bore();
        lug_holes(rear = true);
    }
}

// ===================================================================
// Internal Geometry & Mechanical Features
// ===================================================================

module stepped_meter_bore() {
    // 1. Lower wide skirt
    translate([0, 0, -1])
        cylinder(d = d_shelf, h = h_skirt + 1);

    // 2. Smooth internal transition up the drop
    translate([0, 0, h_skirt - 0.01])
        cylinder(d1 = d_shelf, d2 = d_top, h = h_drop + 0.02);

    // 3. Top rim clearance
    translate([0, 0, h_skirt + h_drop])
        cylinder(d = d_top, h = collar_h);
}

module collar_lugs(rear = false) {
    y_sign = rear ? -1 : 1;
    for (x_dir = [-1, 1]) {
        translate([x_dir * (r_out + lug_w / 2 - 1), y_sign * (clamp_gap / 2 + 5), collar_h / 2])
            cube([lug_w, 10, collar_h], center = true);
    }
}

module lug_holes(rear = false) {
    y_sign = rear ? -1 : 1;
    for (x_dir = [-1, 1]) {
        translate([x_dir * (r_out + lug_w / 2 - 1), 0, collar_h / 2])
            rotate([90, 0, 0])
            cylinder(d = bolt_d, h = 40, center = true);

        if (rear) {
            translate([x_dir * (r_out + lug_w / 2 - 1), -10.5, collar_h / 2])
                rotate([90, 30, 0])
                cylinder(r = nut_w / (2 * cos(30)), h = nut_h + 1, $fn = 6, center = true);
        }
    }
}

module support_leg(angle, with_wire_channel = false) {
    bx = (r_out - 1) * cos(angle);
    by = (r_out - 1) * sin(angle);
    tx = (tray_ext_w / 2 - 2) * cos(angle);
    ty = 8.0 + (tray_ext_l / 2 - 2) * sin(angle);

    difference() {
        hull() {
            translate([bx, by, collar_h - 1])
                cylinder(r = leg_w / 2, h = 1);
            translate([tx, ty, tower_h])
                cylinder(r = leg_w / 2, h = 1);
        }
        
        // Optional 2.5mm groove along the strut for IR cap wiring
        if (with_wire_channel) {
            hull() {
                translate([bx * 0.95, by * 0.95, collar_h])
                    cylinder(d = 2.5, h = 2);
                translate([tx * 0.95, ty * 0.95, tower_h - 1])
                    cylinder(d = 2.5, h = 2);
            }
        }
    }
}

module xiao_tray() {
    difference() {
        // Outer tray body
        translate([-tray_ext_w / 2, -tray_ext_l / 2, 0])
            cube([tray_ext_w, tray_ext_l, xiao_depth + 2.0]);

        // Pocket for XIAO S3 Sense
        translate([-xiao_w / 2, -xiao_l / 2, 2.0])
            cube([xiao_w, xiao_l, xiao_depth + 1.0]);

        // Central aperture for the downward-facing lens
        translate([0, 0, -1])
            cylinder(d = lens_dia, h = 6.0);

        // Horizontal rear cutout for USB-C connector
        translate([-5.5, tray_ext_l / 2 - 4, 2.0])
            cube([11.0, 6.0, xiao_depth + 1.0]);
    }
}
