;
; tiny R 45 -- OHM only version
; for Tiny-VOM 45 board
;

;.include "tn45def.inc"
.device attiny45

.equ txpin = PB1; serial transmit
.equ rxpin = PB0; serial receive
.equ v_adc_pin = PB4;
.equ r_adc_pin = PB3;
.equ c_adc_pin = PB2;

.def bitcnt = R16; bit counter
.def temp = R17; temporary storage
.def temp1 = R18; temporary storage
.def txbyte = R19; transmit byte
.def rxbyte = R20; receive byte


.cseg
.org 0
rjmp reset

;
; putchar
; assumes no line driver (doesn't invert bits)
;
.equ sb = 1; number of stop bits
putchar:
    ldi bitcnt, 9+sb; 1+8+sb
    com txbyte; invert everything
    sec; set start bit
    putchar0:
        brcc putchar1; if carry set
        sbi PORTB, txpin; send a '0'
        rjmp putchar2; else	
    putchar1:
         cbi PORTB, txpin	; send a '1'
         nop ; even out timing
    putchar2:
         rcall bitdelay; one bit delay
         rcall bitdelay
         lsr txbyte; get next bit
         dec bitcnt; if not all bits sent
         brne putchar0; send next bit
    ret;
;
; getchar
; assumes no line driver (doesn't invert bits)
;
getchar:
    ldi bitcnt,9 ; 8 data bit + 1 stop bit
    getchar1:
        sbis PINB, rxpin ; wait for start bit
        rjmp getchar1
    rcall bitdelay ; 0.5 bit delay
    getchar2:
        rcall bitdelay ; 1 bit delay
        rcall bitdelay ;
        clc ; clear carry
        sbis PINB, rxpin ; if RX pin high skip
            sec ; otherwise set carry
        dec bitcnt
        breq getchar3 ; return if all bits read
        ror rxbyte ; otherwise shift bit into receive byte
        rjmp getchar2 ; go get next bit
    getchar3:
        ret
;
; bitdelay
; serial bit delay
;
.equ b = 13 ; 9600 baud (8 MHz clock /8)
bitdelay:
    ldi temp, b
    bitloop:
        dec temp
        brne bitloop
    ret
;
; main program
;
reset:
    ;
    ; set stack pointer to top of RAM
    ;
    ldi temp, high(RAMEND)
    out SPH, temp
    ldi temp, low(RAMEND)
    out SPL, temp
    ;
    ; init comm pins
    ;
    cbi PORTB, txpin
    sbi DDRB, txpin
    cbi PORTB, rxpin
    cbi DDRB, rxpin
    ;
    ; init ADC
    ;

    ; common pin output low (sink)
    sbi DDRB, c_adc_pin
    cbi PORTB, c_adc_pin
    ; ohm read pin input low
    cbi DDRB, r_adc_pin
    cbi PORTB, r_adc_pin
    ; voltage read pin input low
    cbi DDRB, v_adc_pin
    cbi PORTB, v_adc_pin
    ; ADMUX: Select ADC3, set to 2.56V internal reference
    ldi temp, 0b10010011
    out ADMUX, temp
    ; ADCSRB: Set unipolar, non-inverse.
    ldi temp, 0b00000000
    out ADCSRB, temp
    ; ADCSRA: Enable ADC
    ldi temp, 0b10000000
    out ADCSRA, temp
    ;
    ; start main loop
    ;
    loop:
        ; Start conversion
        sbi ADCSRA, ADSC
        AD_loop:
            sbic ADCSRA, ADSC ; loop until complete
            rjmp AD_loop

        ; send ADC data on serial
        in txbyte, ADCL ; low byte
        rcall putchar
        in txbyte, ADCH ; hi byte
        rcall putchar
        rjmp loop
