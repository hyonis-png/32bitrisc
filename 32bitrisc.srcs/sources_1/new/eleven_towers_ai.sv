`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2026 04:16:45 PM
// Design Name: 
// Module Name: eleven_towers_ai
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



      module team_1269580875 (
         input wire clk,
         input wire reset,
         // === Game Context ===
         input wire [2:0] num_players,              // Number of players in the game (2-5)
         input wire [2:0] my_player_index,          // Your player index (0-4)
         input wire [2:0] current_player,           // Index of current player (whose turn it is)
         input wire my_turn,                        // Asserted when it's your turn
         input wire [7:0] rolls_this_turn,          // Number of rolls taken this turn (valid when my_turn)
         // === Your Tower State ===
         input wire [3:0] tower_start_floor [12:2],    // Your locked-in floor on each tower
         input wire [3:0] tower_climb_floor [12:2],    // Your current turn floor on each tower (valid when my_turn)
         input wire [3:0] tower_height [12:2],         // Goal height to claim each tower
         input wire [3:0] turn_start_tower_floor [12:2],  // Your floor on each tower when this turn started
         input wire tower_climbing [12:2],             // Whether you've begun climbing this tower this turn
         input wire tower_claimed [12:2],              // Has any player claimed this tower?
         input wire [1:0] climbing_cnt,                // Number of towers you're currently climbing (max 3)
         input wire [2:0] claimed_cnt,                 // Number of towers you've claimed so far
         // === Pairing Options ===
         input wire [3:0] pairing_sum [2:0][1:0],      // Sum of dice for each pairing''s pairs
         // === Outputs ===
         output wire [15:0] pairing_score [2:0],       // Score for each of 3 pairings (higher is better)
         output wire [0:0] priority_pair [2:0],        // Which pair (0 or 1) gets priority for each pairing
         output wire end_turn                          // Assert to end turn voluntarily
      );

      // PROBABILITY CONSTANTS & RECOMENDED THRESHOLD
      localparam [8:0] roll_probabilities [12:2] = '{171, 302, 461, 580, 727, 834, 727, 580, 461, 302, 171};
      localparam [9:0] probability_threshold = 10'd1500;

      // TOWER DISTANCE CALCULATIONS
      logic [3:0] tower_distance [12:2];
      logic tower_completed [12:2];
      logic tower_one_away [12:2];
      logic tower_two_away [12:2];      
      // ELIGIBLE TOWER CALCULATIONS
      logic eligible_towers [12:2];                     // IF TOWER IS ELIGIBLE
      logic [3:0] eligible_stack [2:0];                 // HOLDS AVAILABLE TOWER NUMBERS
      logic [2:0] eligible_count;                       // NUMBER OF ELIGIBLE THIS TURN
      // SPECIFIC CASES TRACKING
      logic one_floor_away_pairing;                     // ONE FLOOR AWAY PAIR EXISTS
      logic [2:0] one_floor_away_pairing_index;         // PAIRING ORDER HAS A ONE AWAY
      
      // SCORING VARS
      logic [15:0] base_pairing_scores [2:0];
      
      // Calculate tower_distance related calculations
      always_comb begin
        integer i;
        for (i = 2; i <= 12; i = i + 1) begin
            tower_distance[i] = tower_height[i] - tower_climb_floor[i];
            tower_completed[i] = my_turn && (tower_distance[i] == 4'd0);
            tower_one_away[i] = my_turn && (tower_distance[i] == 4'd1);
            tower_two_away[i] = my_turn && (tower_distance[i] == 4'd2);
        end
      end
      
      // Checking each pairing to see any tower is one floor away from completion
      always_comb begin
         integer pn, pp;
         one_floor_away_pairing = 1'b0;
         one_floor_away_pairing_index = 3'd0;

         for (pn = 0; pn < 3; pn = pn + 1) begin
            for (pp = 0; pp < 2; pp = pp + 1) begin
               if (tower_distance[pairing_sum[pn][pp]] == 4'd1) begin
                   one_floor_away_pairing = 1'b1;
                   one_floor_away_pairing_index = pn;
               end
            end
         end
      end

      // ELIGIBLE TOWERS STACK
      always_comb begin
         integer tower;
         for (tower = 2; tower <= 12; tower = tower + 1) begin
            eligible_towers[tower] = !tower_claimed[tower] && 
                  !tower_completed[tower] && (tower_climbing[tower] || (climbing_cnt < 2'd3));
         end
      end
   
      // BEST_SUM CALCULATIONS
      logic [3:0] best_sum;
      logic [10:0] best_probability;
      logic best_pair;
      logic [1:0] best_pairing;
      logic [10:0] current_probability;

      always_comb begin
         integer p;
         best_probability = 11'd0;
         best_pairing = 2'd0;  
       
         for(p = 0; p < 3; p = p + 1) begin
            current_probability =
                roll_probabilities[pairing_sum[p][0]] +
                roll_probabilities[pairing_sum[p][1]];

            if(current_probability > best_probability) begin
                best_probability = current_probability;
                best_pairing = p;
            end
         end
      end

      // priority logic
      localparam [15:0] TIER_DOUBLE_FINISH = 16'd80000; // finish two towers
      localparam [15:0] TIER_FINISH_NOW    = 16'd60000; // distance==1
      localparam [15:0] TIER_CLIMB_TWICE   = 16'd40000; // climb a tower twice
      localparam [15:0] TIER_TWO_TOWERS    = 16'd20000; // two different towers
      localparam [15:0] TIER_ONE_TOWER     = 16'd10000; // one legal lower

      integer h;
      logic [9:0] added_probabilities [2:0];
      logic [3:0] sum0_, sum1_, dist0_, dist1_;
      logic elig0, elig1;
      // CONDITIONS
      logic double_finish, finish_now, climb_twice, two_towers;
      logic double_finish_towers [2:0], finish_now_towers [2:0], climb_twice_towers [2:0], two_eligible_towers [2:0], same_pair_towers [2:0];

      always_comb begin
         double_finish = 0;
         finish_now = 0;
         climb_twice = 0;
         two_towers = 0;
         for (h = 0; h < 3; h = h + 1) begin
            double_finish_towers[h] = 1'b0;
            finish_now_towers[h] = 1'b0;
            climb_twice_towers[h] = 1'b0;
            two_eligible_towers[h] = 1'b0;
            
            sum0_ = pairing_sum[h][0];
            sum1_ = pairing_sum[h][1];
            added_probabilities[h] = (roll_probabilities[sum0_] + roll_probabilities[sum1_]);
            dist0_ = tower_distance[sum0_];
            dist1_ = tower_distance[sum1_];
            elig0 = eligible_towers[sum0_];
            elig1 = eligible_towers[sum1_];
            two_eligible_towers[h] = (elig0 && elig1);
            same_pair_towers[h] = (sum0_ == sum1_);
            
            if (two_eligible_towers[h]) begin
               two_towers = 1'b1;
               if (!same_pair_towers[h] && dist0_ == 4'd1 && dist1_ == 4'd1) begin
                  double_finish = 1'b1;
                  double_finish_towers[h] = 1'b1;
                  base_pairing_scores[h] = TIER_DOUBLE_FINISH;
               end else if (!same_pair_towers[h] && (dist0_ == 4'd1 || dist1_ == 4'd1)) begin
                  finish_now = 1'b1;
                  finish_now_towers[h] = 1'b1;
                  base_pairing_scores[h] = TIER_FINISH_NOW;
               end else if (same_pair_towers[h] && dist0_ == 4'd2) begin
                  finish_now = 1'b1;
                  finish_now_towers[h] = 1'b1;
                  base_pairing_scores[h] = TIER_FINISH_NOW;
               end else if (same_pair_towers[h] && dist0_ != 4'd1) begin
                  climb_twice = 1'b1;
                  climb_twice_towers[h] = 1'b1;
                  base_pairing_scores[h] = TIER_CLIMB_TWICE;
               end else begin
                  base_pairing_scores[h] = TIER_TWO_TOWERS;
               end
            end else if (elig0 || elig1) begin
               if (dist0_ == 4'd1 || dist1_ == 4'd1) begin
                  finish_now = 1'b1;
                  finish_now_towers[h] = 1'b1;
                  base_pairing_scores[h] = TIER_FINISH_NOW;
               end else begin
                  base_pairing_scores[h] = TIER_ONE_TOWER;
               end
            end else begin
               base_pairing_scores[h] = 16'd0; // No eligible towers for this pairing
            end
         end
      end

// TIER SCORING
always_comb begin

   for (h = 0; h < 3; h = h + 1) begin

      sum0_ = pairing_sum[h][0];
      sum1_ = pairing_sum[h][1];

      dist0_ = tower_distance[sum0_];
      dist1_ = tower_distance[sum1_];

      elig0 = eligible_towers[sum0_];
      elig1 = eligible_towers[sum1_];


      base_pairing_scores[h] = 16'd0;


      if (elig0 && elig1) begin

         if ((sum0_ != sum1_) &&
             (dist0_ == 1) &&
             (dist1_ == 1))

            base_pairing_scores[h] = TIER_DOUBLE_FINISH;


         else if ((dist0_ == 1) ||
                  (dist1_ == 1))

            base_pairing_scores[h] = TIER_FINISH_NOW;


         else if ((sum0_ == sum1_) &&
                  (dist0_ == 2))

            base_pairing_scores[h] = TIER_FINISH_NOW;


         else if (sum0_ == sum1_)

            base_pairing_scores[h] = TIER_CLIMB_TWICE;


         else

            base_pairing_scores[h] = TIER_TWO_TOWERS;


      end

      else if (elig0 || elig1) begin

         if ((dist0_ == 1) ||
             (dist1_ == 1))

            base_pairing_scores[h] = TIER_FINISH_NOW;

         else

            base_pairing_scores[h] = TIER_ONE_TOWER;

      end

   end

end
logic [15:0] best_score;
logic [15:0] final_pairing_scores [2:0];
integer p;
// WINNER SELECTION
always_comb begin

   best_score = 0;
   best_pairing = 0;

   for (p = 0; p < 3; p = p + 1) begin

      final_pairing_scores[p] =
          base_pairing_scores[p] +
          added_probabilities[p];


      if (final_pairing_scores[p] > best_score) begin
          best_score = final_pairing_scores[p];
          best_pairing = p;
      end

   end

end
      
      // OUTPUT LOGIC & ASSIGNMENTS
      logic [15:0] pairing_score_reg[2:0];
      logic [0:0] priority_pair_reg[2:0];

      always_comb begin
         integer i;
         for (i = 0; i < 3; i = i + 1) begin
            if (base_pairing_scores[i] != 16'd0) begin
               pairing_score_reg[i] = base_pairing_scores[i] + {6'd0, added_probabilities[i]};
            end else begin
               pairing_score_reg[i] = 16'd0;
            end
            if (roll_probabilities[pairing_sum[i][0]] >= roll_probabilities[pairing_sum[i][1]]) begin
               priority_pair_reg[i] = 1'b0;
            end else begin
               priority_pair_reg[i] = 1'b1; 
            end
         end
      end

      assign pairing_score[0] = pairing_score_reg[0];
      assign pairing_score[1] = pairing_score_reg[1];
      assign pairing_score[2] = pairing_score_reg[2];

      assign priority_pair[0] = priority_pair_reg[0];
      assign priority_pair[1] = priority_pair_reg[1];
      assign priority_pair[2] = priority_pair_reg[2];

      // END TURN LOGIC
      localparam [7:0] ROLLS_THRESHOLD_FULL = 8'd5;    // climbing_cnt == 3; all slots filled
      localparam [7:0] ROLLS_THRESHOLD_PARTIAL = 8'd6; // climbing_cnt < 3; can still climb more

      logic any_tower_complete_now; // at least one tower is complete now
      logic rolls_threshold_hit;
      logic [7:0] current_threshold; // current threshold based on climbing_cnt

      integer t;

      always_comb begin
         any_tower_complete_now = 1'b0;
         for (t = 2; t <= 12; t = t + 1) begin
            if (tower_climbing[t] && (tower_completed[t] || double_finish || finish_now)) begin
               any_tower_complete_now = 1'b1;
            end
         end
      end

      always_comb begin
         current_threshold = (climbing_cnt == 2'd3) ? ROLLS_THRESHOLD_FULL : ROLLS_THRESHOLD_PARTIAL;
         rolls_threshold_hit = (rolls_this_turn >= current_threshold);
      end

      assign end_turn = my_turn && (rolls_threshold_hit || any_tower_complete_now);
      
      endmodule