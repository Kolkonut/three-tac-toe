; lab project
; variable size tic tac toe

.MODEL SMALL



.DATA
matrix db 128, 64, 32, 16, 8, 4, 136, 142, 40   ; all the positions of the playing grid
; 1 | 2 | 3
;----------- 
; 4 | 5 | 6    
;-----------
; 7 | 8 | 9
; each number is of the form ABCDEFGH, set bit to 1 if 
; A - it contains a large O
; B - it contains a medium O
;	C - it contains a small O
;	D - it contains a large X
;	E - it contains a medium X
;	F - it contains a small X
;	G - highlight this cell
;	H - blank  


   
bigO db 'O' 
medO db 'o'
smlO db '.'

bigX db 'X' 
medX db 'x'
smlX db '*' 

blnk db ' '         

hbar db '-'
vbar db '|'
cbar db '+'

.CODE 
.STARTUP     
            
  LEA SI, matrix
  
 
  
  
  
  
  
  
  CALL draw_matrix
  
  
  
  
  
  
  
  
  
  
  
  
  JMP toend
 
 
 
 
 
 
 
 
 
  
  ; functions below this line, should not be run directly 
; -----------------------------------------------------------------------------
  draw_matrix PROC 
    ; push all registers to preserve their values 
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX 
    
    MOV AX, 0
    MOV BX, 0
    MOV CX, 0
    MOV DX, 0
    
    
    MOV DL, 38                ; top horizontal bar
    MOV DH, 12
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, hbar
    MOV CL, 5
    INT 10h  
    
    
    
    MOV DL, 38                  ; bottom horizontal bar
    MOV DH, 14
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, hbar
    MOV CL, 5
    INT 10h
           
           
           
    MOV CX, 5                     ; left vertical bar 
    MOV DL, 39
    MOV DH, 11
    mat_draw_loop1:
    
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, vbar
    PUSH CX
    MOV CL, 1
    INT 10h
    POP CX
    INC DH
    loop mat_draw_loop1  
    
    
    MOV CX, 5                       ; right vertical bar 
    MOV DL, 41
    MOV DH, 11
    mat_draw_loop2:
    
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, vbar
    PUSH CX
    MOV CL, 1
    INT 10h
    POP CX
    INC DH
    loop mat_draw_loop2
    
    MOV DL, 39                        ; top left crossbar
    MOV DH, 12
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, cbar
    MOV CL, 1
    INT 10h  
    
    MOV DL, 41                        ; top right crossbar
    MOV DH, 12
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, cbar
    MOV CL, 1
    INT 10h
    
    MOV DL, 39                          ; bot left crossbar
    MOV DH, 14
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, cbar
    MOV CL, 1
    INT 10h 
    
    MOV DL, 41                           ; bot right crossbar
    MOV DH, 14
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV AH, 9
    MOV AL, cbar
    MOV CL, 1
    INT 10h
     
     
 

    
    MOV DL, 38                      ; inserting pips into the grid
    MOV DH, 11
    
    MOV CX, 3 
    
    print_out_loop:                 ; iterate rows
      PUSH CX
      MOV CX, 3
      MOV DL, 38
      print_in_loop:                ; iterate cols
        MOV AH, 2
        INT 10H
        
        
        MOV BX, 0Fh
        MOV AL, [SI]                ; check if a location needs to be highlighted
        TEST AL, 2
        JZ contd1
        MOV BX, 0F0h
        
           
       
        contd1: 
        PUSH CX
        MOV CX, 0
        MOV AH, 9
        
        MOV AL, [SI]                ; check which pip should be displayed
                                    ; by testing the bits
        TEST AL, 10010000b          ; this tests for X, O    
        JZ med_test                 ; if neither, check for next largest  
        TEST AL, 10000000b          ; check if X or if O
        JNZ char_bigO
        JZ char_bigX
        
        med_test:               
        TEST AL, 01001000b          ; this tests for x, o
        JZ sml_test
        TEST AL, 01000000b
        JNZ char_medO
        JZ char_medX
        
        sml_test:
        TEST AL, 00100100b          ; this tests for *, .
        JZ char_blnk
        TEST AL, 00100000b
        JNZ char_smlO
        JZ char_smlX
        
        
        char_bigO: MOV AL, bigO     ; map the results of testing to actual ASCII chars from data
        JMP asdf 
        char_bigX: MOV AL, bigX
        JMP asdf 
        char_medO: MOV AL, medO
        JMP asdf              
        char_medX: MOV AL, medX
        JMP asdf               
        char_smlO: MOV AL, smlO
        JMP asdf 
        char_smlX: MOV AL, smlX
        JMP asdf               
        char_blnk: MOV AL, blnk
        JMP asdf 
              
        
        
        asdf:
        MOV CL, 1
        INT 10h  
        
        INC SI
        INC DL                      ; move to next available column
        INC DL
          
        POP CX
        LOOP print_in_loop
      
      INC DH                        ; move to next available row
      INC DH  
      
      POP CX
      LOOP print_out_loop
                      
                     
        
      
    LEA SI, matrix
    
    
    
    
    
    

     
    ; pop all registers
    POP DX
    POP CX
    POP BX
    POP AX  
  draw_matrix ENDP       
  
  
  
  toend:      
.EXIT 
END