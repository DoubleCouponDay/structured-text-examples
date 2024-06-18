PROGRAM PLC_PRG
VAR
    redlight_mainroad AT %Q550.0: BOOL; //red light, main road
    orangelight_mainroad AT %Q550.1: BOOL; //orange light, main road
    greenlight_mainroad AT %Q550.2: BOOL; //green light, main road

    redlight_sidestreet AT %Q550.3: BOOL; //red light, side road
    orangelight_sidestreet AT %Q550.4: BOOL; //orange light, side road
    greenlight_sidestreet AT %Q550.5: BOOL; //green light, side road

    redlight_pedestrian AT %Q550.6: BOOL; //red light pedestrian
    greenlight_pedestrian AT %Q550.7: BOOL; //green light pedestrian

    S1_S2 AT %I500.2: BOOL; //pedestrian button
    S3 AT %I500.5: BOOL; //car sensor induction loop

    SYSTEM_ON AT %I500.0: BOOL; //on switch

    power_state: BOOL
    system_state: INT;
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
        0: mainroad()
        1: button_pressed()
        2: car_detected()
        3: pedestrians_walk()
        4: sidestreet()
        5: sidestreet_orange()
    END_CASE;

FUNCTION mainroad
    redlight_mainroad := FALSE;
    orangelight_mainroad := FALSE;
    greenlight_mainroad := TRUE;

    redlight_sidestreet := TRUE;
    orangelight_sidestreet := FALSE;
    greenlight_sidestreet := FALSE;

    redlight_pedestrian := TRUE;
    greenlight_pedestrian := FALSE;

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

FUNCTION mainroad_orange
    VAR_INPUT
        next_state: INT;
    END_VAR;

    greenlight_mainroad := FALSE;
    orangelight_mainroad := TRUE;
    redlight_mainroad := FALSE;

    yellow_timer(IN := yellow_trigger, PT := delay1);
    yellow_trigger := TRUE;

    IF yellow_timer.Q = TRUE THEN
        yellow_trigger := FALSE;
        system_state := next_state;
    END_IF;

END_FUNCTION

FUNCTION button_pressed
    mainroad_orange(3);
END_FUNCTION

FUNCTION car_detected
    mainroad_orange(4);
END_FUNCTION

FUNCTION pedestrians_walk
    greenlight_sidestreet := FALSE;
    orangelight_sidestreet := FALSE;
    redlight_sidestreet := TRUE;
    
    redlight_pedestrian := FALSE;
    greenlight_pedestrian := TRUE;

    green_timer(IN := green_trigger, PT := delay2);
    green_trigger := TRUE;

    IF green_timer.Q = TRUE THEN
        green_trigger := FALSE;
        system_state := 0;
    END_IF;
END_FUNCTION

FUNCTION sidestreet
    greenlight_mainroad := FALSE;
    orangelight_mainroad := FALSE;
    redlight_mainroad := TRUE;

    greenlight_sidestreet := TRUE;
    orangelight_sidestreet := FALSE;
    redlight_sidestreet := FALSE;

    green_timer(IN := green_trigger, PT := delay2);
    green_trigger := TRUE;

    IF green_timer.Q = TRUE THEN
        green_trigger := FALSE;
        system_state := 5;
    END_IF;
END_FUNCTION

FUNCTION sidestreet_orange
    greenlight_sidestreet := FALSE;
    orangelight_sidestreet := TRUE;
    redlight_sidestreet := FALSE;

    yellow_timer(IN := yellow_trigger, PT := delay1);
    yellow_trigger := TRUE;

    IF yellow_timer.Q = TRUE THEN
        yellow_trigger := FALSE;
        system_state := 0;
    END_IF;
END_FUNCTION

END_PROGRAM

