; lab project
; variable size tic tac toe

.MODEL SMALL



.DATA

         
matrix db 0, 0, 0, 0, 0, 0, 0, 0, 0    ; all the positions of the playing grid
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

player1 db 10101000b
; status byte for player 1, of the form AABBCCDD
; AA - number of large pips left, ranges from 10 to 00
; BB - number of medium pips left, ranges from 10 to 00
; CC - number of small pips left, ranges from 10 to 00
; DD - no purpose rn

player2 db 10101000b 
; status byte for player 1, of the form AABBCCDD
; AA - number of large pips left, ranges from 10 to 00
; BB - number of medium pips left, ranges from 10 to 00
; CC - number of small pips left, ranges from 10 to 00
; DD - no purpose rn

currentP db 0
; indicates current player, if 0 it is player 1 else player 2
; just XOR it with 11111111b after every turn  


   
bigO db 'O' 
medO db 'o'
smlO db '.'
; different pip sizes for O

bigX db 'X' 
medX db 'x'
smlX db '*'
; different pip sizes for X 

blnk db ' '         

hbar db '-'
vbar db '|'
cbar db '+' 
; used for drawing the grid itself                      
                      
buff db '%','$'
; just a buffer symbol

p1str db "Player 1 $"
p2str db "Player 2 $" 
lpipstr db "Large pips left :$"
mpipstr db "Medium pips left:$"
spipstr db "Small pips left :$" 
currentstr db "Current Turn $"
; misc strings for printing
str db "Enter the location and symbol $" 

loc dw 00h ; Stores the location (user input)
sym db 00h ; Stores the pip value (user input)       
count db 00h    ; Stores the count of pips 

.CODE 
.STARTUP     
            
  LEA SI, matrix
  
 
  
  
  
  
  
 
  CALL draw_matrix
  HERE: 
  CALL user_input   
  CALL player1_find 
  CALL draw_matrix 
  XOR currentP,11111111b
  CALL player2_find
  CALL draw_matrix
  JMP HERE
  
  
  
  
  
  
  
  
  
  
  
  
  JMP toend
 
 
 
 
 
 
 
 
 
  
  ; functions below this line, should not be run directly 
