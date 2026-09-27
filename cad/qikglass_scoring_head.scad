// QikGLASS - spring-loaded swivel glass-scoring head for a 3018-PRO CNC
// Drops into the spindle clamp in place of the 775 spindle.
//
// How it works
//   BODY   : sits in the spindle clamp, holds two LM8UU linear bearings.
//   SHAFT  : 8 mm steel rod; slides up/down AND spins freely in the LM8UU bearings.
//   SPRING : compression spring on the shaft, between BODY bottom and CARRIER top.
//            It supplies the scoring pressure (3-4 kg) so small bed/glass
//            height errors don't change the force.
//   COLLAR : 8 mm shaft collar above the CAP stops the shaft from dropping out
//            and sets spring preload.
//   CARRIER: clamps the bottom of the shaft and holds the QWORK cutter HEAD
//            (unscrewed from its handle) offset by `caster` mm, so the wheel
//            trails behind the pivot like a shopping-cart caster and steers
//            itself around curves.
//
// Set the MEASURE-THESE values with calipers, choose `part`, press F6, export STL.

/* [Measure these first] */
// Diameter of the 775 spindle where the clamp grips it (clamp bore)
clamp_d = 42.0;
// Diameter of the cutter-head shank that screws into the handle
head_shank_d = 7.0;
// How far the head shank goes into the carrier
head_insert = 10;

/* [Scoring geometry] */
// Offset between pivot axis and wheel (caster / trail). 0 = no self-steering
caster = 1.5;

/* [Hardware] */
lm_d = 15.0;     // LM8UU outer diameter
lm_l = 24.0;     // LM8UU length
lm_fit = 0.15;   // extra bore clearance for a snug press fit (tune for your printer)
shaft_d = 8.0;
spring_od = 12.5; // spring outer diameter (inner diameter must be > 8.5)
m3_tap = 2.8;     // pilot hole for M3 screws self-tapping into plastic
m3_clear = 3.4;

/* [Glass corner fence] */
fence_h = 2.0;    // keep BELOW your glass thickness
fence_arm = 60;
fence_w = 12;

/* [Output] */
part = "all"; // [all, body, cap, carrier, fence]

$fn = 96;
eps = 0.01;

lip = 3;                       // bottom lip that the bearings sit on
body_h = 2 * lm_l + lip;       // 51 mm
cap_d = clamp_d + 8;
cap_h = 4;
screw_r = (lm_d / 2 + clamp_d / 2) / 2;

carrier_d = 22;
carrier_h = 24;
shaft_depth = 12;

module body() {
    difference() {
        cylinder(d = clamp_d, h = body_h);
        // bearing bore (bearings drop in from the top)
        translate([0, 0, lip]) cylinder(d = lm_d + lm_fit, h = body_h);
        // shaft clearance through the lip
        translate([0, 0, -eps]) cylinder(d = shaft_d + 2, h = lip + 2 * eps);
        // cap screw pilot holes
        for (a = [30, 150, 270]) rotate(a) translate([screw_r, 0, body_h - 12])
            cylinder(d = m3_tap, h = 12 + eps);
    }
}

module cap() {
    difference() {
        cylinder(d = cap_d, h = cap_h);
        translate([0, 0, -eps]) cylinder(d = shaft_d + 1.5, h = cap_h + 2 * eps);
        for (a = [30, 150, 270]) rotate(a) translate([screw_r, 0, -eps]) {
            cylinder(d = m3_clear, h = cap_h + 2 * eps);
            translate([0, 0, cap_h - 1.6]) cylinder(d1 = m3_clear, d2 = 6.2, h = 1.6 + 2 * eps);
        }
    }
}

module carrier() {
    difference() {
        cylinder(d = carrier_d, h = carrier_h);
        // shaft socket (top)
        translate([0, 0, carrier_h - shaft_depth]) cylinder(d = shaft_d + 0.2, h = shaft_depth + eps);
        // spring seat
        translate([0, 0, carrier_h - 2]) cylinder(d = spring_od + 1, h = 2 + eps);
        // shaft clamp screw (from -Y side)
        translate([0, 0, carrier_h - shaft_depth / 2 - 1]) rotate([90, 0, 0])
            cylinder(d = m3_tap, h = carrier_d);
        // cutter-head pocket, offset by caster along +X
        translate([caster, 0, -eps]) cylinder(d = head_shank_d + 0.4, h = head_insert + eps);
        // head clamp screw (from +Y side, perpendicular to the caster direction)
        translate([caster, 0, head_insert / 2]) rotate([-90, 0, 0])
            cylinder(d = m3_tap, h = carrier_d);
        // alignment grooves at +X and -X: set the wheel's plane on this line
        for (x = [carrier_d / 2, -carrier_d / 2]) translate([x, 0, carrier_h / 2])
            rotate(45) cube([1.2, 1.2, carrier_h + 2], center = true);
        // arrow notch on the bottom face showing the wheel side
        translate([carrier_d / 2 - 1, 0, 0]) rotate(45) cube([2, 2, 1.6], center = true);
    }
}

module fence() {
    difference() {
        union() {
            cube([fence_arm, fence_w, fence_h]);
            cube([fence_w, fence_arm, fence_h]);
        }
        for (p = [[fence_arm - 10, fence_w / 2], [fence_w / 2, fence_arm - 10], [fence_w + 12, fence_w / 2]])
            translate([p[0], p[1], -eps]) cylinder(d = 3.8, h = fence_h + 2 * eps);
    }
}

if (part == "body") body();
else if (part == "cap") cap();
else if (part == "carrier") carrier();
else if (part == "fence") fence();
else {
    // exploded assembly preview
    color("SteelBlue") body();
    color("LightSteelBlue") translate([0, 0, body_h + 12]) cap();
    color("Silver") translate([0, 0, -45]) cylinder(d = shaft_d, h = 130);
    color("Orange") translate([0, 0, -45]) carrier();
    color("Tan") translate([60, -30, 0]) fence();
}
