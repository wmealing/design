 
$fn=36;
neck_circumference = 430;

// Size in mm.
neck_size_radius = neck_circumference  / (2 * 3.1417);
neck_buffer=20;

collar_radius =  neck_size_radius + neck_buffer;


pipe_x=35; 
pipe_y=20;
curve_edge=5;


pipe_wall_thickness=2.5;

arm_angle=65;
arm_length=140;

bolt_size=3;
bolt_buffer=2;

pi_width = 23;
pi_length = 58;

// 220 x 220 mm.
ender_bed = 220;

total_curve_radius = collar_radius + pipe_x + (curve_edge * 2);

	
inner_radius = neck_size_radius + curve_edge + neck_buffer;
outer_radius = inner_radius + (curve_edge * 2) + pipe_x;
	

connection_height = 10;
connection_width = 18;
connection_depth = 18;


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

module wall() {
	square(size=[5,18]);
}



module half_connector_v2() {

	difference() {
		double_bolt();

		translate([-1,0,0]) {

			rotate([0,90,0]) {
				#cylinder(r=2.5,h=connection_width + 2);
			}

		}

		translate([-1,connection_height - 2,0]) {

			rotate([0,90,0]) {
				cylinder(r=2.5,h=connection_width + 2);
			}

		}


	}

}

module double_bolt() {

//	 half_connector();	
	rotate([0,90,0]) {

		
		translate([0,0,0]) {
			cylinder(r=connection_height/2+ 2,h=connection_width);
		}

		translate([0,connection_height - 2,0]) {
			cylinder(r=connection_height/2 + 2,h=connection_width);
		}

	}


	
}

module arm() {
	arm_with_bolt_holes();
}

module arm_with_bolt_holes() {

	difference() {
		arm_design();

		translate([45,-30,55]) {
			rotate([0,90+ 180,0]) {
				cylinder(r=2.5,h=55);
			}
		}

	}

}


module arm_design() {

	connecting_block_width=10;
	connecting_block_length=25;

	error = 2;

// downward curve connecting the arm
rotate([90,270,90]) {

	rotate_extrude(angle = arm_angle,convexity = 2) {
		translate([55 + pipe_y, 0, 0]) {
			rotate([0,0,90]) { basic_shape(); }
		}
	}

	rotate([0,90, (90 - arm_angle) * -1]) {
 
		translate([-pipe_x,55,-arm_length +1]) {
			linear_extrude(height = arm_length, center = false, convexity = 10, twist = 0) {
					basic_shape();
			}
		}			

	}

	
	// end cap on the arm.
	rotate([0,90, (90 - arm_angle) * -1]) {	
			translate([-pipe_x,55,-arm_length - 2]) {
			linear_extrude(height = 2.6, center = false, convexity = 10, twist = 0) {
								outer_basic();
			}
		}
	}



}
	
	
}




module neck() {
	
	error = 0.1;


	// around neck part.
	difference() { 
		rotate_extrude(angle=180, convexity = 10) {
			translate([neck_size_radius + curve_edge + neck_buffer, 0, 0]) {
				basic_shape();
			}
		}
	}


	
	translate([(connection_depth  / -2.0),
				outer_radius -1, 
				( pipe_y  / 2.0 )- curve_edge + 1.2]) {
		rotate([90,0,0]) { half_connector_v2(); }
	}

}

module neck_with_insets() {

	difference() {

		neck_with_bolt_parts();

		/* Outside supports for the part1. */
		for (i = [30 : 30 : 150]) {

			if (i == 90) {
			// Dont make center hole.
			}
			else {

			rotate([0,0,i]) {

				translate([outer_radius - 15, 
										0,
										-10]) {	
					cylinder(r=6,h=15);
				} // end translate.
			}

			} // end rotate

		} // end for

	} // end difference

}


module neck_with_bolt_parts() {

	neck();

		/* Outside supports for the part1. */
		for (i = [30 : 30 : 150]) {

			if (i == 90) {
				echo("SKIPPING");
			}

			else {

				/* make the shape to "bound" the bolt supports */
				intersection() {		
					rotate_extrude(angle=180, convexity = 10) {
						translate([neck_size_radius + curve_edge + neck_buffer, 0, 0]) {
							outer_basic();
						}
					}	

					/* Iterate through the bolt supports */
					rotate([0,0,i]) {

						translate([neck_size_radius + curve_edge + neck_buffer + pipe_x -5 ,
									0,
									-18]) {	
							difference() {
								cylinder(r=6,h=80);
								cylinder(r=2.5,h=40);
							}
						}
					}
				} // intersection

			}
		
		} // end for




}


module left_arm() {
	translate([(neck_size_radius + pipe_x + curve_edge + neck_buffer) * -1,
				 0,
				 -55]) {
		arm();
	}
}


module right_arm() {
	translate([neck_size_radius + curve_edge + neck_buffer, 
				0,
				-55]) {
		arm();
	}
}

module whole() {
		neck_with_insets();
		left_arm();
		right_arm();
		pi_mount(); 
}




module pi_support() {
	difference() {
		cylinder(h=5, r=3.5, center=true);
		cylinder(h=6, r=2.5, center=true);
	}
}

module pi_mount() {

translate([(pi_length / 2.0)* -1 ,neck_size_radius + neck_buffer + 5,0]) {

	translate([0,0,0]) {
		pi_support();
	}

	translate([pi_length,pi_width,0]) {
		pi_support();
	}

	translate([pi_length,0,0]) {
		pi_support();
	}

	translate([0,pi_width,0]) {
		pi_support();
	}
}


}



