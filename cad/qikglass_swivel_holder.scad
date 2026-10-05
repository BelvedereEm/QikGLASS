// QikGLASS SWIVEL HOLDER (mockup) - the simple holder plus two 608 skateboard bearings.
//
//   HOLDER : same outside as the simple holder (44.1 mm clamp, 34 mm grip, lip on top).
//            Two 608 bearings sit inside it, one at the bottom and one higher up,
//            with a web between them.
//   ROTOR  : printed. Its 8 mm stem passes up through both bearings. Its head hangs below
//            the holder and carries the female 3/8"-24 thread for the QWORK head,
//            1.5 mm off-centre, so the wheel trails behind the swivel and steers itself.
//            The scoring force pushes the rotor up; a small shoulder on the head presses
//            only on the lower bearing's inner race, so the bearing carries that load.
//   CLIP   : printed C-clip that snaps into a groove at the top of the stem and stops the
//            rotor dropping out when the head is lifted.
//   OIL    : the rotor is hollow. An oil cup presses onto the top of the stem; oil runs down
//            the stem's bore into a small chamber above the thread and on into the QWORK head's
//            hollow shank, the same way it fed from the original handle. The cup's lid has a
//            tiny vent: cover it with tape to slow the flow (vacuum), uncover it to let oil run.
//
// Bought parts: 2 x 608 bearings (8 x 22 x 7 mm, the skateboard size). Nothing else.

/* [Clamp] */
clamp_d = 44.1;
clamp_h = 34;
fit = 0.2;
lip_d = 52;
lip_h = 4;

/* [Bearings: 608] */
brg_id = 8; brg_od = 22; brg_w = 7;
brg_fit = 0.15;          // pocket is this much bigger than the bearing (press fit)
brg_gap = 14;            // distance between the two bearings (more = less wobble)

/* [Rotor] */
caster = 1.5;            // wheel offset behind the swivel axis
head_d = 24;
head_len = 25;           // how far the rotor head hangs below the holder (was nose_len)
stem_clr = 0.15;         // stem is this much under 8 mm so the bearings slide on

/* [Oil feed] */
oil = true;
oil_bore = 3;            // bore down the middle of the stem
cup_d = 20; cup_h = 9;   // oil cup on top of the stem (about 1.5 ml)
cup_seat = 5;            // how far the stem goes up into the cup

/* [QWORK head thread] */
thread_od = 9.6; thread_len = 11; pitch = 1.058; thread_clr = 0.35;

/* [Output] */
part = "assembled"; // [assembled, exploded, section, holder, rotor, clip, cup, lid]

$fn = 96;
eps = 0.01;
body_d = clamp_d - fit;
web = brg_gap;                                  // solid web between the bearing pockets
holder_h = clamp_h + lip_h;
stem_len = brg_w + web + brg_w + 3 + (oil ? cup_seat : 0);   // through both bearings, room for the clip (and the cup)

function thread_prof(u, rmaj, rmin) =
    let(c = 0.125, r = 0.25, f = (1 - c - r) / 2)
    u < c ? rmaj : u < c + f ? rmaj - (rmaj - rmin) * (u - c) / f :
    u < c + f + r ? rmin : rmin + (rmaj - rmin) * (u - c - f - r) / f;
module thread_cutter(d, p, h) {
    rmaj = d / 2; rmin = d / 2 - 0.5413 * p; n = 120;
    pts = [for (i = [0 : n - 1]) let(a = 360 * i / n, u = (1 - i / n) % 1)
           [thread_prof(u, rmaj, rmin) * cos(a), thread_prof(u, rmaj, rmin) * sin(a)]];
    linear_extrude(height = h, twist = -360 * h / p, slices = ceil(h / p * 48), convexity = 10) polygon(pts);
}

// HOLDER: z = 0 at its bottom face
module holder() {
    difference() {
        union() {
            cylinder(d = body_d, h = clamp_h);
            translate([0, 0, clamp_h]) cylinder(d = lip_d, h = lip_h);
        }
        // lower bearing pocket (from below) and upper pocket (from above the web)
        translate([0, 0, -eps]) cylinder(d = brg_od + brg_fit, h = brg_w + eps);
        translate([0, 0, brg_w + web]) cylinder(d = brg_od + brg_fit, h = brg_w + eps);
        // clearance for the stem through the web (only the inner races touch the stem)
        cylinder(d = 12, h = holder_h + 1);
        // lighten above the upper bearing, leaving a ledge for its outer race
        translate([0, 0, 2 * brg_w + web]) cylinder(d = body_d - 8, h = holder_h);
        // direction notch on the lip, as on the simple holder
        translate([lip_d / 2, 0, clamp_h - eps]) rotate(45) cube([4, 4, 2 * lip_h + 1], center = true);
    }
}

