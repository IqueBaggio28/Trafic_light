; CDA PROJECT: TRAFFIC LIGHT CROSSING
; Created: 4/21/2023 6:45:16 PM
; Author : Henrique Baggio, Rafael Huang, Charles Marsala, Carlos Bolivar

; Project Description: Project is consists of simulating a traffic light crossing between "North-South" and "East-West"
; and a white LED which is turned on and off when it receives an input from the user, which will cause the white light to
; go on when the red light is supposed to turn on



;______________________________________________________________________



main:

                ; init stack pointer

                ldi r16, HIGH(RAMEND)
                out SPH, r16
                ldi r16, LOW(RAMEND)
                out SPL, r16



; setting the ports in PORTD and PORTB to output execpt from PORTD5
;
;=======================================================================================
               ldi r20, 0xFF
               out DDRD, r20
               out PORTD, r20
               out DDRB, r20
               out PORTB, r20
               cbi DDRD, DDD5

               cbi PORTD, PD7
               cbi PORTD, PB1
               cbi PORTD, PD4
               cbi PORTD, PD2
               cbi PORTD, PD3
               cbi PORTB, PB5

; function of the lights making it turn on and off in a traffic light pattern for two directions (North x South)
;                                                                                                (East x West)
;=======================================================================================
light_blink:
                
                rcall tm1_25s                                                      
                                                                                ; PD5 is for the button
                sbi PORTB, PB1                                                  ; PB5 is "East-West" RED LED
                sbi PORTD, PD3                                                  ; PD7 is "East-West" YELLOW LED
                cbi PORTD, PD4                                                  ; PB1 is "East-West" GREEN LED
                sbi PORTD, PD6                                                  ; PD6 is "North-South" RED LED                                                                              
                                                                                ; PD4 is "North-South" YELLOW LED                                                 
                                                                                ; PD2 is "North-South" GREEN LED 
                                                                                ; PD3 is the pedestrian WHITE LED
                rcall tm1_25s ; delay for green
                rcall tm1_25s
                rcall tm1_25s ; this line might have to be deleted

                cbi PORTB, PB1 ; turn off green
                sbi PORTD, PD7 ; turn on yellow

                rcall tm1_25s ; delay for yellow
                rcall tm1_25s

                cbi PORTD, PD7 ; turn off YELLOW
                sbi PORTB, PB5
                cbi PORTD, PD6 ; turn LED off
                sbi PORTD, PD3
                sbi PORTD, PD2
                cbi PORTD, PD3
                ;sbi PORTD, PD5


                rcall tm1_25s ; delay
                rcall tm1_25s
                rcall tm1_25s
                rcall tm1_25s
                rcall tm1_25s
                rcall tm1_25s


                cbi PORTD, PD2
                sbi PORTD, PD4

main_loop:

wait_input_loop:
               sbic PIND, PIND5 ; waits for the button to be pressed to activate the white light and coninue the code
               rjmp wait_input_loop
               
               
 end_main:
    rjmp light_blink

; Timers for delay  (Timer1 was used)
;
;=======================================================================================
tm1_25s:
                ; Load TCNT1H: TCNT1L with initial count
                ldi r20, HIGH(65536 - 15625) ; 1/4s @ 256
                sts TCNT1L, r20
                ldi r20, LOW(65536 - 15625)        ; 1/4s @ 256
                sts TCNT1L, r20

        ; Load TCCR1A & TCCR1B
                ; Normal mode
                clr r20
                sts TCCR1A, r20                 ; set normal mode

                ; Clock Prescaler - setting the clock starts the timer
                ldi r20, (1<<CS12)
                sts TCCR1B, r20                 ; normla mode & 256 scaler

                ; Monitor TOV1 flag in TIFRI (in I/0 mem)

        tm1_25s_wait:
                sbis TIFR1, TOV1                               ; wait for overflow flat to set
                rjmp tm1_25s_wait

                ; Stop timer by clearing clock (clear TCCR1B)
                clr r20
                sts TCCR1B, r20                 ; stop timer

                ; Clear tov1 flag - write a 1 to TOV1 bit in TIFR1 (in I/0 mem)
                sbi TIFR1, TOV1                  ; rest flag

                ret                                    ;tm1_25s