PROGRAM backup_generator
VAR
    X1_0: BOOL; //boilers thermal overload input
    X1_1: BOOL; //water temperature thermal overload input
    X1_2: BOOL; //smog levels exceeded
    Y1_0: BOOL; //main generator
    Y1_1: BOOL; //standby generator

    T_10s: TON; //10 second timer
    rtime: TIME; //5 second timer
    T_5s: TON;
    ztime: TIME;
END_VAR

Y1_0 := X1_0 AND T_10s.Q AND T-5s.Q;
T_10s.IN := X1_1
T_5s.IN := X1_2
Y1_1 := Y1_0

END_PROGRAM
