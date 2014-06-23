module main(clk, reset, b1, b2, b3, b4, board_key0, speaker_out1, speaker_out2, led1, led2, led3, led4, board_led0, board_led1, board_led2, board_led3);
			
	input clk, reset, b1, b2, b3, b4, board_key0;
	output speaker_out1, speaker_out2, board_led0, board_led1, board_led2, board_led3;
	output reg led1, led2, led3, led4;

	/* ==================== INPUT SETUP ==================== */
	
	wire hax;
	assign hax = ~board_key0;
	
	wire [3:0] raw_bundle;
	assign raw_bundle[0] = b1;
	assign raw_bundle[1] = b2;
	assign raw_bundle[2] = b3;
	assign raw_bundle[3] = b4;
	
	wire [3:0] buttons;
	wire any_button_pressed;
	
	button_sync b_inst(clk, raw_bundle, any_button_pressed, buttons);
	
	
	/* ====================== COUNTERS ===================== */
	
	wire [4:0] max_sequence, cur_sequence, completed_sequences;
	wire reset_max_sequence, reset_cur_sequence, reset_completed_sequences;
	wire inc_max_sequence, inc_cur_sequence, inc_completed_sequences;
	
	wire [4:0] cur_speed;
	
	natural_counter max_sequence_counter(clk, inc_max_sequence,  reset_max_sequence, max_sequence);
	counter cur_sequence_counter(clk, inc_cur_sequence,  reset_cur_sequence, cur_sequence);
	counter completed_sequences_counter(clk, inc_completed_sequences,  reset_completed_sequences, completed_sequences);
	
	/* ==================== DELAY MODULES ================== */
	
	wire reset_var, reset_short, reset_round;
	wire var_delay, short_delay, round_delay;
	
	variable_delay delay_var(clk, reset_var, cur_speed, var_delay);
	variable_delay delay_short(clk, reset_short, 5'b11110, short_delay);
	variable_delay delay_round(clk, reset_round, 5'b01100, round_delay);
	
	/* ==================== SOUND MODULES ================== */
	
	reg [3:0] current_sound1, current_sound2;
	reg sound_on1, sound_on2;
	
	parameter SOUND_1 = 4'b0000;
	parameter SOUND_2 = 4'b0001;
	parameter SOUND_3 = 4'b0010;
	parameter SOUND_4 = 4'b0100;
	
	sound_controller sound_inst(clk, sound_on1, current_sound1, speaker_out1);
	sound_controller sound_inst2(clk, sound_on2, current_sound2, speaker_out2);
	
	
	/* ================== SEQUENCE GENERATOR =============== */
	
	wire randomize_seq, seq_next, seq_start_over;
	wire [3:0] seq_out;
	
	sequence_generator seq_inst(clk, randomize_seq, seq_next, seq_start_over, seq_out);
	
	/* ================= ANIMATION MODULES ================= */
	
	wire sa_next, sa_reset;
	
	wire [3:0] sa_sound;
	wire sa_light1, sa_light2, sa_light3, sa_light4;
	wire sa_done;
	
	round_win_anim sa_inst(clk, sa_next, sa_reset, sa_sound, sa_light1, sa_light2, sa_light3, sa_light4, sa_done);
	
	
	wire gw_next, gw_reset;
	
	wire [3:0] gw_sound1, gw_sound2;
	wire gw_light1, gw_light2, gw_light3, gw_light4;
	wire gw_done;
	
	game_win_anim gw_inst(clk, gw_next, gw_reset, gw_sound1, gw_sound2, gw_light1, gw_light2, gw_light3, gw_light4, gw_done);
	
	/* ==================== STATE STORAGE ================== */
	
	reg [31:0] state;
	reg [31:0] nState;
	
	
	/* ===================== STATE NAMES =================== */
	
	parameter ABSOLUTE_START_STATE = 32'd40;
	parameter RANDOMIZE = 32'd41;
	parameter START_OVER = 32'd42;
	parameter GENERATING = 32'd43;
	parameter RESET_DELAY_VAR = 32'd44;
	parameter SHOWING = 32'd45;
	parameter RESET_DELAY_SHORT = 32'd46;
	parameter WAIT_PAUSE = 32'd47;
	parameter SHOWING_COMPLETE = 32'd48;
	
	parameter START_OVER_INPUT = 32'd100;
	parameter GENERATING_INPUT = 32'd101;
	
	parameter ACCEPTING_INPUT = 32'd102;
		parameter RESET_INPUT_BUFFER_DOWN = 32'd103;
		parameter WAIT_INPUT_BUFFER_DOWN = 32'd104;
	
	parameter WAITING_BUTTON_UP = 32'd105;
		parameter RESET_INPUT_BUFFER_UP = 32'd106;
		parameter WAIT_INPUT_BUFFER_UP = 32'd107;
	
	parameter BUTTON_SUCCESSFUL = 32'd108;
	
	parameter GAME_OVER = 32'd200;
	parameter GAME_WIN = 32'd201;
	
	parameter ROUND_WIN = 32'd250;
	parameter ROUND_INCREMENT = 32'd251;	
	parameter ANIMATION_CHECK = 32'd252;
	
	parameter REGULAR_ANIMATION = 32'd300;
		parameter RA_RESET_DELAY = 32'd301;
		parameter RA_DO_ANIM = 32'd302;
	
	parameter SPECIAL_ANIMATION = 32'd350;
		parameter SA_RESET_MODULE = 32'd351;
		parameter SA_RESET_DELAY = 32'd352;
		parameter SA_NEXT = 32'd353;
		parameter SA_DO_ANIM = 32'd354;
		
	parameter GAME_WIN_ANIMATION = 32'd400;
		parameter GW_RESET_MODULE = 32'd401;
		parameter GW_RESET_DELAY = 32'd402;
		parameter GW_NEXT = 32'd403;
		parameter GW_DO_ANIM = 32'd404;
	
	initial begin
		state = ABSOLUTE_START_STATE;
	end
	
	always @ (posedge clk) begin
		
		state <= nState;
	
	end
	
	always @ (*) begin
		
		if(~reset)
		begin
		
			/* ================== STATE TRANSITION ================= */
		
			case (state)
				ABSOLUTE_START_STATE: nState = RANDOMIZE;
				RANDOMIZE: nState = START_OVER;
				START_OVER:nState = GENERATING;
				GENERATING: nState = RESET_DELAY_VAR;
				RESET_DELAY_VAR: nState = SHOWING;
				SHOWING: begin
					if (var_delay) begin
						if (cur_sequence >= max_sequence)
							nState = SHOWING_COMPLETE;
						else
							nState = RESET_DELAY_SHORT;
					end
					else
						nState = SHOWING;
				end
				RESET_DELAY_SHORT: nState = WAIT_PAUSE;
				WAIT_PAUSE: begin
					if (short_delay)
						nState = GENERATING;
					else
						nState = WAIT_PAUSE;
				end
				SHOWING_COMPLETE: nState = START_OVER_INPUT;
				START_OVER_INPUT: nState = GENERATING_INPUT;
				GENERATING_INPUT: nState = ACCEPTING_INPUT;
				ACCEPTING_INPUT: begin
					if (~any_button_pressed)
						if (cur_sequence >= max_sequence)
							if (max_sequence == 5'b11111)
								nState = GAME_WIN;
							else
								nState = ROUND_WIN;
						else
							// -----HAX------ to automatically win the game
							if (hax)
								nState = GAME_WIN;
							else
								nState = ACCEPTING_INPUT;
					else 
						if (buttons == seq_out)
							nState = RESET_INPUT_BUFFER_DOWN;
						else
							nState = GAME_OVER;
				end
				
				RESET_INPUT_BUFFER_DOWN: nState = WAIT_INPUT_BUFFER_DOWN;
				WAIT_INPUT_BUFFER_DOWN: begin
					if (short_delay)
						nState = WAITING_BUTTON_UP;
					else
						nState = WAIT_INPUT_BUFFER_DOWN;
				end
				WAITING_BUTTON_UP: begin
					if (any_button_pressed)
						nState = WAITING_BUTTON_UP;
					else
						nState = BUTTON_SUCCESSFUL;
				end
					
				BUTTON_SUCCESSFUL: nState = RESET_INPUT_BUFFER_UP;
				RESET_INPUT_BUFFER_UP: nState = WAIT_INPUT_BUFFER_UP;
				WAIT_INPUT_BUFFER_UP: begin
					if (short_delay)
						nState = GENERATING_INPUT;
					else
						nState = WAIT_INPUT_BUFFER_UP;
				end
				GAME_OVER: nState = GAME_OVER;
				GAME_WIN: nState = GAME_WIN_ANIMATION;
				ROUND_WIN: nState = ROUND_INCREMENT;
				ROUND_INCREMENT: nState = ANIMATION_CHECK;
				ANIMATION_CHECK: begin
					if (completed_sequences == 5'd5)
						nState = SPECIAL_ANIMATION;
					else
						nState = REGULAR_ANIMATION;
				end
				REGULAR_ANIMATION: nState = RA_RESET_DELAY;
				RA_RESET_DELAY: nState = RA_DO_ANIM;
				RA_DO_ANIM: begin
					if (round_delay)
						nState = START_OVER;
					else
						nState = RA_DO_ANIM;
				end
				SPECIAL_ANIMATION: nState = SA_RESET_MODULE;
				SA_RESET_MODULE: nState = SA_RESET_DELAY;
				SA_RESET_DELAY: nState = SA_NEXT;
				SA_NEXT: nState = SA_DO_ANIM;
				SA_DO_ANIM: begin
					if (short_delay)
						if (sa_done)
							nState = START_OVER;
						else
							nState = SA_RESET_DELAY;
					else
						nState = SA_DO_ANIM;
				end
				GAME_WIN_ANIMATION: nState = GW_RESET_MODULE;
				GW_RESET_MODULE: nState = GW_RESET_DELAY;
				GW_RESET_DELAY: nState = GW_NEXT;
				GW_NEXT: nState = GW_DO_ANIM;
				GW_DO_ANIM: begin
					if (round_delay)
						if (gw_done)
							nState = GAME_OVER;
						else
							nState = GW_RESET_DELAY;
					else
						nState = GW_DO_ANIM;
				end
				default: nState = ABSOLUTE_START_STATE;
			endcase
			
			/* ================ LIGHT AND SOUND OUTPUT ============= */
			
			case (state)
				SHOWING: begin
					sound_on1 = 1; sound_on2 = 0;
					current_sound2 = 4'b0000;
					case (seq_out)
						4'b0001: begin
							current_sound1 = SOUND_1;
							led1 = 1; led2 = 0; led3 = 0; led4 = 0;
						end
						4'b0010: begin
							current_sound1 = SOUND_2;
							led1 = 0; led2 = 1; led3 = 0; led4 = 0;
						end
						4'b0100: begin
							current_sound1 = SOUND_3;
							led1 = 0; led2 = 0; led3 = 1; led4 = 0;
						end
						4'b1000: begin
							current_sound1 = SOUND_4;
							led1 = 0; led2 = 0; led3 = 0; led4 = 1;
						end
						default: begin
							current_sound1 = SOUND_1;
							led1 = 0; led2 = 0; led3 = 0; led4 = 0;
						end
					endcase 
					
				end
				WAITING_BUTTON_UP: begin
					sound_on1 = 1; sound_on2 = 0;
					current_sound2 = 4'b0000;
					if (buttons[0])
						current_sound1 = 4'b0000;
					else if (buttons[1])
						current_sound1 = 4'b0001;
					else if (buttons[2])
						current_sound1 = 4'b0010;
					else if (buttons[3])
						current_sound1 = 4'b0100;
					else 
						current_sound1 = 4'b0000;
						
					led1 = buttons[0];
					led2 = buttons[1];
					led3 = buttons[2];
					led4 = buttons[3];
				end
				GAME_OVER, RA_DO_ANIM: begin
					sound_on1 = 0; sound_on2 = 0;
					current_sound1 = 4'b0000; current_sound2 = 4'b0000;
					led1 = 1; led2 = 1; led3 = 1; led4 = 1;
				end
				SA_DO_ANIM: begin
					sound_on1 = 1; sound_on2 = 0;
					current_sound1 = sa_sound; current_sound2 = 4'b0000;
					led1 = sa_light1; led2 = sa_light2; led3 = sa_light3; led4 = sa_light4;
				end
				GW_DO_ANIM: begin
					sound_on1 = 1; sound_on2 = 1;
					current_sound1 = gw_sound1; current_sound2 = gw_sound2;
					led1 = gw_light1; led2 = gw_light2; led3 = gw_light3; led4 = gw_light4;
				end
				default: begin
					sound_on1 = 0; sound_on2 = 0;
					current_sound1 = 4'b0000; current_sound2 = 4'b0000;
					led1 = 0; led2 = 0; led3 = 0; led4 = 0;
				end
			endcase
		end
		else begin
			nState = ABSOLUTE_START_STATE;
			sound_on1 = 0; sound_on2 = 0;
			current_sound1 = 4'b0000; current_sound2 = 4'b0000;
			led1 = 0; led2 = 0; led3 = 0; led4 = 0;
		end
	end
	
	/* ====== INTERNAL WIRES AND SUBMODULE CONNECTIONS ===== */
	
	// mostly resets, incrementers, and other commands that correspond to one or multiple states
	
	assign reset_var = (state == RESET_DELAY_VAR);
	assign reset_short = (state == RESET_DELAY_SHORT) | (state == RESET_INPUT_BUFFER_UP) | (state == RESET_INPUT_BUFFER_DOWN) | (state == SA_RESET_DELAY);
	assign reset_round = (state == RA_RESET_DELAY) | (state == GW_RESET_DELAY);
	
	
	assign randomize_seq = (state == RANDOMIZE);
	assign seq_next = (state == GENERATING) | (state == GENERATING_INPUT);
	assign seq_start_over = (state == START_OVER) | (state == START_OVER_INPUT);
	
	
	assign sa_next = (state == SA_NEXT);
	assign sa_reset = (state == SA_RESET_MODULE);

	assign gw_next = (state == GW_NEXT);
	assign gw_reset = (state == GW_RESET_MODULE);
	
	
	
	assign reset_max_sequence = (state == ABSOLUTE_START_STATE);
	assign reset_cur_sequence = (state == ABSOLUTE_START_STATE) | (state == START_OVER) | (state == SHOWING_COMPLETE);
	assign reset_completed_sequences = (state == ABSOLUTE_START_STATE) | (state == SPECIAL_ANIMATION);
	
	assign inc_max_sequence = (state == ROUND_INCREMENT);
	assign inc_cur_sequence = (state == GENERATING) | (state == BUTTON_SUCCESSFUL);
	assign inc_completed_sequences = (state == ROUND_INCREMENT);
	
	assign cur_speed = max_sequence - 5'b00001;
	
	assign board_led0 = cur_sequence[0];
	assign board_led1 = cur_sequence[1];
	assign board_led2 = cur_sequence[2];
	assign board_led3 = cur_sequence[3];
	
endmodule 