    LJMP START
    ORG 100H
START:
    LCALL LCD_CLR
LOOP:
    LCALL WAIT_KEY
    MOV R0, A ; In R0 first value
    LCALL INPUT_BCD
SIGN:
    LCALL WAIT_KEY 
    LCALL SIGN_CODE ; Display operator
    LJMP LOOP
    NOP
    
BCD: 
    MOV B, #10
    DIV AB
    SWAP A
    ADD A,B
    LCALL   WRITE_HEX ; Print output in bcd
CONFRIM_RESULT:
    LCALL WAIT_KEY
    CJNE A, #15, CONFRIM_RESULT
    LCALL LCD_CLR ; clear output after printing
    RET

INPUT_BCD:
    MOV B, #10
    DIV AB
    SWAP A
    ADD A,B
    LCALL WRITE_HEX ; Print input values in bcd
    RET

SIGN_CODE:
    CJNE A,#11,PLUS
    CJNE A,#10,STAR

PLUS:
    CJNE A,#10,STAR
    MOV A, #'+'
    LCALL WRITE_DATA
    LJMP ADDITION
    RET

STAR:
    CJNE A,#11,MINUS
    MOV A, #'*'
    LCALL WRITE_DATA
    LJMP MULTIPLY
    RET

MINUS:
    CJNE A,#12,COLON
    MOV A, #'-'
    LCALL WRITE_DATA
    LJMP SUBTRACTION
    RET

COLON:
    CJNE A,#13,SIGN ; Wrong sign validation
    MOV A, #':'
    LCALL WRITE_DATA
    LJMP DIVISION
    RET

ADDITION:
    LCALL WAIT_KEY
    MOV R1, A ; In R1 second value
    LCALL INPUT_BCD
    MOV A, # '='
    LCALL WRITE_DATA
    MOV A, R1 ; Move back R1 to Acumulator
    ADD A, R0
    LJMP BCD
    RET

MULTIPLY:
    LCALL WAIT_KEY
    MOV R1, A ; In R1 second value
    LCALL INPUT_BCD
    MOV B, R1 ; Move second value to B 
    MOV A, # '='
    LCALL WRITE_DATA
    MOV A, R0
    MUL AB
    LJMP BCD
    RET

SUBTRACTION:
    LCALL WAIT_KEY
    MOV R1, A ; In R1 second value
    LCALL INPUT_BCD
    MOV A, # '='
    LCALL WRITE_DATA
    MOV A, R0 ; Move back R0 to Acumulator
    CLR C
    SUBB A, R1
    JC NEGATIVE
    LJMP BCD

NEGATIVE:
    CPL A
    INC A
    MOV R3, A
    MOV A, #'-'
    LCALL   WRITE_DATA
    MOV A, R3
    LJMP BCD
    RET

DIVISION:
    LCALL WAIT_KEY
    CJNE A, #0, NONZERO
    LJMP DIVISION
NONZERO:
    MOV R1, A
    LCALL INPUT_BCD
    MOV B, R1 ; Move second value to B
    MOV A, # '='
    LCALL WRITE_DATA
    MOV A, R0
    DIV AB
    MOV R3, B
    LJMP BCD_DIVISON
    RET

BCD_DIVISON:
    MOV B, #10
    DIV AB
    SWAP A
    ADD A, B
    LCALL WRITE_HEX
REST:
    MOV DPTR, #TEXT
    LCALL   WRITE_TEXT
    MOV A, R3
    MOV B, #10
    DIV AB
    SWAP A
    ADD A, B
    LCALL WRITE_HEX ; Print rest of divison
CONFIRM_REST:
    LCALL WAIT_KEY
    CJNE A, #15, CONFIRM_REST
    LCALL LCD_CLR
    RET

TEXT:
    DB 'r.',0