/* This is the part that sits on top of part2 */
module part1() {

	offset = 12;
	error = 2;
	box2_height = 200;
	h1= 50;

	half_offset = neck_size_radius + pipe_x  + (curve_edge * 2) + error;
 
	difference() {
		intersection() {
			whole();

			/* cut off the top half */
			translate([half_offset * -2,
						half_offset * -1,
						(pipe_y / 2.0)]) {	
	
				cube(size=[half_offset * 4,
							 half_offset * 3, pipe_y * 3]);
			}
		} // end intersection

	for (i = [30 : 30 : 150]) {

		if (i == 90) {

		}
		else { 
			rotate([180,0,i]) {
					translate([neck_size_radius + curve_edge + neck_buffer + pipe_x -5,
								0, 
								(h1 + 15) * -1 ]) {
						 cylinder(r=5, h=50);
					}
			}
		}
		
	}


	}

}




module part1a() {

	error = 10;

	difference() {
		part1();

		// WORKING collar_radius
		translate([0,(total_curve_radius / 2) * -1,-10]) { 
			cube(size=[total_curve_radius + error,
						 total_curve_radius* 2,60]);
		}
	}


}

module part1b() {
	
	error = 10;

	difference() {
		part1();

		// WORKING collar_radius
		translate([(total_curve_radius  * -1) - error ,(total_curve_radius / 2) * -1,-10]){ 
			cube(size=[total_curve_radius + error ,
						 total_curve_radius* 2,60]);
		}
	}

}



/* This is the first part to print */
/* its the part that contacts the back of the neck around to the shoulder */
module part2() {

	error = 1;
	box2_height = 200;

	half_offset = neck_size_radius + pipe_x  + (curve_edge * 2) + error;
 
	difference() {
		whole();

		/* cut off the top half */
		translate([half_offset * -2,
					half_offset * -1,
					(pipe_y / 2.0)]) {	

					cube(size=[half_offset * 4,
								 half_offset * 4, pipe_y * 2]);
		}

		/* Cut off anything below the flat part on the bottom */
		/* honestly i dont know what this -5 is ?) */
		translate([half_offset * -1.5,
					half_offset * -1.5,
					(box2_height * -1 ) - curve_edge ]) {

			cube(size=[half_offset * 3,
						 half_offset * 3, box2_height]);
		}

	}
}


module part2a() {
	
	error = 10;

	difference() {
		part2();

		// WORKING collar_radius
		translate([0,(total_curve_radius - 30) * -1,-10]) { 
			cube(size=[total_curve_radius + error,
						 total_curve_radius* 2,30]);
		}
	}

}

module part2b() {

	error = 10;

	difference() {
		part2();

		translate([total_curve_radius * -1 - error ,(total_curve_radius / 2) * -1,-10]) { 
			cube(size=[total_curve_radius + error,
						 total_curve_radius* 2, 30]);
		}
	}

}


module part3() {


	error = 1;
	box2_height = 200;

	half_offset = neck_size_radius + pipe_x  + (curve_edge * 2) + error;
 
	intersection() {

		whole();

		/* Cut off anything below the flat part on the bottom */
		/* honestly i dont know what this -5 is ?) */
		translate([half_offset * -1.5,
					half_offset * -1.5,
					(box2_height * -1 ) - curve_edge - 0.01 ]) {

			cube(size=[half_offset * 3,
						 half_offset * 3, box2_height]);
		}

	}


	// add parts that connet to part 2.
	// WORKING

	translate([+2.6,0,-55]) {

	rotate([-180,-90,0]) {
		rotate_extrude(angle = arm_angle,convexity = 2) {
			translate([55 + pipe_y, (outer_radius * -1) + 5, 0]) {
				rotate([0,0,90]) { wall(); }
			}
		}
	}

	}

	
	translate([+34.8,0,-55]) {

	rotate([-180,-90,0]) {
		rotate_extrude(angle = arm_angle,convexity = 2) {
			translate([55 + pipe_y, (outer_radius * -1) + 5, 0]) {
				rotate([0,0,90]) { wall(); }
			}
		}
	}

	}


}


module part3a() {
	
	block=100;

	difference() {
	 	part3();

		/* cut off the top half */
		translate([0,-300,-200]) {
				cube(size=[block * 2,
						 block * 3, block * 2]);
		}

	}
}

module part3b() {

	block=100;

	difference() {
		part3();

			/* cut off the top half */
		translate([-200,-300,-200]) {
				cube(size=[block * 2,
					 block * 3, block * 2]);
		}
	}
}

module ender_bed() {
	cube(size=[220,220,5]);
}


module part_green() {

	translate([0,0,10]) {
 		color("green") { 	

			translate([-5,0,0]) {	
				part1a(); 
			}

			translate([5,0,0]) {
				part1b(); 
			}

 		};
	}
}




module part_blue() {

	translate([0,0,0]) {
		color("blue") { 
	
			translate([0,0,0]) {
				part2a(); 
			}
	
			translate([0,0,0]) {
				part2b(); 
			}

		};

	}
}

module part_black() {

translate([0,0,0]) {
	color("black") { part3(); };
}

}


printable = 1;

if (printable == 1) {
	//rotate([0,180,0]) { part1a(); }
	//rotate([0,180,0]) { part1b(); }
 	// part2a();
	part2b();
	//rotate([25,0,0]) { part3a(); }
	//rotate([25,0,0]) { part3b(); }

}
else {
	// part_green();
	// part_blue();
	// part_black();
}


// part_black();

// part1();
//intersection() {
// part2();
// part3();
//}

//whole();
