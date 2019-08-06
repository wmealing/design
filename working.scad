
$fn=36;

// Size in mm.
neck_size_radius=140;
curve_edge=20;

neck_buffer=10;
pipe_x=25; 
pipe_y=25;

pipe_wall_thickness=2.5;

arm_angle=65;
arm_length=140;

bolt_size=3;
bolt_buffer=2;


module outer_basic() {
			minkowski() {
			 square(size=[pipe_x,pipe_y]);
			 circle(r=curve_edge);
			}
}

module inner_basic() {
			minkowski() {
			 square(size=[pipe_x - pipe_wall_thickness,pipe_y - pipe_wall_thickness]);
			 circle(r=curve_edge - pipe_wall_thickness);
			}
}

module basic_shape() {

	difference() {
		outer_basic();
		inner_basic();
	}

}



module arm() {

// downward curve connecting the arm
rotate([90,270,90]) {

	
	rotate_extrude(angle = arm_angle,convexity = 2) {
		translate([55 + pipe_y, 0, 0]) {
			rotate([0,0,90]) { basic_shape(); }
		}
	}
	translate([pipe_y, 40, 10]) {
		// rotate([90,0,30]) { #cylinder(r=2.5,h=90); }
	}

	rotate_extrude(angle = arm_angle,convexity = 2) {
		translate([30 + pipe_y, 0, 0]) {
			// rotate([0,0,1220]) { square(size = [20, 20]); }
		}
	}



	rotate([0,90, (90 - arm_angle) * -1]) {

		translate([-pipe_x,55,-arm_length]) {
			linear_extrude(height = arm_length, center = false, convexity = 10, twist = 0) {
					basic_shape();
			}
		}			

	}

	
	// end cap on the arm.
	rotate([0,90, (90 - arm_angle) * -1]) {	
			translate([-pipe_x,55,-arm_length - 2]) {
			linear_extrude(height = 2.5, center = false, convexity = 10, twist = 0) {
								outer_basic();
			}
		}
	}




}
	
	
}




module neck() {

	// around neck part.
	difference() { 
		rotate_extrude(angle=180, convexity = 10) {
			translate([neck_size_radius + curve_edge, 0, 0]) {
				basic_shape();
			}
		}
	}

}



module neck_with_bolt_parts() {

	
	neck();

		/* Outside supports for the part1. */
		for (i = [30 : 30 : 150]) {

			/* make the hsape to "bound" the bolt supporst*/
			intersection() {		
				rotate_extrude(angle=180, convexity = 10) {
					translate([neck_size_radius + curve_edge, 0, 0]) {
						outer_basic();
					}
				}

				/* Iterate through the bolt supports */
				rotate([0,0,i]) {
					translate([neck_size_radius + curve_edge + 36 ,0,-18]) {
						difference() {
							cylinder(r=10,h=80);
							cylinder(r=2.5,h=40);
						}

					}
				}
			}
		}




}


module left_arm() {
	translate([-neck_size_radius - curve_edge - pipe_x + curve_edge - (curve_edge / 1.0),0,-55]) {
		arm();
	}
}


module right_arm() {
	translate([neck_size_radius + curve_edge  - curve_edge + (curve_edge / 1.0),0,-55]) {
		arm();
	}
}

module whole() {
		neck_with_bolt_parts();
		left_arm();
		right_arm();
		translate([0,156,-16]) { pi_mount(); }
}




module pi_support() {
	difference() {
		cylinder(h=5, r=3.5, center=true);
		cylinder(h=6, r=2.5, center=true);
	}
}

module pi_mount() {

	translate([0,0,0]) {
		pi_support();
	}

	translate([58,23,0]) {
		pi_support();
	}

	translate([58,0,0]) {
		pi_support();
	}

	translate([0,23,0]) {
		pi_support();
	}


}



/* This is the part that sits on top of part1 */
module part1() {
	offset =12;
	error = 2;
	box2_height = 200;
	h1= 50;

	half_offset = neck_size_radius + pipe_x  + (curve_edge * 2) + error;
 
	difference() {
		intersection() {
			whole();
			/* cut off the top half */
			translate([half_offset * -1 ,half_offset * -1,0]) {	
	
				cube(size=[half_offset * 2,
							 half_offset * 2, pipe_y * 3]);
			}
		} // end intersection

	for (i = [30 : 30 : 150]) {
		rotate([180,0,i]) {
					translate([neck_size_radius + curve_edge + offset + 25,
								0, 
								(h1 + 1) *-1 ]) {
						 cylinder(r=6, h=h1-5);
					}
		}
		
	}


	}

}


/* This is the first part to print */
/* its the part that contacts the back of the neck around to the shoulder */
module part2() {

	error = 2;
	box2_height = 200;

	half_offset = neck_size_radius + pipe_x  + (curve_edge * 2) + error;
 
	difference() {
		whole();

		/* cut off the top half */
		translate([half_offset * -1 ,half_offset * -1,0]) {
			cube(size=[half_offset * 2,
						 half_offset * 2, pipe_y * 2]);
		}

		/* Cut off anything below the flat part on the bottom */
		/* honestly i dont know what this -5 is ?) */
		translate([half_offset * -1,
					half_offset * -1,
					(box2_height + pipe_y - 5) * -1]) {

			cube(size=[half_offset * 2,
						 half_offset * 2, box2_height]);
		}

	}
}

module part3() {


	error = 2;
	box2_height = 200;

	half_offset = neck_size_radius + pipe_x  + (curve_edge * 2) + error;
 
	difference() {
		whole();

		/* cut off the top half */
		translate([half_offset * -1 ,half_offset * -1,( pipe_y - 5) * -1 - 0.01]) {
			cube(size=[half_offset * 2,
						 half_offset * 2, pipe_y * 3]);
		}


	}
}

translate([0,0,0]) {
//	color("green") { part1(); };
}

translate([0,0,-30]) {
	color("blue") { part2(); };
}

translate([0,0,-60]) {
	//color("black") { part3(); };
}



//  whole();