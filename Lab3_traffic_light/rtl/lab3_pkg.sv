package lab3_pkg;

    // Define the states of the traffic light
    typedef enum logic [2:0] {
        L_RED = 3'b001,
        L_YELLOW = 3'b010,
        L_GREEN = 3'b100
    } tl_light_t;

    typedef enum logic [3:0] {
        S_EW_THRU_G      = '0,  // is L_GREEN
        S_EW_THRU_Y,            // is L_YELLOW
        S_RED_TO_EW_LEFT,       // full L_RED to next tl_state

        S_EW_LEFT_G,
        S_EW_LEFT_Y,
        S_RED_TO_SN_THRU,

        S_SN_THRU_G,
        S_SN_THRU_Y,
        S_RED_TO_SN_LEFT,

        S_SN_LEFT_G,
        S_SN_LEFT_Y,
        S_RED_TO_EW_THRU
    } tl_state_t;

endpackage
