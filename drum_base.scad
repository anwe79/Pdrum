//Draft of printable electronic drum
//Copyright 2013 Andreas Wettergren

/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

use <MCAD/shapes.scad>;
use <MCAD/triangles.scad>;
include <MCAD/nuts_and_bolts.scad>;
$fs=1;
$fa=2;

//All measurements in mm except shell radius due to drum head size conventions
//print_parameters
print_sensor=0;
print_body=1;
print_rim=0;

//shell parameters
inch=25.4;
thickness=5;
or=2.95*inch; //default 6" head, remember to change hoop_or to.
ir=or-(thickness);
shell_h=20;
//bearing parameters
bearing_angle=60;
bearing_r=1.5;
bearing_h=bearing_r/3;
bearing_top=2*sqrt(bearing_h*(2*bearing_r-bearing_h));
triangle_side=(thickness-bearing_top)/2; 
triangle_top=tan(bearing_angle)*triangle_side; 
//misc parameters
strut_h=METRIC_NUT_THICKNESS[4]*1.5;
sensor_r=13.5;
rod_r=2.6;
platform_h=2;
spring_r=5;
rim_bolt_size=4;
rim_bolt_r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[rim_bolt_size]/2;

//hoop parameters, modeled on triggerhead 6" heads, with some margin.
hoop_t=7.5;
hoop_or=85;
hoop_h=7;
rim_h=hoop_h+8;
rim_t=hoop_t+rim_bolt_size;
rim_bolt_offset=hoop_or+rim_t-hoop_t+rim_bolt_r;

module bearing_edge() {
  union() {
    //base trapezoid
    rotate_extrude() {
      translate([or-thickness, 0, 0])
      polygon( points=[[0,0], [triangle_side, triangle_top], [triangle_side+bearing_top, triangle_top], [thickness,0]] );
    }
    //top radius
    difference() {
      translate ([0,0,triangle_top-bearing_r+bearing_h])
      rotate_extrude() {
        translate([or-thickness/2, 0, 0])
        circle(r=bearing_r, $fs=0.3); 
      }
      translate ([0,0,triangle_top-bearing_r]) 
      rotate_extrude() {
        translate([or-thickness/2, 0, 0])
        square(bearing_r*2, center=true);
      }
    }
  }
}

module shell() {
  difference() {
    cylinder (h=shell_h, r=or);
    translate ([0,0,-0.5]) cylinder (h=shell_h+1,r=ir);
    translate([-or-1,0,0]) rotate([0,75,0]) cylinder(r=6.5, h=23);
  }
}

