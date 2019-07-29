
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

module little_wall() {

	rotate_extrude(angle = 3,convexity = 2) {
		translate([neck_size_radius - (pipe_x * 2) - (curve_edge / 2.0), curve_edge, 0]) {
			rotate([0,0,180]) { 
		
				difference() {
					scale([1.0,1.0,1.0]) { inner_basic(); }
					scale([0.9,0.9,0.9]) { inner_basic(); }
				} 

				}
		}
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
		neck();
		left_arm();
		right_arm();

		translate([0,156,-16]) { pi_mount(); }
}

module part1() {

		box_height = pipe_x * 2;

difference() {
		difference() {
			whole();
			translate([-neck_size_radius*2,-neck_size_radius,0]) {
				cube(size=[neck_size_radius*4,neck_size_radius*3,box_height]);	
			}
		}

		translate([-neck_size_radius*2,-neck_size_radius * 1.5,0- ((box_height *4) + (pipe_y / 2) + (curve_edge / 2.0) - 2.1)]) {
				cube(size=[neck_size_radius*4,neck_size_radius*4,box_height* 4]);	
		}
}

	// binding walls
	rotate([0,0,150]) {
		translate([102,0,0]) {
			little_wall();
		}
	}

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

part1();
// whole();