include <nutsnbolts/cyl_head_bolt.scad>;
include <nutsnbolts/materials.scad>;



/* Pi zero details */
pi_zero_board_length = 65;
pi_zero_board_width = 30;
pi_zero_board_height = 5;

pi_hole_length_offset = 58.0;
pi_hole_width_offset = 23.0;

pi_zero_mount_hole_inset = 3.5;
pi_zero_mount_hole_size = 2.75;


/* Human settings */
neck_circumference = 430;
neck_size_radius = neck_circumference  / (2 * 3.1417);
neck_buffer=20;

spacing = 6;

box_height =  pi_zero_board_width + spacing;
box_width =   (pi_zero_board_height * 2) + spacing;
box_length = pi_zero_board_length + spacing;

	bolt_hole_diameter = 2.5;
	bolt_head_size = 3.5;
	bolt_head_height = 2.0;
	bolt_len = 15;


$fn=32;

printing = 0;

module pi_sample_board() {

	translate([32,-23.5,-15] ) {
		rotate([0,0,180]) {
			import("RaspberryPiZeroW.stl");
		}
	}
}

/* Confirmed part */
module neck_contact() {
	difference() {
        cube(size=[box_length,box_width,box_height ],center=true);

		 translate([0,62,0]) {
		 	rotate([0,0,0]) { 
				cylinder(r=neck_size_radius, h=80, center=true);
			 }
		 }
	}
}




module neck_contact_smoothed() {

	minkowski() {
		neck_contact();
		sphere(r=1);
	}


}

module neck_bolt_hole() {

		rotate([90,0,0]) {
			/* Bolt hole*/
			cylinder(r=bolt_hole_diameter / 2.0, h=bolt_len);

			/* Subset head */
			translate([0,0,-12]) {  
				cylinder(r=bolt_head_size / 2.0, h=bolt_len);
			}
		}
}


module bolt_holes() {
	/* 4 bolt holes */

	// bottom right hole
	translate([pi_hole_length_offset / 2.0,
				0,
				pi_hole_width_offset / 2.0]) {
			neck_bolt_hole();

	}

	// top right hole 
	translate([pi_hole_length_offset / 2.0,
				0,
				-pi_hole_width_offset / 2.0]) {
			neck_bolt_hole();

	}


	// bottom left hole
	translate([-pi_hole_length_offset / 2.0,
				0,
				pi_hole_width_offset / 2.0]) {
			neck_bolt_hole();

	}

	// top left hole
	translate([-pi_hole_length_offset / 2.0,
				0,
				-pi_hole_width_offset / 2.0]) {
			neck_bolt_hole();
	}

}

module neck_contact_final() {

	difference() {
		neck_contact_smoothed();
   		bolt_holes();	
	}

}

module pi_holder_unsmoothed() {

	wall_thickness = 2;

	translate([0,-20,0]) {

		difference() { 
        	cube(size=[box_length,box_width,box_height ],center=true);
     
			translate([0,-4,0]) { 
	   			cube(size=[box_length - wall_thickness,
							 box_width - wall_thickness,
				     		 box_height - wall_thickness ],center=true);
			}


		}

	}
}

module pi_holder() {

	color("red") {
		minkowski() {
			pi_holder_unsmoothed();
			sphere(r=1);
		}
	}
}

module pi_holder_lid() {

	translate([0,-57,0]) {
	
		rotate([180,0,0]) {
			color("blue") {
				minkowski() {
					pi_holder_unsmoothed();
					sphere(r=1);
				}
			}
		}

	}
}


module pi_holder_final() {

	difference() {
	pi_holder();
	translate([0,-5,0]) { 
			bolt_holes(); 

		}
	}
}

module pi_holder_lid_final() {

	difference() {	
		pi_holder_lid();
		translate([0,-48,0]) { 

		rotate([180,0,0]) { bolt_holes(); }

		}
	}
}



// neck_contact_final();
//pi_holder_final();
pi_holder_lid_final();

//pi_sample_board();
// translate([0,-20,0]) { rotate([90,0,270]) { pi_sample_board(); } }