module struts() {
  mounting_hole=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[5]; 
  mount_offset=or/3;
  difference() {
    union() {
        for (i=[0:4]) {
          rotate([0,0,i*72]) {
            hull() {
              translate ([rim_bolt_offset,0,0]) cylinder(r=METRIC_NUT_AC_WIDTHS[rim_bolt_size]/2+2, h=strut_h);
              translate ([0,sensor_r/2,0]) cylinder(r=METRIC_NUT_AC_WIDTHS[rim_bolt_size]/2+1, h=strut_h);
              translate ([0,-sensor_r/2,0]) cylinder(r=METRIC_NUT_AC_WIDTHS[rim_bolt_size]/2+1, h=strut_h);
            }
          }
        }
      for (i=[0:4]) {
        rotate([0,0,i*72]) {
          translate ([0, -(METRIC_NUT_AC_WIDTHS[rim_bolt_size]+2)/2, 0]) cube(size=[rim_bolt_offset, METRIC_NUT_AC_WIDTHS[rim_bolt_size]+2, strut_h]);
        }
      }
      cylinder(r=sensor_r+spring_r*2, h=strut_h);
      //mounting/jack strut 
      linear_extrude(height=strut_h) {
        polygon(points=[[mount_offset*cos(144), mount_offset*sin(144)], [mount_offset*cos(216), mount_offset*sin(216)], [or*cos(185),or*sin(185)], [or*cos(175),or*sin(175)]  ]);
      }
      translate([-or,0,0]) rotate([0,75,0]) cylinder(r=7, h=24);
    }
    for (i=[0:4]) {
      rotate([0,0,i*72]) translate ([rim_bolt_offset,0,-0.5]) {
        #translate([0,0,METRIC_NUT_THICKNESS[4]+.4]) rotate([0,180,0]) nutHole(4);
        cylinder(r=rim_bolt_r+.1, h=strut_h+1);
      }
    }
    translate([0,0,-0.5]) cylinder(r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[3]/2+.1, h=strut_h+1);
    #translate([0,0,strut_h-METRIC_NUT_THICKNESS[3]+.1]) nutHole(3); 
    rod_hole(rod_r*2);
    rotate([0,0,120]) rod_hole(rod_r*2);
    rotate([0,0,240]) rod_hole(rod_r*2);
    //mount and jack holes
    translate([-mount_offset*1.2,0,-.5]) cylinder(r=mounting_hole/2, h=strut_h+1);
    translate([-or-1,0,0]) rotate([0,75,0]) cylinder(r=6.5, h=23);
    translate([-or-1,0,0]) rotate([0,75,0]) cylinder(r=3, h=25);
    translate([-or,0,0]) rotate([0,75,0]) translate([0,0,30]) cube(12, center=true);
    translate([-or,0,0]) rotate([0,75,0]) translate([0,0,23.5]) intersection() {
      cylinder(r=4, h=2);
      cube([6,8,2], center=true);
    }
    translate([-or+12.5,0,-3.5]) cube([25,14,7], center=true);
    translate([-or,0,0]) cube([5,14,15], center=true);
  }
}

module rod_mount() {
    translate([sensor_r+3,0,0]) cylinder(r=spring_r+1, h=platform_h);
}

module rod_hole(depth=platform_h) {
    translate([sensor_r+3,0,-0.4]) cylinder(r=rod_r, h=depth+1);
}

module sensor_platform() {
  difference() {
    union() {
      hull() {
        rod_mount();
        rotate([0,0,120]) rod_mount();
        rotate([0,0,240]) rod_mount();
      }
      //sensor space
      cylinder(r=sensor_r+2, h=platform_h);
      //adjustment screw slot
      difference () {
        translate([0,0,platform_h]) cylinder(r=2.55, h=platform_h);
        translate([0,0,platform_h+.1]) cylinder(r=1.55, h=platform_h+.2);
      }
    }
    rod_hole();
    rotate([0,0,120]) rod_hole();
    rotate([0,0,240]) rod_hole();
  }
}


module rod_cap() {
  union() {
    cylinder(r=spring_r+1, h=2);
    difference() {
      cylinder(r=rod_r+1, h=4);
      translate([0,0,.1]) cylinder(r=rod_r, h=4.2); 
    }
  }  
}

module rim() {
  difference() { 
    union () {
      hull() {
        for(i=[0:4]) {
          rotate([0,0,i*72]) translate([rim_bolt_offset,0,0]) cylinder(r=rim_bolt_r*2, h=rim_h);
        }
      }
      cylinder(r=hoop_or+rim_t-hoop_t, h=rim_h);
    }
    translate([0,0,-0.5]) cylinder(r=hoop_or-hoop_t/2, rim_h-hoop_h+1);
    translate([0,0,rim_h-hoop_h-.5]) cylinder(r=hoop_or, hoop_h+1);
    for (i=[0:4]) {
      rotate([0,0,i*72]) translate([rim_bolt_offset,0,-.5]) #cylinder(r=rim_bolt_r, h=rim_h+1);
    }
  }
}

if (print_sensor) {
  translate([0,or*2,0]) { 
    for (i=[0:2]) {
      rotate([0,0,i*120]) translate([sensor_r+spring_r*4,0,0]) rod_cap();
    }
    sensor_platform();
  }
}

if (print_body) {
  translate([0,0,shell_h]) bearing_edge();
  shell();
  struts();
}

if (print_rim) {
  translate([0,-rim_bolt_offset*2-rim_bolt_size,0]) rim();
}
