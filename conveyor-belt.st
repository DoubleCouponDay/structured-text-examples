PROGRAM conveyor_belt
VAR
    //inputs
    start_button AT %I0.0: BOOL;
    left_sensor AT %I69.3: BOOL;
    right_sensor AT %I69.4: BOOL;

    //outputs
    stop_button AT %I0.1: BOOL;
    move_left AT %Q65.1: BOOL;
    move_right AT %Q65.0: BOOL;
    should_move_conveyor AT %M0.7: BOOL;
    should_reset AT %M1.0: BOOL;
    increment5 AT %Q0.4: BOOL;
    count AT %QW0: INT;

    //blocks
    counter5 AT %DB6: CTUD;

END_VAR;

should_move_conveyor := start_button OR (should_move_conveyor AND NOT should_reset);
move_left := should_move_conveyor AND (right_sensor OR (move_left AND NOT left_sensor));
move_right := should_move_conveyor AND NOT move_left;
should_reset := increment5 OR stop_button;
update_counter();

FUNCTION update_counter
    counter5.CU := should_move_conveyor AND right_sensor;
    counter5.CD := FALSE;
    counter5.R := should_reset;
    counter5.PV := 5;
    counter5.LD := FALSE;
    increment5 = counter5.QU;
    count := counter5.CV;

END_FUNCTION

END_PROGRAM
