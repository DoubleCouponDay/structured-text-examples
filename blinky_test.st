PROGRAM blinky_test
  VAR
    led : BOOL;
    on_timer : TON;
    off_timer : TOF;
  END_VAR

  on_timer.IN := NOT led;
  off_timer.IN := on_timer.Q;
  (* off_timer.PT := T#500ms;
  on_timer.PT := T#500ms;*)
  led := off_timer.Q;
END_PROGRAM

CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : blinky_test;
  END_RESOURCE
END_CONFIGURATION
