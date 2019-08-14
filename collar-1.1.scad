
/* Pi zero details */
pi_zero_board_length = 10;
pi_zero_board_width = 30;
pi_zero_board_height = 5;

spacing = 8;

box_height = pi_zero_board_height + spacing;
box_width =  pi_zero_board_width + spacing;
box_length = pi_zero_board_length + spacing;
box_curve = 1;
box_wall = 3;

$fn=32;


module outer_shell() {

    minkowski() {
        cube(size=[box_height,box_width,box_length],center=true);
        sphere(r=box_curve);
    }

}

module inner_shell() {
    
   minkowski() {
    cube(size=[box_height - box_wall,
               box_width  - box_wall,
               box_length - box_wall ],center=true);
    sphere(r=box_curve);
   }
} 


difference() {
outer_shell();
inner_shell();
}
    