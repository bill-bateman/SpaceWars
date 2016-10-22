`timescale 1ns / 1ns 

module SpaceWars(CLOCK_50, KEY , GPIO_0, GPIO_1, LEDR, SW, 
//HEX
		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
//VGA PORTS
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]


);

	/***************************************************************
							DEFINING INPUTS AND OUTPUTS
	***************************************************************/
   input CLOCK_50;
	input [35:0] GPIO_1;
	input [3:0]KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	output [35:0]GPIO_0;
	output [7:0]HEX0;
	output [7:0]HEX1;
	output [7:0]HEX2;
	output [7:0]HEX3;
	output [7:0]HEX4;
	output [7:0]HEX5;					
	
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	/***************************************************************
							DEFINING LOCAL SIGNALS
	***************************************************************/
	wire vcc, gnd;
	assign vcc = 1'b1;
	assign gnd = 1'b0;
	//logic 1 and logic 0
	
	wire clock_60hz, game_clock;
	//alternate clock signals
	
	wire clock60hz, clock6us;
	// controller related clock signals 
	
	
	/*** USER INPUTS ***/
	wire a1, b1, sel1, st1, up1, down1, left1, right1;
	//inputs for the left ship
	wire a2, b2, sel2, st2, up2, down2, left2, right2;
	//inputs for the right ship
	
	
	/*** OUTPUTS TO CONTROLLER ***/
	wire latch, pulse;
	assign GPIO_0[0] = latch;
	assign GPIO_0[2] = pulse;
	
	wire latch1, pulse1;
	//these wires don't do anything
	//physically, both controllers are wired to the same latch and pulse wire
	
	
	/*** LEFT SHIP ***/
	
	wire[9:0] leftX, leftY;
	//position of left ship
	
	wire left_frame;
	
	wire[9:0] left_atk_1_x, left_atk_1_y;
	wire[9:0] left_atk_2_x, left_atk_2_y;
	wire[9:0] left_atk_3_x, left_atk_3_y;
	wire[9:0] left_atk_4_x, left_atk_4_y;
	wire[9:0] left_def_x, left_def_y;
	wire left_atk_1_exist, left_atk_2_exist, left_atk_3_exist, left_atk_4_exist, left_def_exist;
	wire [2:0] left_atk_1_explode, left_atk_2_explode, left_atk_3_explode, left_atk_4_explode;
	//data on left projectiles
	
	wire left_atk_proj_hit_planet;
	wire left_def_proj_hit_right_atk_proj;
	//collision detection wires
	
	wire  data1;
	//data wire for controller module
	
	
	/*** RIGHT SHIP ***/
	
	wire [9:0] rightX, rightY;
	//position of right ship
	
	wire right_frame;
	
	wire[9:0] right_atk_1_x, right_atk_1_y;
	wire[9:0] right_atk_2_x, right_atk_2_y;
	wire[9:0] right_atk_3_x, right_atk_3_y;
	wire[9:0] right_atk_4_x, right_atk_4_y;
	wire[9:0] right_def_x, right_def_y;
	wire right_atk_1_exist, right_atk_2_exist, right_atk_3_exist, right_atk_4_exist, right_def_exist;
	wire [2:0] right_atk_1_explode, right_atk_2_explode, right_atk_3_explode, right_atk_4_explode;
	//data on right projectiles
	
	wire right_atk_proj_hit_planet;
	wire right_def_proj_hit_left_atk_proj;
	//collision detection wires
	
	wire data2;
	//data wire for controller module
	
	/*** PLANET STATUS ***/
	wire [1:0] left_planet_status;
	wire [1:0] right_planet_status;
	
	wire [1:0]game_state;
	//current game state
	
	wire[3:0] draw_state;
	//current draw state
	
	wire doneDrawing; 
	//signal from draw datapath
	
	wire [8:0] colour;
	//9 bit color (to vga)
	wire[9:0] x_plot, y_plot;
	//position to draw (to vga)
	wire plot;
	//1 if currently drawing to vga
	wire doneFrame;
	//1 if just finished drawing a frame to the screen
	
	
	
	
	wire earth_defense;
	assign earth_defense = SW[0];
	
	wire War;
	assign War = SW[1];
	
	wire faster_proj;
	assign faster_proj = SW[6];
	
	wire lower_cooldown;
	assign lower_cooldown = SW[7];
	
	wire piercing_projectile;
	assign piercing_projectile = SW[8];
	
	wire no_cooldown;
	assign no_cooldown = SW[9];
	
	//Game mode parameters
	
	
	wire [7:0]mars_score_counter;
	wire [7:0]earth_score_counter;
	//Score Counter
	
	
	wire [7:0]projectile_defense_counter;
	// score counter for earth defense
	
	wire [7:0]projectile_defense_counter_dummy;
	// dummy wire to send to left ship. will not need 
	
	wire [7:0]earth_defence_1;
	wire [7:0]earth_defence_2;
	wire [7:0]earth_score_1;
	wire [7:0]earth_score_2;
	wire [7:0]mars_score_1;
	wire [7:0]mars_score_2;
	// used to hold decoded hex values for scores 
	
	/*** PARAMETERS ***/
	
	parameter[3:0] INIT = 4'b0000, WAIT = 4'b0001 , DRAW_BACKGROUND = 4'b0010, DRAW_PLANET_LEFT=4'b0011, DRAW_PLANET_RIGHT=4'b0100,
		DRAW_SHIP_LEFT=4'b0101, DRAW_SHIP_RIGHT = 4'b0110 , DRAW_ATK_PROJ_RIGHT=4'b0111, DRAW_DEF_PROJ_RIGHT = 4'b1000 , DRAW_ATK_PROJ_LEFT=4'b1001, DRAW_DEF_PROJ_LEFT=4'b1010,
		UPDATE_GAME_STATE=4'b1111;
	//draw state parameters
	
	parameter[1:0] MENU= 2'b00, PLAY = 2'b01, GAMEOVER_VICTORY_RIGHT = 2'b10 , GAMEOVER_VICTORY_LEFT = 2'b11;  
	//game state parameters
	
	/***************************************************************
							DEFINING CLOCK SIGNALS
	***************************************************************/
	timer_60hz hz60(CLOCK_50, clock_60hz);
	timer_30hz hz4(clock_60hz, game_clock);
	
	/*** CONTROLLER RELATED CLOCKS ***/
	get60HzClock clk60hz(CLOCK_50, clock60hz);
	get6usClock clk6us(CLOCK_50, clock6us);
	
	/***************************************************************
								USER INPUTS
	***************************************************************/
	/*** LEFT SHIP ***/	
	assign data1 = GPIO_1[2];
	nes_fsm NES_1(CLOCK_50, clock60hz, clock6us, latch1, pulse1, data1, a1,b1,sel1,st1,up1,down1,left1,right1);
	//controller module
	
	/*** RIGHT SHIP ***/
	assign data2 = GPIO_1[0];
	nes_fsm NES_2(CLOCK_50, clock60hz, clock6us, latch, pulse, data2, a2,b2,sel2,st2,up2,down2,left2,right2);
	//controller module for right ship
	
	
	//looks cool to have inputs flash the LEDs
	assign LEDR[0] = a1;
	assign LEDR[1] = b1;
	assign LEDR[2] = up1;
	assign LEDR[3] = down1;
	assign LEDR[4] = st1;
	assign LEDR[5] = a2;
	assign LEDR[6] = b2;
	assign LEDR[7] = up2;
	assign LEDR[8] = down2;
	assign LEDR[9] = st2;
		
	/***************************************************************
							SHIP AND PROJECTILE CONTROL
	***************************************************************/
	
	/*** LEFT SHIP ***/
	ship_control left_ship(
		.clock_50(CLOCK_50),
		.draw_state(draw_state),
		.btn_a(a1), .btn_b(b1), .btn_up(up1), .btn_down(down1),
		.x_pos(leftX), .y_pos(leftY),
		.atk_1x(left_atk_1_x), .atk_1y(left_atk_1_y), .atk_1exist(left_atk_1_exist), .atk_1explode(left_atk_1_explode),
		.atk_2x(left_atk_2_x), .atk_2y(left_atk_2_y), .atk_2exist(left_atk_2_exist), .atk_2explode(left_atk_2_explode),
		.atk_3x(left_atk_3_x), .atk_3y(left_atk_3_y), .atk_3exist(left_atk_3_exist), .atk_3explode(left_atk_3_explode),
		.atk_4x(left_atk_4_x), .atk_4y(left_atk_4_y), .atk_4exist(left_atk_4_exist), .atk_4explode(left_atk_4_explode),
		.def_x(left_def_x), .def_y(left_def_y), .def_exist(left_def_exist),
		.enemy_def_x(right_def_x), .enemy_def_y(right_def_y), .enemy_def_exist(right_def_exist),
		.def_collision(left_def_proj_hit_right_atk_proj),
		.planet_collision(left_atk_proj_hit_planet),
		.destroy_enemy_def(right_def_proj_hit_left_atk_proj),
		.is_left_ship(vcc), .frame(left_frame),
		.game_state(game_state),
		.clock_30(game_clock),
		.earth_defense(earth_defense),
		.earth_defense_counter(projectile_defense_counter_dummy), // May have to make this a dummy wire, but theoretically sjould never be triggered 
		.defense_counter_resetn(KEY[0]),
		.faster_proj(faster_proj),
		.lower_cooldown(lower_cooldown),
		.piercing_projectile(piercing_projectile),
		.no_cooldown(no_cooldown)
	);
	
	
	/*** RIGHT SHIP ***/
	ship_control right_ship(
		.clock_50(CLOCK_50),
		.draw_state(draw_state),
		.btn_a(a2), .btn_b(b2), .btn_up(up2), .btn_down(down2),
		.x_pos(rightX), .y_pos(rightY),
		.atk_1x(right_atk_1_x), .atk_1y(right_atk_1_y), .atk_1exist(right_atk_1_exist), .atk_1explode(right_atk_1_explode),
		.atk_2x(right_atk_2_x), .atk_2y(right_atk_2_y), .atk_2exist(right_atk_2_exist), .atk_2explode(right_atk_2_explode),
		.atk_3x(right_atk_3_x), .atk_3y(right_atk_3_y), .atk_3exist(right_atk_3_exist), .atk_3explode(right_atk_3_explode),
		.atk_4x(right_atk_4_x), .atk_4y(right_atk_4_y), .atk_4exist(right_atk_4_exist), .atk_4explode(right_atk_4_explode),
		.def_x(right_def_x), .def_y(right_def_y), .def_exist(right_def_exist),
		.enemy_def_x(left_def_x), .enemy_def_y(left_def_y), .enemy_def_exist(left_def_exist),
		.def_collision(right_def_proj_hit_left_atk_proj),
		.planet_collision(right_atk_proj_hit_planet),
		.destroy_enemy_def(left_def_proj_hit_right_atk_proj),
		.is_left_ship(gnd), .frame(right_frame),
		.game_state(game_state),
		.clock_30(game_clock),
		.earth_defense(earth_defense),
		.earth_defense_counter(projectile_defense_counter),
		.defense_counter_resetn(KEY[0]),
		.faster_proj(faster_proj),
		.lower_cooldown(lower_cooldown),
		.piercing_projectile(piercing_projectile),
		.no_cooldown(no_cooldown)
	);
	
	
	/***************************************************************
							PLANETS AND GAME STATE
	***************************************************************/
	/*** PLANETS ***/
	planet_status lp(
		.clock(CLOCK_50),
		.planet_hit(right_atk_proj_hit_planet),
		.game_state(game_state),
		.status(left_planet_status),
		.War(War)
	);
	planet_status rp(
		.clock(CLOCK_50),
		.planet_hit(left_atk_proj_hit_planet),
		.game_state(game_state),
		.status(right_planet_status),
		.War(War)
	);

	/*** GAME STATE FSM ***/
	//module gamestate_fsm(clock_50M, left_planet_status, right_planet_status, a1, a2, game_state);
	gamestate_fsm gm(
		.clock_50M(CLOCK_50),
		.left_planet_status(left_planet_status),
		.right_planet_status(right_planet_status),
		.st1(st1),
		.st2(st2),
		.game_state(game_state),
		.score_resetn(KEY[0]),
		.mars_score_counter(mars_score_counter),
		.earth_score_counter(earth_score_counter),
		.earth_defense(earth_defense)
	);
	
	
	/***************************************************************
							DRAW FSM AND DATAPATH
	***************************************************************/
	draw_fsm dr(CLOCK_50, doneFrame, game_clock, draw_state, game_state, doneDrawing);
	//controls the draw state
	
	draw_datapath DP(CLOCK_50, draw_state, game_state, doneDrawing, x_plot, y_plot, plot, colour,
			leftX, leftY, rightX, rightY, left_frame, right_frame,
			left_planet_status, right_planet_status,
			left_atk_1_x, left_atk_1_y, left_atk_1_exist, left_atk_1_explode,
			left_atk_2_x, left_atk_2_y, left_atk_2_exist, left_atk_2_explode,
			left_atk_3_x, left_atk_3_y, left_atk_3_exist, left_atk_3_explode,
			left_atk_4_x, left_atk_4_y, left_atk_4_exist, left_atk_4_explode,
			left_def_x, left_def_y, left_def_exist,
			right_atk_1_x, right_atk_1_y, right_atk_1_exist, right_atk_1_explode,
			right_atk_2_x, right_atk_2_y, right_atk_2_exist, right_atk_2_explode,
			right_atk_3_x, right_atk_3_y, right_atk_3_exist, right_atk_3_explode,
			right_atk_4_x, right_atk_4_y, right_atk_4_exist, right_atk_4_explode,
			right_def_x, right_def_y, right_def_exist
			);
	//uses x_plot, y_plot, colour, and plot to draw to the VGA module
	
	
	/***************************************************************
									HEX OUTPUTS
	***************************************************************/
	
		
	hex_decoder earth_d_1(.val(projectile_defense_counter%10),
						.hex_out(earth_defence_1)
						);
							
							
	hex_decoder earth_d_2(.val(projectile_defense_counter/10),
						.hex_out(earth_defence_2)
						);		
			
	hex_decoder e_score_1(.val(earth_score_counter%10),
						.hex_out(earth_score_1)
						);
							
	hex_decoder e_score_2(.val(earth_score_counter/10),
						.hex_out(earth_score_2)
						);		
							
							
	hex_decoder m_score_1(.val(mars_score_counter%10),
						.hex_out(mars_score_1)
						);
							
							
	hex_decoder m_score_2(.val(mars_score_counter/10),
						.hex_out(mars_score_2)
						);						
	// hex decoders loading the values of the first and secodn digits of each score counter onto a wire 
		
			
			
	assign HEX2	= 8'b11111111;
	assign HEX3	= 8'b11111111;
	
	// assigning HEX 2&3 to blank
	
	
	assign HEX0 = (earth_defense)? (earth_defence_1):(earth_score_1) ;
	
	assign HEX1 = (earth_defense)? (earth_defence_2):(earth_score_2);
	
	assign HEX4 = (earth_defense)? (8'b11111111):(mars_score_1);

	assign HEX5 = (earth_defense)? (8'b11111111):(mars_score_2);

	// displays the appropriate score to the hex displays 
	
	
	/***************************************************************
											VGA
	***************************************************************/
	
	vga_adapter VGA(
			.resetn(vcc),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x_plot),
			.y(y_plot),
			.plot(plot),
			.doneFrame(doneFrame),
			// Signals for the DAC to drive the monitor. 
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "title_screen.mif";
endmodule


/***************************************************************
						SHIP CONTROL
________________________________________________________________
-controls all aspects of the ship and its projectiles
-does movement of the ship and boundary checking on the upper/lower walls
-does projectile generation/movement/collision detection
-collision detection is with attack projectiles on the enemy planet and enemy defense projectile
***************************************************************/
module ship_control(clock_50, draw_state, btn_a, btn_b, btn_up, btn_down, 
	x_pos, y_pos, atk_1x, atk_1y, atk_1exist, atk_1explode, atk_2x, atk_2y, atk_2exist, atk_2explode,
					  atk_3x, atk_3y, atk_3exist, atk_3explode, atk_4x, atk_4y, atk_4exist, atk_4explode,
					  def_x, def_y, def_exist,
			  enemy_def_x, enemy_def_y, enemy_def_exist,
			  def_collision, planet_collision, destroy_enemy_def,
			  is_left_ship, frame, game_state, clock_30, earth_defense, earth_defense_counter, defense_counter_resetn,faster_proj,lower_cooldown,piercing_projectile,no_cooldown);
			  
  /***************************************************************
						DEFINING INPUTS AND OUTPUTS
	***************************************************************/
			  
	input clock_50;
	//50Mhz clock for registers
	
	input [1:0]game_state;
	
	input [3:0] draw_state;
	//current draw state (only move when in the UPDATE_GAME_STATE draw state)
	
	input btn_a, btn_b, btn_up, btn_down;
	//user inputs
	
	input [9:0] enemy_def_x, enemy_def_y;
	input enemy_def_exist;
	//information on the enemies defense projectile (for collision)
	
	input is_left_ship;
	//equal to 1'b1 if this is the ship on the left-hand side of the screen
	
	input def_collision;
	//wire from enemy ship - whether or not to destroy this.def_proj from a collision
	
	input clock_30;
	//30 HZ clock
	
	input earth_defense;
	
	input defense_counter_resetn;
	// resets the defense counter to 0
	
	input faster_proj;
	//controls the faster projectile cheat 
	
	input lower_cooldown;
	// controls the lower cooldwon cheat
	
	input piercing_projectile;
	//controls projectile pirecing
	
	input no_cooldown;
	//removes projectile cooldown 
	
	output reg destroy_enemy_def = 1'b0;
	//wire to enemy ship - whether or not to destory the other def_proj from a collision
		
	
	output reg [9:0] x_pos=10'd0, y_pos=10'd0, atk_1x=10'd0, atk_2x=10'd0, atk_3x=10'd0, atk_4x=10'd0, atk_1y=10'd0, atk_2y=10'd0, atk_3y=10'd0, atk_4y=10'd0, def_x=10'd0, def_y=10'd0;
	//positions of the ship and all projectiles
	
	output reg atk_1exist=1'd0, atk_2exist=1'd0, atk_3exist=1'd0, atk_4exist=1'd0, def_exist=1'd0;
	//existence of the projectiles
	
	output reg [2:0] atk_1explode, atk_2explode, atk_3explode, atk_4explode;
	//explosion counters
	
	output reg planet_collision = 1'd0;
	//output to the enemy planet - whether or not we just colliding with the enemy planet
	
	output reg frame = 1'b0;
	//toggles between 1 and 0 to draw the different frames for a simple animation
	
	output reg [7:0]earth_defense_counter;
	//projectile counter for earth defense 
	
	/***************************************************************
								LOCAL SIGNALS
	***************************************************************/
	wire hitUp, hitDown;
	wire move_up, move_down;
	
	reg[9:0] frame_counter = 10'b0;
	
	wire[9:0] planet_x_coordinate;
	
	wire[9:0] projectile_start_x; 
	
	reg reg_b = 1'b0, reg_a=1'b0;
	//stores the previous value from the btn_b and btn_a, respectively
	
	reg [4:0]projectile_cooldown_counter;
	//used to limit projectile spam
	
	wire[9:0]VELOCITY;
	//used to control attack projectile velocity 
	
	reg [1:0]game_state_previous;
	//used to posedge the gamestate

	/***************************************************************
								PARAMETERS
	***************************************************************/
	
	parameter [9:0] LEFT_SHIP_X=10'd50, RIGHT_SHIP_X=10'd255;
	//static x values
	
	parameter [9:0] SHIP_HEIGHT = 10'd20;
	
	parameter [9:0] SHIP_VELOCITY = 10'd8, PROJECTILE_VELOCITY = 10'd4, FASTER_PROJECTILE_VELOCITY = 10'd6, OFFSET = 10'd6, PROJECTILE_OFFSET_X = 10'd17, PROJECTILE_OFFSET_Y = 10'd5, DEF_PROJECTILE_OFFSET_Y = 10'd9, RIGHT_PLANET_X = 10'd270, LEFT_PLANET_X = 10'd35;
	//chosen after careful consideration (looks nice). Actual planet x coordinates are 285 and 35, these coordinates chosen to have correct parts of projectiles colliding
	// if we want to move forward or backwards eventually, have the offset set to 16 and then do stuff
	parameter [9:0] YMAX = 10'd240;
	//for 320x240 resolution
	
	parameter [9:0] FRAME_COUNTER_MAX = 10'd5;
	//change this to speed up or slow down the ship animation
	
	parameter[3:0] INIT = 4'b0000, WAIT = 4'b0001 , DRAW_BACKGROUND = 4'b0010, DRAW_PLANET_LEFT=4'b0011, DRAW_PLANET_RIGHT=4'b0100,
		DRAW_SHIP_LEFT=4'b0101, DRAW_SHIP_RIGHT = 4'b0110 , DRAW_ATK_PROJ_RIGHT=4'b0111, DRAW_DEF_PROJ_RIGHT = 4'b1000 , DRAW_ATK_PROJ_LEFT=4'b1001, DRAW_DEF_PROJ_LEFT=4'b1010,
		UPDATE_GAME_STATE=4'b1111;
	//draw state parameters
	
	parameter[1:0] MENU= 2'b00, PLAY = 2'b01, GAMEOVER_VICTORY_RIGHT = 2'b10 , GAMEOVER_VICTORY_LEFT = 2'b11;
	//game state parameters
	
	/***************************************************************
						PROJECTILE AND MOVEMENT LOGIC
	***************************************************************/
	assign hitDown = ((y_pos + SHIP_HEIGHT + OFFSET) >= YMAX)?1'b1: 1'b0;
	assign hitUp = ((y_pos) <= OFFSET)?1'b1: 1'b0;
	//check if we have hit the wall
	
	assign move_up = btn_up && !btn_down && !hitUp;
	assign move_down = btn_down && !btn_up && !hitDown;
	//controls when we are moving
	
	assign planet_x_coordinate = (is_left_ship)? RIGHT_PLANET_X : LEFT_PLANET_X;
	// used to check when a projectile has hit the appropriate planet 
	
	assign projectile_start_x = (is_left_ship)? (x_pos + PROJECTILE_OFFSET_X):(x_pos - PROJECTILE_OFFSET_X);
	
	assign VELOCITY =(faster_proj)?FASTER_PROJECTILE_VELOCITY : PROJECTILE_VELOCITY; // MADE A CHANGE HERE 
	
	/***************************************************************
								MOVEMENT AND REGISTERS
	***************************************************************/
	
	always@(posedge clock_50) begin
		planet_collision <= 1'b0; //reset planet collision wire on the 50MHz clock
				
				
		/***************************************************************
									GAME MODE VARIABLES
		***************************************************************/
			game_state_previous<=game_state;
			if(~defense_counter_resetn || !earth_defense ||(game_state_previous != PLAY   && game_state == PLAY )) earth_defense_counter <= 8'b0;

					
		/***************************************************************
						ERASING PROJECTILES AT THE END OF A GAME
		***************************************************************/
		if((game_state == GAMEOVER_VICTORY_RIGHT)||(game_state == GAMEOVER_VICTORY_LEFT))begin
			atk_1exist<= 1'b0;
			atk_2exist<= 1'b0;
			atk_3exist<= 1'b0;
			atk_4exist<= 1'b0;
			def_exist <= 1'b0;
			
			atk_1explode<=3'b0;
			atk_2explode<=3'b0;
			atk_3explode<=3'b0;
			atk_4explode<=3'b0;
		end
		
		if (draw_state == UPDATE_GAME_STATE) begin
			destroy_enemy_def <=1'b0; //reset projectile collision wire on the ~60Hz clock
		
			/***************************************************************
										SHIP POSITION
			***************************************************************/
			/*** X POSITION ***/
			if (is_left_ship) x_pos <= LEFT_SHIP_X;
			else x_pos <= RIGHT_SHIP_X;
			
			/*** Y POSITION ***/
			if (move_up) y_pos <= y_pos - SHIP_VELOCITY;
			if (move_down) y_pos <= y_pos + SHIP_VELOCITY;
			//top of the screen is y=0, so subtract from y_pos to move up
			
			/***************************************************************
								PROJECTILE GENERATION
			***************************************************************/
			if(projectile_cooldown_counter > 5'b0)
				if(no_cooldown) projectile_cooldown_counter <= 5'b0;
				else if(lower_cooldown) projectile_cooldown_counter <= projectile_cooldown_counter+ 5'd2; // should half the cooldown time 
				else projectile_cooldown_counter <= projectile_cooldown_counter+ 5'b1;
			//counts projectile delay of ~ 1s
			
			reg_b <= btn_b;
			if (!reg_b && btn_b && (projectile_cooldown_counter == 5'b0) && !(( !is_left_ship )&&( earth_defense))) begin
				//b was just changed 
				if(!atk_1exist && atk_1explode==3'b0)begin
					projectile_cooldown_counter<= 5'd2;
					atk_1exist<= 1'b1;
					atk_1x<= projectile_start_x;
					atk_1y<=y_pos + PROJECTILE_OFFSET_Y;
				end
				else if(!atk_2exist && atk_2explode==3'b0)begin
					projectile_cooldown_counter<= 5'd2;
					atk_2exist<= 1'b1;
					atk_2x<= projectile_start_x;
					atk_2y<=y_pos + PROJECTILE_OFFSET_Y;
				end
				else if(!atk_3exist && atk_3explode==3'b0)begin
					projectile_cooldown_counter<= 5'd2;
					atk_3exist<= 1'b1;
					atk_3x<= projectile_start_x;
					atk_3y<=y_pos + PROJECTILE_OFFSET_Y;
				end
				else if(!atk_4exist && atk_4explode==3'b0)begin
					projectile_cooldown_counter<= 5'd2;
					atk_4exist<= 1'b1;
					atk_4x<= projectile_start_x;
					atk_4y<=y_pos + PROJECTILE_OFFSET_Y;
				end
			end
			
			// attack projectile starts to exist when button B is pressed, and starts at position relativet to spaceship
			
			reg_a<=btn_a;
			if (!reg_a && btn_a && !((is_left_ship )&&( earth_defense))) begin 
				//a was just pressed
				if(!def_exist)begin
					def_exist <= 1'b1;
					def_x <= projectile_start_x;
					def_y<=y_pos + DEF_PROJECTILE_OFFSET_Y;
				end
			end
			/***************************************************************
							  ATTACK AND DEFENCE PROJECTILE COLlISION
			***************************************************************/			
			
			if(atk_1exist && enemy_def_exist)begin
					if(  (((atk_1x<=enemy_def_x)&&( (atk_1x + 10'd15)>=enemy_def_x)) ||  ((((atk_1x + 10'd15 ) >= enemy_def_x)&&( (atk_1x)<=enemy_def_x + 10'd15))))
						&&
					  (  ((((atk_1y) <=  (enemy_def_y + 10'd9))&&((atk_1y + 10'd9)>= (enemy_def_y + 10'd3) )))|| ((((atk_1y) <= enemy_def_y)&&((atk_1y + 10'd9)>=enemy_def_y))))         
					  )begin  // this fucking thing is collision detection
						
						atk_1exist <= 1'b0;
						destroy_enemy_def <= 1'b1;
						atk_1explode<=3'b1; //explosion
							
					  end
			end
				
				
		   if(atk_2exist && enemy_def_exist)begin
					if(  (((atk_2x<=enemy_def_x)&&( (atk_2x + 10'd15)>=enemy_def_x)) ||  ((((atk_2x + 10'd15 ) >= enemy_def_x)&&( (atk_2x)<=enemy_def_x + 10'd15))))
						&&
					  (  ((((atk_2y) <=  (enemy_def_y + 10'd9))&&((atk_2y + 10'd9)>= (enemy_def_y + 10'd3) )))|| ((((atk_2y) <= enemy_def_y)&&((atk_2y + 10'd9)>=enemy_def_y))))         
					  )begin 
						
						atk_2exist <= 1'b0;
						destroy_enemy_def <= 1'b1;
						atk_2explode<=3'b1; //explosion
						
					end
			end
				
		   if(atk_3exist && enemy_def_exist)begin
					if(  (((atk_3x<=enemy_def_x)&&( (atk_3x + 10'd15)>=enemy_def_x)) ||  ((((atk_3x + 10'd15 ) >= enemy_def_x)&&( (atk_3x)<=enemy_def_x + 10'd15))))
						&&
					  (  ((((atk_3y) <=  (enemy_def_y + 10'd9))&&((atk_3y + 10'd9)>= (enemy_def_y + 10'd3) )))|| ((((atk_3y) <= enemy_def_y)&&((atk_3y + 10'd9)>=enemy_def_y))))         
					  )begin 
						
						atk_3exist <= 1'b0;
						destroy_enemy_def <= 1'b1;
						atk_3explode<=3'b1; //explosion
						
					  end
			end
				
				
		   if(atk_4exist && enemy_def_exist)begin
					if(  (((atk_4x<=enemy_def_x)&&( (atk_4x + 10'd15)>=enemy_def_x)) ||  ((((atk_4x + 10'd15 ) >= enemy_def_x)&&( (atk_4x)<=enemy_def_x + 10'd15))))
						&&
					  (  ((((atk_4y) <=  (enemy_def_y + 10'd9))&&((atk_4y + 10'd9)>= (enemy_def_y + 10'd3) )))|| ((((atk_4y) <= enemy_def_y)&&((atk_4y + 10'd9)>=enemy_def_y))))         
					  )begin 
						
						atk_4exist <= 1'b0;
						destroy_enemy_def <= 1'b1;
						atk_4explode<=3'b1; //explosion
							
					  end
			end
				
			/*** explosion timers ***/
			if (atk_1explode!=3'b0) atk_1explode <= atk_1explode + 1'b1;
			if (atk_2explode!=3'b0) atk_2explode <= atk_2explode + 1'b1;
			if (atk_3explode!=3'b0) atk_3explode <= atk_3explode + 1'b1;
			if (atk_4explode!=3'b0) atk_4explode <= atk_4explode + 1'b1;
			
			/***************************************************************
										PROJECTILE POSITION
			***************************************************************/
			
			
			if(atk_1exist)begin 
				if (is_left_ship) atk_1x<=atk_1x + VELOCITY; // should potentially change to some other velocity
				else atk_1x<=atk_1x - VELOCITY;
				
				if(( is_left_ship && atk_1x >= planet_x_coordinate) || (!is_left_ship && atk_1x <= planet_x_coordinate) )begin // may need to optimise this for both planets 
					atk_1exist <= 1'b0;
					atk_1explode<=3'b1; //explosion
					planet_collision <= 1'b1;
				end
			end
			
			if(atk_2exist)begin 
				if (is_left_ship) atk_2x<=atk_2x + VELOCITY; // should potentially change to some other velocity
				else atk_2x<=atk_2x - VELOCITY;
				
				if(( is_left_ship && atk_2x >= planet_x_coordinate) || (!is_left_ship && atk_2x <= planet_x_coordinate) )begin // may need to optimise this for both planets 
					atk_2exist <= 1'b0;
					atk_2explode<=3'b1; //explosion
					planet_collision <= 1'b1;
				end
			end
			
			if(atk_3exist)begin 
				if (is_left_ship) atk_3x<=atk_3x + VELOCITY; // should potentially change to some other velocity
				else atk_3x<=atk_3x - VELOCITY;
				
				if(( is_left_ship && atk_3x >= planet_x_coordinate) || (!is_left_ship && atk_3x <= planet_x_coordinate) )begin // may need to optimise this for both planets 
					atk_3exist <= 1'b0;
					atk_3explode<=3'b1; //explosion
					planet_collision <= 1'b1;
				end
			end
			
			if(atk_4exist)begin 
				if (is_left_ship) atk_4x<=atk_4x + VELOCITY; // should potentially change to some other velocity
				else atk_4x<=atk_4x - VELOCITY;
				
				if(( is_left_ship && atk_4x >= planet_x_coordinate) || (!is_left_ship && atk_4x <= planet_x_coordinate) )begin // may need to optimise this for both planets 
					atk_4exist <= 1'b0;
					atk_4explode<=3'b1; //explosion
					planet_collision <= 1'b1;
				end
			end
			
			//if the attack projectile has collided with the oposite planet, set exist to 0. Otherwise, increment X
		
			if(def_exist)begin 
				if (is_left_ship) def_x<=def_x + SHIP_VELOCITY; // should potentially change to some other velocity
				else def_x<=def_x - SHIP_VELOCITY;
				
				if(( is_left_ship && def_x >= planet_x_coordinate) || (!is_left_ship && def_x <= planet_x_coordinate) )begin // may need to optimise this for both planets 
					def_exist <= 1'b0;
					def_x<=10'b0;
					def_y<=10'b0;
				end
				else if(def_collision)begin // hit enemy projectile
					
					if(earth_defense_counter < 8'd99) earth_defense_counter<= earth_defense_counter + 1'b1;
					
					//increments the defence counter every time a defense projectile hits an offence projectile. and sets to zero if not in earth defence  
					
					/*** Comment out the following 3 lines to have defense projectiles go through attack projectiles (i.e. instead of both being destroyed) ***/
					if(!piercing_projectile)begin // makes it so that defense projectiles peirce straight thhrough attack bombs
						def_exist <= 1'b0;
						def_x<=10'b0;
						def_y<=10'b0;
					end
				end
			end
			
			
			/***************************************************************
										CHANGING FRAME
			***************************************************************/
			if (frame_counter == FRAME_COUNTER_MAX) begin
				frame <= frame ? 1'b0 : 1'b1; //toggle frame
				frame_counter <= 10'b0;
			end
			else frame_counter <= frame_counter + 2'b01;
			
		end
	end
	
endmodule


/***************************************************************
						PLANET STATUS
________________________________________________________________
-controls the status of the planets
***************************************************************/
module planet_status(clock, planet_hit, game_state, status, War);
	/***************************************************************
							DEFINING INPUTS AND OUTPUTS
	***************************************************************/
	input clock;
	//50MHz clock for registers
	
	input planet_hit;
	//1 if the planet was just hit
	
	input [1:0] game_state;
	//current game state
	
	input War;
	// war gamemode 
	
	output reg [1:0] status;
	//the status of the planet
	
	reg[5:0] war_counter;
	//counter for war mod  health
	
	/***************************************************************
							PARAMETERS
	***************************************************************/
	parameter[1:0] MENU= 2'b00, PLAY = 2'b01, GAMEOVER_VICTORY_RIGHT = 2'b10 , GAMEOVER_VICTORY_LEFT = 2'b11 ;	
	//game states
	
	parameter[1:0] SHIELD = 2'b00, NO_SHIELD = 2'b01, DAMAGED = 2'b10, DEAD = 2'b11;
	//planet state
	
	/***************************************************************
							PLANET STATUS LOGIC
	***************************************************************/
	
	always@(posedge clock) begin
		if (game_state != PLAY) begin
			status <= SHIELD;
			war_counter<=6'd20;
			//reset the status
		end
		else if (status!=DEAD && planet_hit) begin
		
			if(War)
			begin
					if(war_counter>6'd0)
						war_counter <= war_counter - 6'd1;
						
					if((war_counter > 6'd10))
						status <= SHIELD;
					else if((war_counter > 6'd5))
						status <= NO_SHIELD;
					else if((war_counter > 6'd0))
						status <= DAMAGED;
					else begin
						status<=DEAD;
					end	
				
			end
			
			else begin 
				status <= status + 1'b1;
				//increase the damage by one
			end
		end 	
		
		/*else begin // commented code starts here (original code)
			if (planet_hit && status != DEAD) begin
				status <= status + 1'b1;
				//increase the damage by one
			end
		end*/
		
		
		
	end

endmodule


/***************************************************************
						GAMESTATE FSM
________________________________________________________________
-controls the game state
***************************************************************/
module gamestate_fsm(clock_50M, left_planet_status, right_planet_status, st1, st2, game_state, score_resetn, earth_score_counter, mars_score_counter, earth_defense);
	/***************************************************************
							DEFINING INPUTS AND OUTPUTS
	***************************************************************/
	input clock_50M; //50MHz clock
	input [1:0] left_planet_status, right_planet_status; //status of the left and right planets
	input st1, st2; //user input on the 'start' buttons
	input score_resetn; //resets the score counters
	input earth_defense;
	output [1:0] game_state;
	//current game state
	
	output reg[7:0] earth_score_counter = 8'b0;
	output reg[7:0] mars_score_counter = 8'b0;
	//score counters
	
	/***************************************************************
							DEFINING LOCAL SIGNALS
	***************************************************************/
	parameter[1:0] MENU= 2'b00, PLAY = 2'b01, GAMEOVER_VICTORY_RIGHT = 2'b10 , GAMEOVER_VICTORY_LEFT = 2'b11 ;	
	//game states
	
	parameter[1:0] SHIELD = 2'b00, NO_SHIELD = 2'b01, DAMAGED = 2'b10, DEAD = 2'b11;
	//planet state
	
	parameter[7:0] MAX_SCORE_COUNT = 8'd99;
	//maximum possible score 
	
	reg [1:0]y_curr = MENU;
	reg [1:0] Y_next = MENU;
	//current and next states
	
	/***************************************************************
							STATE TABLE
	***************************************************************/
	always@(*) begin
		case (y_curr)
			MENU: begin //if both players press start, play. Else, stay in current state
				if (st2 || st1) Y_next = PLAY;
				else Y_next = MENU;
			end
			
			PLAY: begin
				if (left_planet_status == DEAD) Y_next = GAMEOVER_VICTORY_RIGHT;
				//the left planet is dead, so the right player won
				
				else if (right_planet_status == DEAD) Y_next = GAMEOVER_VICTORY_LEFT;
				//the right planet is dead, so the left player won
				
				else Y_next = PLAY;
				//no winner yet, so keep playing
			end
			
			GAMEOVER_VICTORY_LEFT: begin //if both players press start, play. Else, stay in current state
				if (st2 || st1) Y_next = PLAY;
				else Y_next = GAMEOVER_VICTORY_LEFT;
			end
			
			GAMEOVER_VICTORY_RIGHT: begin //if both players press start, play. Else, stay in current state
				if (st2 || st1) Y_next = PLAY;
				else Y_next = GAMEOVER_VICTORY_RIGHT;
			end
		endcase
	end
	
	/***************************************************************
							STATE REGISTERS
	***************************************************************/
	always@(posedge clock_50M)begin
			y_curr<= Y_next; 
	end
	
	/***************************************************************
							ASSIGN OUTPUTS
	***************************************************************/
	assign game_state = y_curr;
	
	
	
		
	/***************************************************************
								SCORE COUNTER
	***************************************************************/
	
	always@(posedge clock_50M)begin
	
		if(~score_resetn || earth_defense)begin // if game mode changes also reset, when we get there
			earth_score_counter <= 8'b0;
			mars_score_counter <=8'b0;
		end
		
		if((Y_next == GAMEOVER_VICTORY_LEFT)&&(y_curr == PLAY))begin
			if(mars_score_counter<MAX_SCORE_COUNT)
				mars_score_counter <= mars_score_counter + 1'b1; 
		end
		if((Y_next == GAMEOVER_VICTORY_RIGHT)&&(y_curr == PLAY))begin
			if(earth_score_counter<MAX_SCORE_COUNT)
				earth_score_counter <= earth_score_counter + 1'b1; 
		end
	end
	
	
	
endmodule


/***************************************************************
						DRAW FSM
________________________________________________________________
-controls the draw state
***************************************************************/
module draw_fsm(clock_50M , draw_en , game_clock , draw_state , gameState , doneDrawing);
	/***************************************************************
							DEFINING INPUTS AND OUTPUTS
	***************************************************************/
	output [3:0]draw_state;
	
	input clock_50M , game_clock; 
	input draw_en;
	input doneDrawing;
	input[1:0] gameState;
	
	/***************************************************************
							DEFINING LOCAL SIGNALS
	***************************************************************/
	parameter[3:0] INIT = 4'b0000, WAIT = 4'b0001 , DRAW_BACKGROUND = 4'b0010, DRAW_PLANET_LEFT=4'b0011, DRAW_PLANET_RIGHT=4'b0100,
		DRAW_SHIP_LEFT=4'b0101, DRAW_SHIP_RIGHT = 4'b0110 , DRAW_ATK_PROJ_RIGHT=4'b0111, DRAW_DEF_PROJ_RIGHT = 4'b1000 , DRAW_ATK_PROJ_LEFT=4'b1001, DRAW_DEF_PROJ_LEFT=4'b1010,
		UPDATE_GAME_STATE=4'b1111;
	//draw states
	
	parameter[1:0] MENU= 2'b00, PLAY = 2'b01, GAMEOVER_VICTORY_RIGHT = 2'b10 , GAMEOVER_VICTORY_LEFT = 2'b11 ; 
	//game states
	
	reg [3:0]y_curr = INIT;
	reg [3:0] Y_next = INIT;
	//current and next states (initialize to INIT)
		
	/***************************************************************
							STATE TABLE
	***************************************************************/
	always@(*)begin
	
		case(y_curr)
		INIT:begin
			/*
				The game starts at init (just showing the menu).
				When the gamestate switches to PLAY, go to WAIT (so that we draw the game screen at the next possible time).
			*/
			if(gameState == PLAY)Y_next = WAIT;
			else Y_next = INIT;
		end
		
		WAIT:begin
			/*
				Wait until the draw_en signal is one, then begin drawing.
			*/
			if(draw_en)Y_next = DRAW_BACKGROUND;
			else Y_next = WAIT;
		end
		
		DRAW_BACKGROUND:begin
			/*
				Remain in this state until doneDrawing is 1 (signals that the background has been drawn).
				Then, go to the next state.
					-if we are in the PLAY state, we have more things to draw, so go to the next thing (planets)
					-else, we must be in a GAMEOVER state, and we have nothing left to draw (go back to WAIT)
			*/
			if(doneDrawing)begin
					if(gameState == PLAY)Y_next = DRAW_PLANET_LEFT;
					else Y_next = WAIT;
			end 
			else
				 Y_next = DRAW_BACKGROUND;
		end
		
		
		DRAW_PLANET_LEFT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				 Y_next = DRAW_PLANET_RIGHT;
			else
				 Y_next = DRAW_PLANET_LEFT;
		end
			
		DRAW_PLANET_RIGHT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				 Y_next = DRAW_SHIP_LEFT;
			else
				 Y_next = DRAW_PLANET_RIGHT;
		end
	
		DRAW_SHIP_LEFT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				 Y_next = DRAW_SHIP_RIGHT;
			else
				 Y_next = DRAW_SHIP_LEFT;
		end
	
		DRAW_SHIP_RIGHT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				 Y_next = DRAW_ATK_PROJ_RIGHT;
			else
				 Y_next = DRAW_SHIP_RIGHT;
		end
	
		DRAW_ATK_PROJ_RIGHT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				Y_next = DRAW_DEF_PROJ_RIGHT;
			else
				Y_next = DRAW_ATK_PROJ_RIGHT;
		end
	
	
		DRAW_DEF_PROJ_RIGHT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				 Y_next = DRAW_ATK_PROJ_LEFT;
			else
				 Y_next = DRAW_DEF_PROJ_RIGHT;
		end
		
		DRAW_ATK_PROJ_LEFT:begin
			/*
				Remain in this state until doneDrawing is 1. Then draw the next thing.
			*/
			if(doneDrawing)
				Y_next = DRAW_DEF_PROJ_LEFT;
			else
				Y_next = DRAW_ATK_PROJ_LEFT;
		end
	
	
		DRAW_DEF_PROJ_LEFT:begin
			/*
				Remain in this state until doneDrawing is 1.
				If game_clock is 1, go to UPDATE_GAME_STATE (move entities, check victory conditions, etc.).
				Else go back to wait.
			*/
			if(doneDrawing) begin
				if (game_clock)
					Y_next = UPDATE_GAME_STATE;
				else
					Y_next = WAIT;
			 end
			else
				 Y_next = DRAW_DEF_PROJ_LEFT;
		end
	
	
		UPDATE_GAME_STATE:begin
			/*
				All done. Go back to wait.
			*/
			Y_next = WAIT;
		end
	
		default:begin
			Y_next = WAIT;
		end
	
		endcase	
	end 	
		
	/***************************************************************
							STATE REGISTERS
	***************************************************************/
	always@(posedge clock_50M)begin
			y_curr<= Y_next; 
	end
	
	/***************************************************************
							ASSIGN OUTPUTS
	***************************************************************/
	assign draw_state = y_curr;
		
endmodule

/***************************************************************
						DRAW DATAPATH
________________________________________________________________
-outputs a position in x,y and a colour to be drawn to the VGA
***************************************************************/
module draw_datapath(clock, draw_state , gameState, doneDrawing , x_pos , y_pos , plot , colour,
	ship1_x, ship1_y, ship2_x, ship2_y , 
	left_frame, right_frame,
	left_planet_status, right_planet_status,	
	left_attack1_x, left_attack1_y, left_attack1_exist, left_attack1_explode,
	left_attack2_x, left_attack2_y, left_attack2_exist, left_attack2_explode,
	left_attack3_x, left_attack3_y, left_attack3_exist, left_attack3_explode,
	left_attack4_x, left_attack4_y, left_attack4_exist, left_attack4_explode,
	left_def_x, left_def_y, left_def_exist,
	right_attack1_x, right_attack1_y, right_attack1_exist, right_attack1_explode,
	right_attack2_x, right_attack2_y, right_attack2_exist, right_attack2_explode,
	right_attack3_x, right_attack3_y, right_attack3_exist, right_attack3_explode,
	right_attack4_x, right_attack4_y, right_attack4_exist, right_attack4_explode,
	right_def_x, right_def_y, right_def_exist,
	);
//SHOULD HAVE MORE INPUTS COMING IN (e.g. planet status, planet frame, ship frame, more atk projectiles, more defense projectiles)
		/***************************************************************
								DEFINING INPUTS AND OUTPUTS
		***************************************************************/
		input clock;
		//50MHz clock for registers
		
		input[3:0] draw_state;
		input[1:0] gameState;
		//current states
		
		input[9:0] ship1_x, ship1_y;
		input[9:0] ship2_x, ship2_y;
		input[9:0] left_attack1_x , left_attack1_y;
		input[9:0] left_attack2_x , left_attack2_y;
		input[9:0] left_attack3_x , left_attack3_y;
		input[9:0] left_attack4_x , left_attack4_y;
		input[2:0] left_attack1_explode, left_attack2_explode, left_attack3_explode, left_attack4_explode;
		input[9:0] left_def_x , left_def_y;
		input[9:0] right_attack1_x , right_attack1_y;
		input[9:0] right_attack2_x , right_attack2_y;
		input[9:0] right_attack3_x , right_attack3_y;
		input[9:0] right_attack4_x , right_attack4_y;
		input[2:0] right_attack1_explode, right_attack2_explode, right_attack3_explode, right_attack4_explode;
		input[9:0] right_def_x , right_def_y;
		//incoming positions of various entities
		
		input left_attack1_exist, left_attack2_exist, left_attack3_exist, left_attack4_exist;
		input right_attack1_exist, right_attack2_exist, right_attack3_exist, right_attack4_exist;
		input left_def_exist, right_def_exist;

		//existence states of projectiles 
		
		
		output[9:0] x_pos , y_pos;
		output plot;
		output[8:0] colour;
		//outgoing information to vga
		
		output reg doneDrawing;
		//outgoing information to draw FSM
		//signals when we are done drawing a segment and should go to the next state
		
		input [1:0] left_planet_status, right_planet_status;
		//state of the planets
		
		input left_frame, right_frame;
		//which frame to draw (for animation)
		
		/***************************************************************
								DEFINING LOCAL SIGNALS
		***************************************************************/
		reg[18:0] address_counter = 18'b0; // max is 76,800 or 10010110000000000
		reg[9:0] x_counter = 9'b0; // max is 320 or 101101000
		reg[8:0] y_counter = 8'b0; // max is 240 or 11110000
		//counters for xy position and address (for drawing)
		
		reg count_en , count_reset ;
		//reset and enable for above counters
		
		reg drawShipLeft, drawShipRight , drawPlanetLeft, drawPlanetRight , drawBackground , drawAttackRight, drawAttackLeft, drawDefenseRight , drawDefenseLeft;		
		//used to select what is being drawn
		//only one should be high at a time
		
		reg drawBlack;
		//used to tell if we should draw black pixels to the screen or not
		//only background should draw black pixels to the screen
		
		reg regPlot;
		//whether or not the VGA should draw
		
		reg[9:0] regX, regY;
		reg[8:0] colourSelector; 
		//registers for position and colour
		
		reg[17:0] Max_Address = 18'b0; //used to tell when we are finished drawing the image
		reg[8:0] Max_X = 9'b0; 			 //used to tell when to go to the next row
		//these values are set for each image
		
		
		wire gnd;
		assign gnd = 1'b0;
		//logic 0
		
		wire[8:0] do_nothing_data;
		assign do_nothing_data = 9'b0;
		//empty wire
				
		
		/*** Colour wires for RAM blocks ***/
		
		wire[8:0] shipRight_pixel_colour_1, shipRight_pixel_colour_2, shipLeft_pixel_colour_1, shipLeft_pixel_colour_2;
		//colours for ships
		
		wire[8:0] planetRight_pixel_shield_colour_1, planetRight_pixel_shield_colour_2;
		wire[8:0] planetRight_pixel_no_shield_colour_1, planetRight_pixel_no_shield_colour_2;
		wire[8:0] planetRight_pixel_damaged_colour_1, planetRight_pixel_damaged_colour_2;
		//colours for right planet
		
		wire[8:0] planetLeft_pixel_shield_colour_1, planetLeft_pixel_shield_colour_2;
		wire[8:0] planetLeft_pixel_no_shield_colour_1, planetLeft_pixel_no_shield_colour_2;
		wire[8:0] planetLeft_pixel_damaged_colour_1, planetLeft_pixel_damaged_colour_2;
		//colours for left planet
		
		wire[8:0] attackRight_pixel_colour, attackLeft_pixel_colour;
		wire[8:0] defenseRight_pixel_colour, defenseLeft_pixel_colour;
		wire[8:0] explosion_pixel_colour, explosion_med_pixel_colour, explosion_small_pixel_colour;
		//colours for projectiles
		
		wire[8:0] backGround_pixel_colour;
		wire[8:0] game_over_victory_pixel_colour;
		//colours for background and game over
		
		
		reg[1:0] atk_draw_selector = 2'b0;
		reg drawing_atk_proj = 1'b0;
		//for drawing specifically the attack projectiles
		
		
		/*** PARAMETERS ***/
		
		parameter[3:0] INIT = 4'b0000, WAIT = 4'b0001 , DRAW_BACKGROUND = 4'b0010, DRAW_PLANET_LEFT=4'b0011, DRAW_PLANET_RIGHT=4'b0100,
		DRAW_SHIP_LEFT=4'b0101, DRAW_SHIP_RIGHT = 4'b0110 , DRAW_ATK_PROJ_RIGHT=4'b0111, DRAW_DEF_PROJ_RIGHT = 4'b1000 , DRAW_ATK_PROJ_LEFT=4'b1001, DRAW_DEF_PROJ_LEFT=4'b1010,
		UPDATE_GAME_STATE=4'b1111;
		//draw states
		
		parameter[1:0] MENU= 2'b00, PLAY = 2'b01, GAMEOVER_VICTORY_RIGHT = 2'b10 , GAMEOVER_VICTORY_LEFT = 2'b11 ; 
		//game states
		
		parameter[1:0] SHIELD = 2'b00, NO_SHIELD = 2'b01, DAMAGED = 2'b10, DEAD = 2'b11;
		//planet state

		
		
		// Gonna have to change these values depending on how our graphics look
		// need values for: background, gameover, planet, ship, atk proj, def proj
		
		parameter[17:0] BG_ADDRESS_MAX = 18'd76800 , GAMEOVER_ADDRESS_MAX = 18'd11250, PLANET_ADDRESS_MAX = 18'd8400 , SHIP_ADDRESS_MAX = 18'd300, ATTACK_ADDRESS_MAX = 18'd135 , DEFENSE_ADDRESS_MAX = 18'd45 ;
		
      parameter[8:0] BG_X_MAX = 9'd320 ,GAMEOVER_X_MAX = 9'd150, PLANET_X_MAX = 9'd35 , SHIP_X_MAX =9'd15, ATTACK_X_MAX = 9'd15 , DEFENSE_X_MAX = 9'd15;
		
		// These values just from how big the corresponding .mif file is

		parameter[8:0] VICTORY_BLUE = 9'b001001111, VICTORY_RED = 9'b111000000;
		//colors to draw (or not draw) on the victory screen
		
		
		/***************************************************************
							DEFINING RAM CELLS FOR IMAGES
		***************************************************************/
		
		/*** BACKGROUND AND GAME OVER RAM ***/
		background_ram bg_ram(
			.address(address_counter[16:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(backGround_pixel_colour)
		); 
		gameover_ram victory_ram(	.address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(game_over_victory_pixel_colour));
		
		/*** RIGHT SHIP RAM ***/
		ship_right_1 right_ship_1_ram(	.address(address_counter[8:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(shipRight_pixel_colour_1));
		ship_right_2 right_ship_2_ram(	.address(address_counter[8:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(shipRight_pixel_colour_2));
		
		/*** LEFT SHIP RAM ***/
		LeftShip_2 left_ship_1_ram(	.address(address_counter[8:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(shipLeft_pixel_colour_1));
		ShipLeft_2 left_ship_2_ram(	.address(address_counter[8:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(shipLeft_pixel_colour_2));
		
		
		/*** RIGHT PLANET RAM ***/
		blue_planet_shiel_1 right_shield_1(		 .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetRight_pixel_shield_colour_1	));
		blue_planet_shield_2 right_shield_2(	 .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetRight_pixel_shield_colour_2	));
		blue_planet_noshield_1 right_noshield_1(.address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetRight_pixel_no_shield_colour_1));
		blue_planet_noshield_2 right_noshield_2(.address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetRight_pixel_no_shield_colour_2));
		blue_planet_damaged_1 right_damaged_1(	 .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetRight_pixel_damaged_colour_1	));
		blue_planet_damaged_2 right_damaged_2(	 .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetRight_pixel_damaged_colour_2	));

		/*** LEFT PLANET RAM ***/
		PlanetLeft_shield_1 left_shield_1(	  .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetLeft_pixel_shield_colour_1	 ));
		PlanetLeft_shield_2 left_shield_2(	  .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetLeft_pixel_shield_colour_2	 ));
		PlanetLeft_noshield_1 left_noshield_1(.address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetLeft_pixel_no_shield_colour_1));
		PlanetLeft_noshield_2 left_noshield_2(.address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetLeft_pixel_no_shield_colour_2));
		PlanetLeft_damaged_1 left_damaged_1(  .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetLeft_pixel_damaged_colour_1  ));
		PlanetLeft_damaged_2 left_damaged_2(  .address(address_counter[13:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(planetLeft_pixel_damaged_colour_2	 ));
		
		/*** RIGHT PROJECTILE RAM ***/
		right_attack_projectile_ram right_atk_proj( .address(address_counter[7:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(attackRight_pixel_colour));
		right_defense_projectile_ram right_def_proj(.address(address_counter[5:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(defenseRight_pixel_colour));
		
		/*** LEFT PROJECTILE RAM ***/
		left_attack_projectile_ram left_atk_proj( .address(address_counter[7:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(attackLeft_pixel_colour));
		left_defense_projectile_ram left_def_proj(.address(address_counter[5:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(defenseLeft_pixel_colour));
		
		/*** EXPLOSION RAM ***/
		explosion explosion_ram(  		.address(address_counter[7:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(explosion_pixel_colour		));
		explosion_med_ram med_ram(		.address(address_counter[7:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(explosion_med_pixel_colour	));
		explosion_small_ram small_ram(.address(address_counter[7:0]), .clock(clock), .data(do_nothing_data), .wren(gnd), .q(explosion_small_pixel_colour));
				
		/***************************************************************
									SETTING FLAGS
		-potential source of error:
			-we set regPlot here, which goes straight to the VGA adapter
			-however, the other outputs are registers, and won't get updated until the next clock edge
			-I think this isn't a problem, as it would just draw whatever it had before, but I'm making a note here
		***************************************************************/		
		always@(*)begin
			count_en=1'b0;
			count_reset = 1'b0;
			drawShipLeft=1'b0; drawShipRight=1'b0;drawPlanetLeft=1'b0;drawPlanetRight=1'b0;
			drawBackground=1'b0; 
			drawAttackRight=1'b0; drawDefenseRight = 1'b0;
			drawAttackLeft=1'b0; drawDefenseLeft = 1'b0;
			drawBlack=1'b0;
			Max_Address = 18'b0;
			Max_X = 9'b0;
			drawing_atk_proj = 1'b0;
			//force to 0 to avoid latches
			
			
			case(draw_state)
				
				INIT: begin
					count_reset=1'b1;
				end
				
				WAIT:begin
					count_reset = 1'b1;
				end
				
				DRAW_BACKGROUND:begin
					count_en = 1'b1;
					drawBackground=1'b1;
					
					drawBlack = 1'b1;
					//this allows us to draw black to VGA
					//in other states, black is used to mark transparency, and so isn't drawn
					
					if (gameState == PLAY) begin
						Max_Address =  BG_ADDRESS_MAX;
						Max_X = BG_X_MAX;
						//draw the entire background image
					end
					else begin
						Max_Address = GAMEOVER_ADDRESS_MAX;
						Max_X = GAMEOVER_X_MAX;
						//draw a gameover overlay
					end
					
				end
			
				DRAW_PLANET_LEFT:begin
					count_en = 1'b1;
					drawPlanetLeft=1'b1;
					Max_Address = PLANET_ADDRESS_MAX;
					Max_X = PLANET_X_MAX;
				end
				
				DRAW_PLANET_RIGHT: begin 
					count_en = 1'b1;					
					drawPlanetRight=1'b1;
					Max_Address = PLANET_ADDRESS_MAX;
					Max_X = PLANET_X_MAX;
				end
				
				DRAW_SHIP_LEFT:begin
					count_en = 1'b1;
					drawShipLeft=1'b1;
					Max_Address = SHIP_ADDRESS_MAX;
					Max_X = SHIP_X_MAX;
				end
			
				DRAW_SHIP_RIGHT:begin
					count_en = 1'b1;
					drawShipRight = 1'b1;
					Max_Address = SHIP_ADDRESS_MAX;
					Max_X = SHIP_X_MAX;
				end
				
				DRAW_ATK_PROJ_RIGHT:begin
					count_en = 1'b1;
					drawAttackRight = 1'b1;
					Max_Address = ATTACK_ADDRESS_MAX;
					Max_X = ATTACK_X_MAX;
					drawing_atk_proj = 1'b1;
				end
				
				DRAW_DEF_PROJ_RIGHT: begin
					count_en = 1'b1;
					drawDefenseRight = 1'b1;
					Max_Address = DEFENSE_ADDRESS_MAX;
					Max_X = DEFENSE_X_MAX;
				end
				
				
				DRAW_ATK_PROJ_LEFT: begin
					count_en = 1'b1;
					drawAttackLeft = 1'b1;
					Max_Address = ATTACK_ADDRESS_MAX;
					Max_X = ATTACK_X_MAX;
					drawing_atk_proj = 1'b1;
				end
				
				DRAW_DEF_PROJ_LEFT: begin
					count_en = 1'b1;
					drawDefenseLeft = 1'b1;
					Max_Address = DEFENSE_ADDRESS_MAX;
					Max_X = DEFENSE_X_MAX;
				end
				
				UPDATE_GAME_STATE:begin
					count_reset = 1'b1;				
				end

				default:begin
					count_reset = 1'b1;
				end
				
			endcase
		end
		
		
		/***************************************************************
									REGISTERS AND LOGIC
		***************************************************************/	
		always@(posedge clock)begin
			doneDrawing<=1'b0;
			regPlot<=1'b0;
			//reset doneDrawing to 0
			//this is to make sure it isn't 1 for 2 clock cycles in a row (which could cause us to skip over a draw state)
						
			/***************************************************************
										DRAW COUNTER
			***************************************************************/
			/*** RESET ***/
			if(count_reset || doneDrawing)begin
				address_counter <= 18'b0;
				x_counter <= 9'b0;
				y_counter <= 8'b0;
				atk_draw_selector <= 2'b0;
			end
			/*** COUNTING ***/
			else if(count_en)begin		
				
				if(address_counter == Max_Address) begin //we have reached the end of the image
				
					if (drawing_atk_proj) begin
						//draw 4 attack projectiles
						atk_draw_selector <= atk_draw_selector + 2'b1;
						if (atk_draw_selector == 2'b11) doneDrawing <= 1'b1;
						else begin
							//reset
							address_counter <= 18'b0;
							x_counter<=9'b0;
							y_counter<=9'b0;
						end
					end
					else doneDrawing <= 1'b1; //we are all finished
				end
				else begin //normal counting (go to the next pixel)
										
					if (address_counter == 18'b0 && regPlot == 1'b1) begin
						//special code for loading the first pixel
						address_counter<=18'b0;
						regPlot<=1'b0;
					end
					else begin 
						address_counter<= address_counter + 1'b1;
						regPlot <= 1'b1;
					end
					
										
					if (address_counter > 18'b0) begin
						if(x_counter+1'b1 == Max_X)begin
							x_counter <= 9'b0;
							y_counter <= y_counter + 1'b1;
						end
						else x_counter<= x_counter + 1'b1;
					end
					
				end
			end
			
			/***************************************************************
									LOADING INITIAL X-Y POSITIONS
			-set regX and regY to the top-left corner of where the image should be
			***************************************************************/
			if (drawPlanetLeft) begin
				regX <= 10'b0;
				regY <= 10'b0;
			end
			
			if (drawPlanetRight) begin
				regX <= 10'd285;  // 35 PX from the right wall
				regY <= 10'b0;
			end
			
			if (drawShipLeft) begin
				regX <= ship1_x;
				regY <= ship1_y;
			end
			
			if (drawShipRight) begin
				regX <= ship2_x;
				regY <= ship2_y;
			end
			
			if (drawBackground) begin // in draw background we may also draw the game over screens, thats what this is
				if (gameState == PLAY) begin
					//for background image, start at top-left
					regX <= 10'd0;
					regY <= 10'd0;
				end
				else begin
					//center the victory overlay
					regX <= 10'd85; //150 px wide, screen is 320px
					regY <= 10'd82; //75  px tall, screen is 240px
				end
			end
			
			if (drawAttackRight) begin
				if (atk_draw_selector == 2'b00) begin
					regX <= right_attack1_x;
					regY <= right_attack1_y;
					if (!right_attack1_exist && right_attack1_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				if (atk_draw_selector == 2'b01) begin
					regX <= right_attack2_x;
					regY <= right_attack2_y;
					if (!right_attack2_exist && right_attack2_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				if (atk_draw_selector == 2'b10) begin
					regX <= right_attack3_x;
					regY <= right_attack3_y;
					if (!right_attack3_exist && right_attack3_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				if (atk_draw_selector == 2'b11) begin
					regX <= right_attack4_x;
					regY <= right_attack4_y;
					if (!right_attack4_exist && right_attack4_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				//selects a different x,y based on which attack projectile is being drawn
			end
			if (drawAttackLeft) begin
				if (atk_draw_selector == 2'b00) begin
					regX <= left_attack1_x;
					regY <= left_attack1_y;
					if (!left_attack1_exist && left_attack1_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				if (atk_draw_selector == 2'b01) begin
					regX <= left_attack2_x;
					regY <= left_attack2_y;
					if (!left_attack2_exist && left_attack2_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				if (atk_draw_selector == 2'b10) begin
					regX <= left_attack3_x;
					regY <= left_attack3_y;
					if (!left_attack3_exist && left_attack3_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				if (atk_draw_selector == 2'b11) begin
					regX <= left_attack4_x;
					regY <= left_attack4_y;
					if (!left_attack4_exist && left_attack4_explode==3'b0) regPlot <= 1'b0; //force to 0 if it doesn't exist
				end
				//selects a different x,y based on which attack projectile is being drawn
			end
			
			if (drawDefenseRight) begin
				regX <= right_def_x;
				regY <= right_def_y;
				if (!right_def_exist) regPlot <= 1'b0; //force to 0 if it doesn't exist
			end
			if (drawDefenseLeft) begin
				regX <= left_def_x;
				regY <= left_def_y;
				if (!left_def_exist) regPlot <= 1'b0; //force to 0 if it doesn't exist
			end
			
	end
	
	/***************************************************************
								LOADING COLOURS
	-set colourSelector to the appropriate colour value coming out of the RAM block
	-choose the colour wire based on the image to draw and possibly status and frame
	***************************************************************/
	always@(*) begin
			colourSelector = 9'b0; //prevent the latch
	
			if (drawPlanetLeft) begin
				if (left_planet_status == SHIELD) begin //shield planet
					if (left_frame)
						colourSelector = planetLeft_pixel_shield_colour_1;
					else
						colourSelector = planetLeft_pixel_shield_colour_2;
				end
				else if (left_planet_status == NO_SHIELD) begin //no shield
					if (left_frame)
						colourSelector = planetLeft_pixel_no_shield_colour_1;
					else
						colourSelector = planetLeft_pixel_no_shield_colour_2;
				end
				else begin //damaged
					if (left_frame)
						colourSelector = planetLeft_pixel_damaged_colour_1;
					else
						colourSelector = planetLeft_pixel_damaged_colour_2;
				end
			end
			
			if (drawPlanetRight) begin
				if (right_planet_status == SHIELD) begin //shield planet
					if (right_frame)
						colourSelector = planetRight_pixel_shield_colour_1;
					else
						colourSelector = planetRight_pixel_shield_colour_2;
				end
				else if (right_planet_status == NO_SHIELD) begin //no shield
					if (right_frame)
						colourSelector = planetRight_pixel_no_shield_colour_1;
					else
						colourSelector = planetRight_pixel_no_shield_colour_2;
				end
				else begin //damaged
					if (right_frame)
						colourSelector = planetRight_pixel_damaged_colour_1;
					else
						colourSelector = planetRight_pixel_damaged_colour_2;
				end
			end
			
			if (drawShipLeft) begin
				if (left_frame)
						colourSelector = shipLeft_pixel_colour_1;
					else
						colourSelector = shipLeft_pixel_colour_2;
			end
			
			if (drawShipRight) begin
				if (right_frame)
					colourSelector = shipRight_pixel_colour_1;
				else
					colourSelector = shipRight_pixel_colour_2;
			end
			
			if (drawBackground) begin // in draw background we may also draw the game over screens, thats what this is
				if (gameState == PLAY) begin
					colourSelector = backGround_pixel_colour;
				end
				else begin
					//different image based on who won
					if(gameState == GAMEOVER_VICTORY_LEFT) colourSelector = (game_over_victory_pixel_colour==VICTORY_BLUE) ? 9'b0 : game_over_victory_pixel_colour;
					if(gameState == GAMEOVER_VICTORY_RIGHT) colourSelector = (game_over_victory_pixel_colour==VICTORY_RED) ? 9'b0 : game_over_victory_pixel_colour;
				end
			end
			
			if (drawAttackRight) begin
				//draw projectile or explosion based on exist
				if (atk_draw_selector == 2'b00) begin
					if (right_attack1_exist) colourSelector = attackRight_pixel_colour;
					else begin
						if (right_attack1_explode == 3'd2 || right_attack1_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (right_attack1_explode == 3'd6 || right_attack1_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
				if (atk_draw_selector == 2'b01) begin
					if (right_attack2_exist) colourSelector = attackRight_pixel_colour;
					else begin
						if (right_attack2_explode == 3'd2 || right_attack2_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (right_attack2_explode == 3'd6 || right_attack2_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
				if (atk_draw_selector == 2'b10) begin
					if (right_attack3_exist) colourSelector = attackRight_pixel_colour;
					else begin
						if (right_attack3_explode == 3'd2 || right_attack3_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (right_attack3_explode == 3'd6 || right_attack3_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
				if (atk_draw_selector == 2'b11) begin
					if (right_attack4_exist) colourSelector = attackRight_pixel_colour;
					else begin
						if (right_attack4_explode == 3'd2 || right_attack4_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (right_attack4_explode == 3'd6 || right_attack4_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
			end
			if (drawAttackLeft) begin
				//draw projectile or explosion based on exist
				if (atk_draw_selector == 2'b00) begin
					if (left_attack1_exist) colourSelector = attackLeft_pixel_colour;
					else begin
						if (left_attack1_explode == 3'd2 || left_attack1_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (left_attack1_explode == 3'd6 || left_attack1_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
				if (atk_draw_selector == 2'b01) begin
					if (left_attack2_exist) colourSelector = attackLeft_pixel_colour;
					else begin
						if (left_attack2_explode == 3'd2 || left_attack2_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (left_attack2_explode == 3'd6 || left_attack2_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
				if (atk_draw_selector == 2'b10) begin
					if (left_attack3_exist) colourSelector = attackLeft_pixel_colour;
					else begin
						if (left_attack3_explode == 3'd2 || left_attack3_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (left_attack3_explode == 3'd6 || left_attack3_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
				if (atk_draw_selector == 2'b11) begin
					if (left_attack4_exist) colourSelector = attackLeft_pixel_colour;
					else begin
						if (left_attack4_explode == 3'd2 || left_attack4_explode == 3'd3)
							colourSelector = explosion_pixel_colour; //big explosion for frames 2 and 3
						if (left_attack4_explode == 3'd6 || left_attack4_explode == 3'd7)
							colourSelector = explosion_small_pixel_colour; //small explosion for frames 6, 7
						else
							colourSelector = explosion_med_pixel_colour; //medium explosion for frames 1,2 and 4,5
					end
				end
			end
			
			if (drawDefenseRight) begin
				colourSelector = defenseRight_pixel_colour;
			end
			if (drawDefenseLeft) begin
				colourSelector = defenseLeft_pixel_colour;
			end
	end

	/***************************************************************
								ASSIGNING OUTPUTS
	***************************************************************/
	assign colour = colourSelector;
	//where colourSelector is coming out of the appropriate RAM block
	
	assign x_pos = regX + x_counter;
	assign y_pos = regY + y_counter;	
	//initial position plus counter values
	
	assign plot = (colourSelector == 9'b0 && !drawBlack) ? 1'b0 : regPlot;
	//if the colour is black and we are NOT drawing black, force plot to 0
	//else just use regPlot
endmodule


/***************************************************************
						60 Hz Clock
________________________________________________________________
-takes in a 50MHz clock and outputs a 60 Hz clock
***************************************************************/
module timer_60hz(clock_50, enable);
	input clock_50;
	output reg enable;
	
	parameter [19:0] TICKS=20'd833333;
	reg [19:0] cnt = 20'b0;
	
	always@(posedge clock_50) begin
		if (cnt == TICKS) begin
			enable <= 1'b1;
			cnt<=20'b0;
		end
		else begin
			enable<=1'b0;
			cnt <= cnt+1'b1;
		end
	end
endmodule

/***************************************************************
						30 Hz Clock
________________________________________________________________
-takes in a 60 Hz clock and outputs a 30 Hz clock
***************************************************************/
module timer_30hz(clock_60hz, enable);
	input clock_60hz;
	output reg enable;
	
	parameter [3:0] TICKS = 4'd1;
	reg [3:0] cnt = 4'b0;
	
	always@(posedge clock_60hz) begin
		if (cnt >= TICKS) begin
			enable <= 1'b1;
			cnt<=4'b0;
		end
		else begin
			enable<=1'b0;
			cnt <= cnt+1'b1;
		end
	end
endmodule


/***************************************************************
	        Properly Functioning controller controls 
***************************************************************/

module get60HzClock(clock50MHz, clock60Hz);
	input clock50MHz;
	output reg clock60Hz;
	
	parameter [19:0] TICKS=20'd833333;
	reg [19:0] cnt = 20'b0;
	
	always@(posedge clock50MHz) begin
		if (cnt == TICKS) begin
			clock60Hz <= 1'b1;
			cnt<=20'b0;
		end
		else begin
			clock60Hz<=1'b0;
			cnt <= cnt+1;
		end
	end
endmodule

module get6usClock(clock50Mhz, clock6us);
	input clock50Mhz;
	output reg clock6us;
	
	parameter [8:0] TICKS=9'd300;
	reg [8:0] cnt = 9'd300;
	
	always@(posedge clock50Mhz) begin
		if (cnt == TICKS) begin
			clock6us <= 1'b1;
			cnt<=9'b0;
		end
		else begin
			clock6us<=1'b0;
			cnt <= cnt+1;
		end
	end
endmodule


module nes_fsm(clock, clock60hz, clock6us, latch, pulse, data, a,b,sel,st,up,down,left,right);
	input clock, clock60hz, clock6us;
	
	output latch, pulse;
	input data;
	
	output a,b,sel,st,up,down,left,right;
	
	parameter[2:0] WAIT=3'b000, LATCH=3'b001, LATCH2=3'b010, READ=3'b011, INCR=3'b100, PULSE_LOW=3'b101, PULSE_HIGH=3'b110;
	reg[2:0] y_curr=3'b0;
	reg[2:0] Y_next=3'b0;
	
	wire counter_is_done;
	
	always@(*) begin
		case(y_curr)
			WAIT: begin
				if (clock60hz) Y_next = LATCH;
				else Y_next = WAIT;
			end
			LATCH: begin
				if (clock6us) Y_next = LATCH2;
				else Y_next=LATCH;
			end
			LATCH2: begin
				if (clock6us) Y_next = READ;
				else Y_next = LATCH2;
			end
			READ: begin
				Y_next = INCR;
			end
			INCR: begin
				Y_next = PULSE_LOW;
			end
			PULSE_LOW: begin
				if (counter_is_done) Y_next = WAIT;
				else if (clock6us) Y_next = PULSE_HIGH;
				else Y_next = PULSE_LOW;
			end
			PULSE_HIGH: begin
				if (clock6us) Y_next = READ;
				else Y_next = PULSE_HIGH;
			end
			default: Y_next = WAIT;
		endcase
	end
	
	
	//state regs
	always@(posedge clock) begin
		y_curr <= Y_next;
	end
	
	nes_datapath nes_dp(y_curr, latch, pulse, data, counter_is_done, clock, a, b, sel, st, up, down, left, right);
	
endmodule

module nes_datapath(curr_state, latch, pulse, data, counter_is_done, clock,
	a, b, sel, st, up, down, left, right);
	
	output reg latch, pulse;
	input data;
	input[2:0] curr_state;
	input clock;
	
	output reg a,b,sel,st,up,down,left,right;
	output reg counter_is_done;
	
	parameter[2:0] WAIT=3'b000, LATCH=3'b001, LATCH2=3'b010, READ=3'b011, INCR=3'b100, PULSE_LOW=3'b101, PULSE_HIGH=3'b110;
	
	reg counter_reset, counter_en;
	reg [3:0] counter;
	reg ld_a, ld_b, ld_sel, ld_st, ld_up, ld_down, ld_left, ld_right;
	
	always@(*) begin
		ld_a = 1'b0; ld_b = 1'b0; ld_sel = 1'b0; ld_st = 1'b0; ld_up = 1'b0; ld_down = 1'b0; ld_left = 1'b0; ld_right = 1'b0; 
		latch = 1'b0; pulse = 1'b0;
		counter_reset = 1'b0; counter_en=1'b0;
		
		case(curr_state)
			WAIT:
				counter_reset = 1'b1;
			LATCH:
				latch=1'b1; //output latch high for 12us
			LATCH2:
				latch=1'b1;
			PULSE_HIGH:
				pulse=1'b1; //output pulse high for 6us
			INCR:
				counter_en=1'b1;
			READ: begin
				case(counter) //choose which value to read in
					4'b0000: ld_a = 1'b1;
					4'b0001: ld_b = 1'b1;
					4'b0010: ld_sel = 1'b1;
					4'b0011: ld_st = 1'b1;
					4'b0100: ld_up = 1'b1;
					4'b0101: ld_down = 1'b1;
					4'b0110: ld_left = 1'b1;
					4'b0111: ld_right = 1'b1;
					default: begin
					end
				endcase
			end
			default: begin
			end
		endcase
	end
	
	always@(posedge clock) begin
	
		//counter register
		if (counter_reset == 1'b1)
			counter <= 4'b0;
		else if (counter_en == 1'b1)
			counter <= counter + 1'b1;
		
		if (counter > 4'b1000) //read in 8 times, then go back to WAIT
			counter_is_done<=1'b1;
		else counter_is_done<=1'b0;
		
		//input registers
		if (ld_a) a <= ~data;
		if (ld_b) b <= ~data;
		if (ld_sel) sel <= ~data;
		if (ld_st) st <= ~data;
		if (ld_up) up <= ~data;
		if (ld_down) down <= ~data;
		if (ld_left) left <= ~data;
		if (ld_right) right <= ~data;
	end
	
endmodule



	/******************************************************
	//---------/ CODE FOR THE HEX DECODER /--------------//
	******************************************************/

module hex_decoder(hex_out, val);
	input [3:0] val;
   output [7:0] hex_out; 
	
	mux16to1 u0(1'b0,1,0,0,1,0,0,0,0,0,0,1,0,1,0,0,val[0],val[1],val[2],val[3],hex_out[0]);
	mux16to1 u1(1'b0,0,0,0,0,1,1,0,0,0,0,1,1,0,1,1,val[0],val[1],val[2],val[3],hex_out[1]);
	mux16to1 u2(1'b0,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1,val[0],val[1],val[2],val[3],hex_out[2]);
	mux16to1 u3(1'b0,1,0,0,1,0,0,1,0,1,1,0,0,0,0,1,val[0],val[1],val[2],val[3],hex_out[3]);
	mux16to1 u4(1'b0,1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,val[0],val[1],val[2],val[3],hex_out[4]);
	mux16to1 u5(1'b0,1,1,1,0,0,0,1,0,0,0,0,0,1,0,0,val[0],val[1],val[2],val[3],hex_out[5]);
	mux16to1 u6(1'b1,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,val[0],val[1],val[2],val[3],hex_out[6]);
	
endmodule

module mux16to1(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,s1,s2,s3,s4,out);
	input x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,s1,s2,s3,s4;
	output out;
	wire connect1, connect2;
	
	mux8to1 u0(
		.x1(x1), .x2(x2), .x3(x3), .x4(x4), .x5(x5), .x6(x6), .x7(x7), .x8(x8), .s1(s1), .s2(s2), .s3(s3), .out(connect1)
		);
	mux8to1 u1(
		.x1(x9), .x2(x10), .x3(x11), .x4(x12), .x5(x13), .x6(x14), .x7(x15), .x8(x16), .s1(s1), .s2(s2), .s3(s3), .out(connect2)
		);
	mux2to1 u2(
		.x(connect1),
		.y(connect2),
		.s(s4),
		.m(out)
		);
endmodule

module mux8to1(x1, x2, x3, x4, x5, x6, x7, x8, s1, s2, s3, out);
	input x1,x2,x3,x4,x5,x6,x7,x8,s1,s2,s3;
	output out;
	wire connect1, connect2;
	
	mux4to1 u0(
		.x1(x1),
		.x2(x2),
		.x3(x3),
		.x4(x4),
		.s1(s1),
		.s2(s2),
		.out(connect1)
		);
	mux4to1 u1(
		.x1(x5),
		.x2(x6),
		.x3(x7),
		.x4(x8),
		.s1(s1),
		.s2(s2),
		.out(connect2)
		);
	mux2to1 u2(
		.x(connect1),
		.y(connect2),
		.s(s3),
		.m(out)
		);
endmodule

module mux4to1(x1, x2, x3, x4, s1, s2, out);
    input x1,x2,x3,x4,s1,s2;
	 output out;
	 wire connect1, connect2;

    mux2to1 u0(
        .x(x1),
        .y(x2),
        .s(s1),
        .m(connect1)
        );
	  mux2to1 u1(
		  .x(x3),
		  .y(x4),
		  .s(s1),
		  .m(connect2)
		  );
	  mux2to1 u2(
	     .x(connect1),
		  .y(connect2),
		  .s(s2),
		  .m(out)
		  );
endmodule

module mux2to1(x, y, s, m);
    input x; //select 0
    input y; //select 1
    input s; //select signal
    output m; //output
  
    //assign m = s & y | ~s & x;
    // OR
    assign m = s ? y : x;

endmodule
	