; -----------------------------------------------------------------------------
  draw_matrix PROC
    LEA SI, matrix
   
     
    
    
    MOV AX, 0
    MOV BX, 0
    MOV CX, 0
    MOV DX, 0
    
    

    MOV AX, 0700h  ; function 07, AL=0 means scroll whole window
    MOV BH, 07h    ; character attribute = white on black
    MOV CX, 0  ; row = 0, col = 0
    MOV DX, 0184Fh  ; row = 24 (0x18), col = 79 (0x4f)
    INT 10h        

  
    
    
    
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
     
     
    MOV DL, 10                ; printing Player 1 title
    MOV DH, 5
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV DX, offset p1str
    MOV AH, 9
    INT 21h   
    
    
    MOV DL, 8                ; printing large pips
    MOV DH, 7  
    MOV AH, 2
    INT 10h
    
    MOV DX, offset lpipstr
    MOV AH, 9
    INT 21h 
    
    MOV AL, player1
    AND AL, 11000000b
    SHR AL, 6
    ADD AL, 30h
    MOV buff, AL
    
    MOV DX, offset buff
    MOV AH, 9
    INT 21h
    
    
    MOV DL, 8                ; printing medium pips
    MOV DH, 8   
    MOV AH, 2
    INT 10h
    
    MOV DX, offset mpipstr
    MOV AH, 9
    INT 21h
    
    MOV AL, player1
    AND AL, 00110000b
    SHR AL, 4
    ADD AL, 30h
    MOV buff, AL
    
    MOV DX, offset buff
    MOV AH, 9
    INT 21h 
    
    
    MOV DL, 8                ; printing small pips
    MOV DH, 9  
    MOV AH, 2
    INT 10h
    
    MOV DX, offset spipstr
    MOV AH, 9
    INT 21h
    
    MOV AL, player1
    AND AL, 00001100b
    SHR AL, 2
    ADD AL, 30h
    MOV buff, AL
    
    MOV DX, offset buff
    MOV AH, 9
    INT 21h
    
    MOV AL, currentP
    CMP AL, 0
    JNZ Player2Print 
    
    MOV DL, 8                ; printing current turn indicator
    MOV DH, 12
    MOV AH, 2
    INT 10h
    
    MOV DX, offset currentstr
    MOV AH, 9
    INT 21h
    
    
    
    
    
    
    
    Player2Print:
    
    MOV DL, 56                ; printing Player 2 title
    MOV DH, 5
    MOV BX, 0fh
    
    MOV AH, 2
    INT 10h
    
    MOV DX, offset p2str
    MOV AH, 9
    INT 21h   
    
    
    MOV DL, 54                ; printing large pips
    MOV DH, 7  
    MOV AH, 2
    INT 10h
    
    MOV DX, offset lpipstr
    MOV AH, 9
    INT 21h 
    
    MOV AL, player2
    AND AL, 11000000b
    SHR AL, 6
    ADD AL, 30h
    MOV buff, AL
    
    MOV DX, offset buff
    MOV AH, 9
    INT 21h
    
    
    MOV DL, 54                ; printing medium pips
    MOV DH, 8   
    MOV AH, 2
    INT 10h
    
    MOV DX, offset mpipstr
    MOV AH, 9
    INT 21h
    
    MOV AL, player2
    AND AL, 00110000b
    SHR AL, 4
    ADD AL, 30h
    MOV buff, AL
    
    MOV DX, offset buff
    MOV AH, 9
    INT 21h 
    
    
    MOV DL, 54                ; printing small pips
    MOV DH, 9  
    MOV AH, 2
    INT 10h
    
    MOV DX, offset spipstr
    MOV AH, 9
    INT 21h
    
    MOV AL, player2
    AND AL, 00001100b
    SHR AL, 2
    ADD AL, 30h
    MOV buff, AL
    
    MOV DX, offset buff
    MOV AH, 9
    INT 21h
    
    MOV AL, currentP
    CMP AL, 0
    JZ exitPrinter 
    
    MOV DL, 54                ; printing current turn indicator
    MOV DH, 12
    MOV AH, 2
    INT 10h
    
    MOV DX, offset currentstr
    MOV AH, 9
    INT 21h
    
    
    
    
    

   exitPrinter:     
   ret
  draw_matrix ENDP 
  ;-------------------------------------------------------------------------------------------
  ; 
  ; ---------Function 1 -----------------------------   
        ; user input - Takes the input from the user as '1A'
        ; Need to display the cursor at the bottom
    
     
           
      user_input PROC
                    
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
        
        ; Setting cursor position 
            
        
        MOV DL, 10               
        MOV DH, 20  
        MOV AH, 2
        INT 10h
    
    
        lea dx,str
        mov ah,09h
        int 21h  
        
        ; stores the location 
        mov ah,01h
        int 21h 
        mov dl,al
        sub dl,31h
        mov loc,dx 
        
        ; stores the pips value
        
        mov ah,01h
        int 21h    
        mov sym,al  
        mov si,0h
      user_input ENDP   
        
        RET
  ;--------------------------- Function-player2_find----------------------;
      
        ;Player1_find-  Finding if A,B or C is avaiable  
        
        
        ;Player1_find-  Finding if A,B or C is avaiable  
        
        
        player2_find PROC 
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0  
        
        
        MOV AL,player2 
        MOV BL , sym
        ; if pip == A (Large Pip)
        
        MOV BL , sym 
        XOR BL,41H  ; Check if its equal to 41H(After converting into hexadecimal)
        CMP BL,0h   ; Compare with zero 
        JNZ med     ; If not 0h move to pip B
        AND AL, 11000000b
        SHR AL, 6 
        ; After attaining the value check if A values are present are not.
        ; The count should be greater than 0
        MOV DL,AL
        CMP DL,0H             
        MOV count,AL
        
        JBE invalid ; If the count == 0 , ask input again  
        CALL locationp2_A 
        ; Subtract 1 from the count (is left)   
        MOV BL,player2
        MOV AL,count
        DEC AL
        SHL AL,6
        AND BL, 00111111b
        OR AL,BL  
        MOV player2,AL
        
        ret
        
        
        ; if pip == B (medium pips)  (same method applied as A)
        
        med: 
        MOV BL , sym
        XOR BL,42H    
        CMP bl,0h
        JNZ small
        AND AL, 00110000b
        SHR AL, 4   
        MOV DL,AL
        CMP DL,0H   
        MOV count,AL
        JBE invalid  
        CALL locationp2_B
        MOV BL,player2
        MOV AL,count
        DEC AL
        SHL AL,4
        AND BL, 11001111b
        OR AL,BL  
        MOV player2,AL
        ret
        
        ; if pip == C (small pips)
        small:
        MOV BL , sym
        XOR BL,43h 
        CMP bl,0h
        JNZ invalid ;  If not equal to A,B,C ask user to input again
        AND AL, 00001100b
        SHR AL, 2    
        MOV DL,AL
        CMP DL,0H   
        MOV count,AL
        JBE invalid 
        CALL locationp2_C  
        MOV BL,player2
        MOV AL,count
        DEC AL
        SHL AL,2
        AND BL, 11110011b
        OR AL,BL  
        MOV player2,AL 
        ret   
        
        
        
        invalid:  
        
        CALL user_input       ; Ask user the input 
        CALL player2_find     ; Perform this function again 
        
        player2_find ENDP
        ret
        
        
    ;---------------------------FUNCTION 3-----------------------;
        
        
        locationp2_A PROC     
        ; if the location is more than 9 the input is invalid 
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
         
        MOV dx,loc ; Store the location in DX  
        MOV bl , sym ; store the weight 
        LEA si,matrix ; iterate element  
        ; Add values to iterate the location 
        add si,dx  
        MOV dl,[si]
        AND dl,10010000b    ; Check if A contains in the current location 
        CMP dl,0
        JNZ again: ; if not zero jump   
        OR dl,00010000b 
        MOV [si],dl
        
        ret                  
        
        
        
        again:  
        
        CALL user_input   
        CALL player2_find
        locationp2_A ENDP
        ret
             
    ;----------------------------FUNCTION LOCATION B ---------------------      
             
        locationp2_B PROC 
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
            
        
         
        MOV dx,loc ; Store the location in DX  
        MOV bl , sym ; store the weight 
        LEA si,matrix ; iterate element  
        ; Add values to iterate the location 
        add si,dx  
        MOV dl,[si]
        AND dl,11011000b
        CMP dl,0
        JNZ again_2: ; if not zero jump   
        OR dl,00001000b 
        MOV [si],dl
        
        ret                  
        
        
        
        again_2:  ; if weight of the pip does not satisfy then the input location is wrong
        
        CALL user_input   
        CALL player2_find
        locationp2_B ENDP
        ret
        
                    
                    
         
         
         
         
         
        ;----------------------FUNCTION LOCATION_C----------------------------;             
        
        locationp2_C PROC     
        ; if the location is more than 9 the input is invalid
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0 
         
        MOV dx,loc ; Store the location in DX  
        MOV bl , sym ; store the weight 
        LEA si,matrix ; iterate element  
        ; Add values to iterate the location 
        add si,dx  
        MOV dl,[si]
        AND dl,11111100b
        CMP dl,0
        JNZ again_3: ; if not zero jump   
        OR dl,00000100b 
        MOV [si],dl
        ; Add or logic here 
        ret                  
        
        
        
        again_3:  ; if weight of the pip does not satisfy then the input location is wrong
        
        CALL user_input   
        CALL player2_find
        locationp2_C ENDP
        ret      
        
        
        
        ;--------------------------- Function-player1_find----------------------;
      
        ;Player1_find-  Finding if A,B or C is avaiable  
        
        
        player1_find PROC 
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0  
        
        
        MOV AL,player1 
        MOV BL , sym
        ; if pip == A (Large Pip)
        
        MOV BL , sym 
        XOR BL,41H  ; Check if its equal to 41H(After converting into hexadecimal)
        CMP BL,0h   ; Compare with zero 
        JNZ med2     ; If not 0h move to pip B
        AND AL, 11000000b
        SHR AL, 6 
        ; After attaining the value check if A values are present are not.
        ; The count should be greater than 0
        MOV DL,AL
        CMP DL,0H      
        MOV count,AL
        
        JBE invalid2 ; If the count == 0 , ask input again  
        CALL locationp1_A 
        ; Subtract 1 from the count (is left)   
        MOV BL,player1
        MOV AL,count
        DEC AL
        SHL AL,6
        AND BL, 00111111b
        OR AL,BL  
        MOV player1,AL 
        
        ret
        
        
        ; if pip == B (medium pips)  (same method applied as A)
        
        med2: 
        MOV BL , sym
        XOR BL,42H    
        CMP bl,0h
        JNZ small2
        AND AL, 00110000b
        SHR AL, 4   
        MOV DL,AL
        CMP DL,0H
        MOV count,AL
        JBE invalid2 
        CALL locationp1_B
        MOV BL,player1
        MOV AL,count
        DEC AL
        SHL AL,4
        AND BL, 11001111b
        OR AL,BL  
        MOV player1,AL
        ret
        
        ; if pip == C (small pips)
        small2:
        MOV BL , sym
        XOR BL,43h 
        CMP bl,0h
        JNZ invalid2 ;  If not equal to A,B,C ask user to input again
        AND AL, 00001100b
        SHR AL, 2    
        MOV DL,AL
        CMP DL,0H
        MOV count,AL
        JBE invalid2
        CALL locationp1_C  
        MOV BL,player1
        MOV AL,count
        DEC AL
        SHL AL,2
        AND BL, 11110011b
        OR AL,BL  
        MOV player1,AL  
        ret   
        
        
        
        invalid2:  
        
        CALL user_input       ; Ask user the input 
        CALL player1_find     ; Perform this function again 
        
        player1_find ENDP
        ret
        
        
    ;---------------------------FUNCTION 3-----------------------;
        
        
        locationp1_A PROC     
        ; if the location is more than 9 the input is invalid 
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
         
        MOV dx,loc ; Store the location in DX  
        MOV bl , sym ; store the weight 
        LEA si,matrix ; iterate element  
        ; Add values to iterate the location 
        add si,dx  
        MOV dl,[si]
        AND dl,10010000b    ; Check if A contains in the current location 
        CMP dl,0
        JNZ again4: ; if not zero jump   
        OR dl,10000000b 
        MOV [si],dl
        
        ret                  
        
        
        
        again4:  
        
        CALL user_input   
        CALL player1_find
        locationp1_A ENDP
        ret
             
    ;----------------------------FUNCTION LOCATION B ---------------------      
             
        locationp1_B PROC 
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
            
        
         
        MOV dx,loc ; Store the location in DX  
        MOV bl , sym ; store the weight 
        LEA si,matrix ; iterate element  
        ; Add values to iterate the location 
        add si,dx  
        MOV dl,[si]
        AND dl,11011000b
        CMP dl,0
        JNZ again_5: ; if not zero jump   
        OR dl,01000000b 
        MOV [si],dl
        
        ret                  
        
        
        
        again_5:  ; if weight of the pip does not satisfy then the input location is wrong
        
        CALL user_input   
        CALL player1_find
        locationp1_B ENDP
        ret
        
                    
                    
         
         
         
         
         
        ;----------------------FUNCTION LOCATION_C----------------------------;             
        
        locationp1_C PROC     
        ; if the location is more than 9 the input is invalid
        MOV AX, 0
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0 
         
        MOV dx,loc ; Store the location in DX  
        MOV bl , sym ; store the weight 
        LEA si,matrix ; iterate element  
        ; Add values to iterate the location 
        add si,dx  
        MOV dl,[si]
        AND dl,11111100b
        CMP dl,0
        JNZ again_6: ; if not zero jump   
        OR dl,00100000b 
        MOV [si],dl
        ; Add or logic here 
        ret                  
        
        
        
        again_6:  ; if weight of the pip does not satisfy then the input location is wrong
        
        CALL user_input   
        CALL player1_find
        locationp1_C ENDP
        ret
                 
                 
        
        


  toend:      
.EXIT 
END

