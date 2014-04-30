
// Configuration parameters
$fa=6;
//Pipe diameter
Pd=15;
//Screw diameter
Sd=5;
//Washer type
Penny_washer=true;
//Rubber thickness
Rt=2;
//Base thickness
T=5;
//Inner and outer Clearances
Ic=0;
Oc=4;

//Calculated constants

//Washer diameter
Wd=(Penny_washer) ? 3*Sd : 2*Sd;
//Pipe housing diameters
PHod=Pd+T*2+Rt*2;
PHid=Pd+Rt*2;
//Overall diameter
Od=2*PHod+Wd+2*Ic+2*Oc;
//Pipe offset
Po=Wd/2+Ic+Oc+PHod/2;

module brace() {
  translate([-Od/2, 0, T]) cube([Od, T, PHod-Rt-2*T]);
}

module roundoff() {
  translate([0, 0, PHod/2-Rt-2*T+1]) difference() {
    cube([Od+2, Od+2, PHod-Rt+2*T+2], center=true);
    scale([1, 1, 0.7]) sphere(r=Od/2);
  }
}

/*rotate([0, 180, 0])*/ difference() {
  union() {
    //Base
    cylinder(r=Od/2, h=T);
    translate([0, -Od/2, 0]) cube([Po-PHod/2, Od, T]);
    //Pipe Housing
    translate([Po, Od/2, PHid/2-Rt]) rotate([90, 0, 0]) cylinder(r=(PHod)/2, h=Od);
    translate([Po-PHod/2, -Od/2, 0]) cube([PHod, Od, PHid/2-Rt]);
    //Braces
    translate([0,-Od/5,0]) brace();
    translate([0,-Od/2.5,0]) brace();
    translate([0,Od/5-T,0]) brace();
    translate([0,Od/2.5-T,0]) brace();
  } 
  //Pipe hole
  translate([Po, Od/2+0.5, PHid/2-Rt]) rotate([90, 0, 0]) cylinder(r=(PHid)/2, h=Od+1);
  translate([Po, Od, Pd/2]) rotate([90, 0, 0]) cylinder(r=(Pd)/2, h=Od*2);
  translate([Po-(PHid)/2, -Od/2-0.5, -Rt]) cube([PHid, Od+1, PHid/2]);
  //Rubber cutout and base smoothing
  difference() {
    translate([0, 0, -0.1]) cylinder(r=Od/2-Oc, h=Rt/2);
    cylinder(r=Sd, h=T);
  }
  translate([-Od, -Od, -3*T+0.01]) cube([Od*2, Od*2, 3*T]);
  //Washer and screw holes
  translate([0, 0, T-1]) cylinder(r=Wd/2, h=PHod);
  translate([0, 0, -T/2]) cylinder(r=Sd/2,h=2*T);
  roundoff();
}