// ROTOR: z = 0 at the top of its head (just under the holder)
module rotor() {
    difference() {
        union() {
            translate([0, 0, -head_len]) cylinder(d = head_d, h = head_len);
            cylinder(d = 11, h = 0.6);                                 // shoulder on the inner race only
            cylinder(d = brg_id - stem_clr, h = 0.6 + stem_len);       // stem
        }
        // female thread for the QWORK head, offset by the caster
        translate([caster, 0, -head_len - eps]) thread_cutter(thread_od + thread_clr, pitch, thread_len + 1.5);
        translate([caster, 0, -head_len - eps]) cylinder(d1 = thread_od + thread_clr + 1, d2 = thread_od + thread_clr - 1.0825 * pitch, h = 1.2);
        // groove for the clip, just above the upper bearing
        translate([0, 0, 0.6 + 2 * brg_w + web + 0.3]) difference() { cylinder(d = 10, h = 1.4); cylinder(d = 6.4, h = 1.4); }
        if (oil) {
            // bore down the stem, and a chamber above the thread that feeds the head's shank
            translate([0, 0, -head_len + thread_len + 1]) cylinder(d = oil_bore, h = head_len + stem_len + 2);
            translate([0, 0, -head_len + thread_len + 1.4]) cylinder(d = 2 * (caster + thread_od / 2) + 0.6, h = 4);
        }
        // grooves showing the wheel direction (line the wheel's plane up with these)
        for (x = [head_d / 2, -head_d / 2]) translate([x, 0, -head_len / 2]) rotate(45) cube([1.2, 1.2, head_len + 2], center = true);
    }
}

module clip() {
    difference() {
        cylinder(d = 14, h = 1.2);
        translate([0, 0, -1]) cylinder(d = 6.6, h = 3);
        translate([0, -2.8, -1]) cube([10, 5.6, 3]);   // opening that snaps over the groove
    }
}

// Oil cup: presses onto the top of the stem, above the clip
module cup() {
    difference() {
        union() {
            cylinder(d = cup_d, h = cup_h);
            translate([0, 0, -cup_seat]) cylinder(d = 12, h = cup_seat + eps);   // socket that grips the stem
        }
        translate([0, 0, 1.5]) cylinder(d = cup_d - 3, h = cup_h);                // the oil well
        translate([0, 0, -cup_seat - eps]) cylinder(d = brg_id - stem_clr - 0.1, h = cup_seat + 0.5);   // press fit on the stem
        translate([0, 0, -1]) cylinder(d = oil_bore, h = 3);                       // outlet into the stem's bore
    }
}
module lid() {
    difference() {
        union() { cylinder(d = cup_d + 2.4, h = 1.6); translate([0, 0, -2]) cylinder(d = cup_d - 3.2, h = 2 + eps); }
        translate([0, 0, -3]) cylinder(d = 0.8, h = 5, $fn = 12);                  // vent: tape over it to slow the flow
        translate([0, 0, -2 - eps]) cylinder(d = cup_d - 6, h = 1.6);
    }
}

module bearing() {
    color([0.75, 0.75, 0.78]) difference() { cylinder(d = brg_od, h = brg_w); translate([0, 0, -1]) cylinder(d = brg_id, h = brg_w + 2); }
    color([0.25, 0.25, 0.28]) translate([0, 0, brg_w - 0.2]) difference() { cylinder(d = brg_od - 3, h = 0.3); cylinder(d = brg_id + 3, h = 1); }
}
module qwork() {   // stand-in for the cutter head
    color("Gold") { cylinder(d = 9.6, h = 11); translate([0, 0, -5]) cylinder(d = 10.5, h = 5); }
    color("Silver") translate([-4, -6, -22]) cube([8, 12, 17]);
    color("DimGray") translate([0, 0, -23]) rotate([0, 90, 0]) cylinder(d = 5, h = 1.2, center = true);
}

module assembly(ex = 0) {
    // shown under load: the rotor's shoulder is pressed up against the lower bearing's inner race
    r0 = -0.6;
    color("Orange") translate([0, 0, 2 * ex]) holder();
    translate([0, 0, ex * 0.6]) bearing();
    translate([0, 0, brg_w + web + ex * 3.4]) bearing();
    color("SteelBlue") translate([0, 0, r0 - ex * 0.3]) rotor();
    color("Red") translate([0, 0, r0 + 0.6 + 2 * brg_w + web + 0.3 + ex * 4.6]) clip();
    translate([caster, 0, r0 - head_len - ex * 1.6]) qwork();
    if (oil) {
        color("LimeGreen") translate([0, 0, r0 + 0.6 + stem_len + ex * 5.6]) cup();
        color("PaleGreen") translate([0, 0, r0 + 0.6 + stem_len + cup_h + ex * 6.4]) lid();
    }
}

if (part == "assembled") assembly(0);
else if (part == "exploded") assembly(14);
else if (part == "section") difference() { assembly(0); translate([-40, -80, -80]) cube([80, 80, 160]); }
else if (part == "holder") translate([0, 0, holder_h]) rotate([180, 0, 0]) holder();
else if (part == "rotor") translate([0, 0, head_len]) rotor();
else if (part == "clip") clip();
else if (part == "cup") translate([0, 0, cup_seat]) cup();
else if (part == "lid") translate([0, 0, 1.6]) rotate([180, 0, 0]) lid();
