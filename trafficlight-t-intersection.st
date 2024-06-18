PROGRAM PLC_PRG
VAR
    H1 AT %Q550.0: BOOL; //red light, side road
    H2 AT %Q550.1: BOOL; //orange light, side road
    H3 AT %Q550.2: BOOL; //green light, side road

    H4 AT %Q550.3: BOOL; //red light, side road
    H5 AT %Q550.4: BOOL; //orange light, side road
    H6 AT %Q550.5: BOOL; //green light, side road

    H7 AT %Q550.6: BOOL := TRUE; //red light pedestrian
    H8 AT %Q550.7: BOOL; //green light pedestrian
    S1_S2 AT %I500.2: BOOL; //pedestrian button
    S3 AT %I500.5: BOOL; //car sensor induction loop

    SYSTEM_ON AT %I500.0: BOOL; //on switch

    power_state: BOOL
    system_state: INT := 0;
    button_was_pressed: BOOL;
    inducer_was_triggered: BOOL;

    red_timer: TON;
    red_trigger: BOOL;
    yellow_timer: TON;
    yellow_trigger: BOOL;
    green_timer: TON;
    green_trigger: BOOL;

    delay1: TIME := T#3s;
    delay2: TIME := T#10s;
END_VAR

IF SYSTEM_ON THEN
    power_state := TRUE;

ELSE THEN
    power_state := FALSE;
END_IF;

if power_state THEN
    CASE system_state OF
        0: main_road()
        1: button_pressed()
        2: car_detected()
        3: pedestrians_walk()
        4: sidestreet()
        5: sidestreet_orange()
    END_CASE;

FUNCTION main_road
    H7 := TRUE;
    H8 := FALSE;

    H2 := FALSE;
    H1 := TRUE;
    H4 := FALSE;
    H6 := TRUE;

    IF S1_S2 = TRUE THEN
        red_timer(IN := red_trigger, PT := delay1);
        red_trigger := TRUE;
        button_was_pressed := TRUE:

    ELSE IF S3 = TRUE THEN
        inducer_was_triggered := TRUE;

    ELSE IF red_timer.Q = TRUE THEN
        red_trigger := FALSE;

        IF button_was_pressed = TRUE THEN
            system_state := 1;
            button_was_pressed := FALSE;

        ELSE IF inducer_was_triggered = TRUE
            system_state := 2;
            inducer_was_triggered := FALSE;

        END_IF;
    END_IF;
END_FUNCTION

FUNCTION button_pressed
    H6 := FALSE;
    H5 := TRUE;

    yellow_timer(IN := yellow_trigger, PT := delay1);
    yellow_trigger := TRUE;

    IF yellow_timer.Q = TRUE THEN
        yellow_trigger := FALSE;
        system_state := 3;

    END_IF;
END_FUNCTION

FUNCTION car_detected
    H6 := FALSE;
    H5 := TRUE;

    yellow_timer(IN := yellow_trigger, PT := delay1);
    yellow_trigger := TRUE;

    IF yellow_timer.Q = TRUE THEN
        yellow_trigger := FALSE;
        system_state := 4;
    END_IF;
END_FUNCTION

FUNCTION pedestrians_walk
    H5 := FALSE;
    H4 := TRUE;
    
    H7 := FALSE;
    H8 := TRUE;

    green_timer(IN := green_trigger, PT := delay2);
    green_trigger := TRUE;

    IF green_timer.Q = TRUE THEN
        green_trigger := FALSE;
        system_state := 0;
    END_IF;
END_FUNCTION

FUNCTION sidestreet
    H5 := FALSE;
    H4 := TRUE;

    H1 := FALSE;
    H3 := TRUE;

    green_timer(IN := green_trigger, PT := delay2);
    green_trigger := TRUE;

    IF green_timer.Q = TRUE THEN
        green_trigger := FALSE;
        system_state := 5;
    END_IF;
END_FUNCTION

FUNCTION sidestreet_orange
    H3 := FALSE;
    H2 := TRUE;

    yellow_timer(IN := yellow_trigger, PT := delay1);
    yellow_trigger := TRUE;

    IF yellow_timer.Q = TRUE THEN
        yellow_trigger := FALSE;
        system_state := 0;
    END_IF;
END_FUNCTION

END_PROGRAM

