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
print_sensor=1;
print_body=1;
print_rim=1;

//shell parameters
inch=25.4;
thickness=3;
or=2.95*inch; //default 6" head, remember to change hoop_or to.
ir=or-(thickness);
shell_h=19;
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
//Assume M4 for sensor screw, long M3s are hard to find.
//These parameters should cover most M4 screw heads
sensor_screw_head_h=4; 
sensor_screw_head_r=5;
sensor_screw_r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[4]/2;
sensor_mount_screw_r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[3]/2;
sensor_mount_nut_width=METRIC_NUT_AC_WIDTHS[3];
sensor_mount_depth=15;
platform_h=2;
rim_bolt_size=4;
rim_bolt_r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[rim_bolt_size]/2;

//hoop parameters, modeled on triggerhead 6" heads, with some margin.
hoop_t=7;
hoop_or=84;
hoop_h=7;
rim_h=hoop_h/2+4;
rim_t=hoop_t+rim_bolt_size*0.75;
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
      cylinder(r=sensor_r+2, h=strut_h);
      //mounting/jack strut 
      linear_extrude(height=strut_h) {
        polygon(points=[[mount_offset*cos(144), mount_offset*sin(144)], [mount_offset*cos(216), mount_offset*sin(216)], [or*cos(185),or*sin(185)], [or*cos(175),or*sin(175)]  ]);
      }
      translate([-or,0,0]) rotate([0,75,0]) cylinder(r=7, h=24);
    }
    for (i=[0:4]) {
      rotate([0,0,i*72]) translate ([rim_bolt_offset,0,-0.5]) {
        translate([0,0,METRIC_NUT_THICKNESS[4]+.4]) rotate([0,180,0]) nutHole(4);
        cylinder(r=rim_bolt_r+.1, h=strut_h+1);
      }
    }
    //sensor mount holes
    translate([0,0,-.5]) cylinder(r=sensor_r+1, h=strut_h+1);
    for(i=[0,144,216]) {
      rotate([0,0,i]) translate([sensor_r+sensor_mount_nut_width+2, 0, 0]) {
        translate([0,0,-.5]) cylinder(r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[3]/2, h=sensor_mount_depth+platform_h-strut_h+1);
      }
    }
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

module sensor_platform() {
  difference () {
    union() {
      cylinder(r=sensor_r, h=platform_h);
      translate([0,0,+1]) cylinder(r=sensor_screw_head_r+1, h=sensor_screw_head_h);
    }
    translate([0,0,-1]) cylinder(r=sensor_screw_head_r, h=sensor_screw_head_h+1);
    translate([0,0,-1]) cylinder(r=sensor_screw_r, h=sensor_screw_head_h+platform_h+1);
  }
}

module sensor_mount() {
  difference() {
    union() {
      cylinder(r=sensor_r+sensor_mount_nut_width+2, h=platform_h);
      for(i=[0,144,216]) {
        rotate([0,0,i]) translate([sensor_r+sensor_mount_nut_width+2, 0, 0]) {
          cylinder(r=sensor_mount_nut_width/2+2, h=sensor_mount_depth+platform_h-strut_h);
        }
      }
    }
    for(i=[0,144,216]) {
      rotate([0,0,i]) translate([sensor_r+sensor_mount_nut_width+2, 0, 0]) {
        translate([0,0,-.5]) cylinder(r=COURSE_METRIC_BOLT_MAJOR_THREAD_DIAMETERS[3]/2, h=sensor_mount_depth+platform_h-strut_h+1);
        translate([0,0,-.1]) nutHole(3);
      }
    }
    translate([0,0,-.5]) cylinder(r=sensor_screw_r, h=platform_h+1);
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
    translate([0,0,-0.5]) cylinder(r=hoop_or-hoop_t/2, rim_h-hoop_h/2+1);
    translate([0,0,rim_h-hoop_h/2-.5]) cylinder(r=hoop_or, hoop_h/2+1);
    for (i=[0:4]) {
      rotate([0,0,i*72]) translate([rim_bolt_offset,0,-.5]) #cylinder(r=rim_bolt_r, h=rim_h+1);
    }
  }
}

if (print_sensor) {
  translate([0,or*2,0]) sensor_platform();
  translate([0,or*2+sensor_r*3,0]) sensor_mount();
}

if (print_body) {
  translate([0,0,shell_h]) bearing_edge();
  shell();
  struts();
}

if (print_rim) {
  translate([0,-rim_bolt_offset*2-rim_bolt_size,0]) rim();
}
