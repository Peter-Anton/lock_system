; Nejjednodussi frekventometr s ATtiny2313(A) do 10 MHz. 
; 20 MHz krystal
; vytvoril: DANYK
; http://danyk.cz

.NOLIST
.INCLUDE "tn2313def.inc"
.LIST


.DEF CIF1=R9		;nejnizsi cifra
.DEF CIF2=R10		; ...
.DEF CIF3=R11		; ...
.DEF CIF4=R12		; ...
.DEF CIF5=R13		; ...
.DEF CIF6=R14		; ...
.DEF CIF7=R15		;nejvyssi cifra

.DEF REG=R16		;docasny registr

.DEF UDAJ1=R17		; spodnich 8bitu 24-bitoveho vysledku
.DEF UDAJ2=R18		;
.DEF UDAJ3=R19		; hornich 8bitu 24-bitoveho vysledku

.DEF DELREG=R20		; 2 registry deleni frekvence z 625 na 1 Hz
.DEF DELREG2=R21
.DEF PRETREG=R22	; registr do ktereho preteka 16-bitovy citac1
.DEF MULTREG=R23	; registr si pamatuje stav multiplexu 

.DEF ROZREG=R24		; rozsah


.EQU SMER=DDRB		;PORT displeje - anod segmentu 
.EQU PORT=PORTB
.EQU SMER2=DDRD 	;PORT multiplexu - katod segmentu, vstup
.EQU PORT2=PORTD


.CSEG
.ORG 0
RJMP START

; sem skoci program pri preruseni
.ORG OVF1addr
INC PRETREG
RETI

.ORG OC0Aaddr
RJMP CITAC0


START:
;nastavi port jako vystup
LDI REG,0xFF
OUT SMER,REG
LDI REG,0xFF
OUT PORT,REG

;nastaví bity 0,1,2,3 jako vystup
;nastaví bity 4,5,6 jako vstup
LDI REG,0b00001111
OUT SMER2,REG
LDI REG,0b11010000
OUT PORT2,REG


LDI REG,LOW(RAMEND)
OUT SPL,REG

; vypne analogovy komparator (setri energii).
LDI REG,0b10000000
OUT ACSR,REG

; sleep mod IDLE
LDI REG,0b00100000
OUT MCUCR,REG



; NASTAVENI CITACU/CASOVACU
LDI	REG,0b00000010 	; nastavi citac0 na nulovani pri dosazeni porovnavane...
OUT	TCCR0A,REG    	; ...hodnoty (tzv. CTC), OC0 nevyuzit, deleni 256
LDI	REG,0b00000100 	; 
OUT	TCCR0B,REG 
LDI	REG,124      	; porovnavana hodnota, vznikne 625Hz (multiplex 156,25Hz)
OUT	OCR0A,REG     	; 

LDI	REG,0b00000000	; nastavi citac1 na normalni mod
OUT	TCCR1A,REG    	; 
LDI	REG,0b00000111 	; externi taktovani
OUT	TCCR1B,REG


LDI	REG,0b10000001	; povoli preruseni
OUT	TIMSK,REG    	; (bit 0 povoli citac0A, bit 7 povoli preruseni preteceni1)

; vynuluje/prednastavi registry
CLR REG
LDI DELREG,1
LDI DELREG2,1
CLR PRETREG
LDI MULTREG,1
CLR CIF1
CLR CIF2
CLR CIF3
CLR CIF4
CLR CIF5
CLR CIF6
CLR CIF7

SEI ;povoli globalni preruseni


;hlavni smycka
SMYCKA:
SLEEP
RJMP SMYCKA



MULT:
LDI REG,0b11010000
OUT PORT2,REG

CPI MULTREG,1
BREQ MULT1
CPI MULTREG,2
BREQ MULT2
CPI MULTREG,3
BREQ MULT3
CPI MULTREG,4
BREQ MULT4


MULT1:
MOV REG,CIF1
RCALL ZOBRAZ
CPI ROZREG,3
BRNE TECKA1NE
SUBI REG,128   		;tohle rozsveci tecku
TECKA1NE:
OUT PORT,REG
LDI REG,0b11010001  ;da log1 na bit0 portu. 
OUT PORT2,REG
RET

MULT2:
MOV REG,CIF2
RCALL ZOBRAZ
CPI ROZREG,2
BRNE TECKA2NE
SUBI REG,128   		;tohle rozsveci tecku
TECKA2NE:
OUT PORT,REG
LDI REG,0b11010010  ;da log1 na bit1 portu.
OUT PORT2,REG
RET

MULT3:
MOV REG,CIF3
RCALL ZOBRAZ
CPI ROZREG,1
BRNE TECKA3NE
SUBI REG,128   		;tohle rozsveci tecku
TECKA3NE:
OUT PORT,REG
LDI REG,0b11010100  ;da log1 na bit2 portu.
OUT PORT2,REG
RET

MULT4:
MOV REG,CIF4
RCALL ZOBRAZ
CPI ROZREG,0
BRNE TECKA4NE
SUBI REG,128   		;tohle rozsveci tecku
TECKA4NE:
OUT PORT,REG
LDI REG,0b11011000  ;da log1 na bit3 portu.
OUT PORT2,REG
RET



ZOBRAZ:

CPI REG,0
BREQ ZOBRAZ0
CPI REG,1
BREQ ZOBRAZ1
CPI REG,2
BREQ ZOBRAZ2
CPI REG,3
BREQ ZOBRAZ3
CPI REG,4
BREQ ZOBRAZ4
CPI REG,5
BREQ ZOBRAZ5
CPI REG,6
BREQ ZOBRAZ6
CPI REG,7
BREQ ZOBRAZ7
CPI REG,8
BREQ ZOBRAZ8
CPI REG,9
BREQ ZOBRAZ9

LDI REG,0b11110111
RET

ZOBRAZ0:
LDI REG,0b11000000
RET

ZOBRAZ1:
LDI REG,0b11111001
RET

ZOBRAZ2:
LDI REG,0b10100100
RET

ZOBRAZ3:
LDI REG,0b10110000
RET

ZOBRAZ4:
LDI REG,0b10011001
RET

ZOBRAZ5:
LDI REG,0b10010010
RET

ZOBRAZ6:
LDI REG,0b10000010
RET

ZOBRAZ7:
LDI REG,0b11111000
RET

ZOBRAZ8:
LDI REG,0b10000000
RET

ZOBRAZ9:
LDI REG,0b10010000
RET




OBNOVA:
MOV UDAJ3,PRETREG
IN UDAJ1,TCNT1L
IN UDAJ2,TCNT1H
CLR PRETREG
OUT	TCNT1H,PRETREG
OUT	TCNT1L,PRETREG

CLR ROZREG
CLR CIF1
CLR CIF2
CLR CIF3
CLR CIF4
CLR CIF5
CLR CIF6
CLR CIF7

CPI UDAJ1,128		;24-bitova podminka mensi nez 10 000 000
LDI REG,150
CPC UDAJ2,REG
LDI REG,152
CPC UDAJ3,REG
BRLO DO9999999
SER REG
MOV CIF7,REG
MOV CIF6,REG
MOV CIF5,REG
MOV CIF4,REG
MOV CIF3,REG
MOV CIF2,REG
MOV CIF1,REG
SER ROZREG
RJMP KONEC_OBNOVY
DO9999999:

ZNOVU_7:
CPI UDAJ1,64		;24-bitova podminka mensi nez 1 000 000
LDI REG,66
CPC UDAJ2,REG
LDI REG,15
CPC UDAJ3,REG
BRLO MENSI_7
SUBI UDAJ1,64		;24-bitove odcitání cisla 1 000 000 od vysledku
SBCI UDAJ2,66
SBCI UDAJ3,15
INC CIF7
RJMP ZNOVU_7
MENSI_7:

ZNOVU_6:
CPI UDAJ1,160		;24-bitova podminka mensi nez 100 000
LDI REG,134
CPC UDAJ2,REG
LDI REG,1
CPC UDAJ3,REG
BRLO MENSI_6
SUBI UDAJ1,160		;24-bitove odcitání cisla 100 000 od vysledku
SBCI UDAJ2,134
SBCI UDAJ3,1
INC CIF6
RJMP ZNOVU_6
MENSI_6:

ZNOVU_5:
CPI UDAJ1,16		;24-bitova podminka mensi nez 10 000
LDI REG,39
CPC UDAJ2,REG
LDI REG,0
CPC UDAJ3,REG
BRLO MENSI_5
SUBI UDAJ1,16		;24-bitove odcitání cisla 10 000 od vysledku
SBCI UDAJ2,39
SBCI UDAJ3,0
INC CIF5
RJMP ZNOVU_5
MENSI_5:

ZNOVU_4:
CPI UDAJ1,232		;16-bitova podminka mensi nez 1 000
LDI REG,3
CPC UDAJ2,REG
BRLO MENSI_4
SUBI UDAJ1,232		;16-bitove odcitání cisla 1 000 od vysledku
SBCI UDAJ2,3
INC CIF4
RJMP ZNOVU_4
MENSI_4:

ZNOVU_3:
CPI UDAJ1,100		;16-bitova podminka mensi nez 100
LDI REG,0
CPC UDAJ2,REG
BRLO MENSI_3
SUBI UDAJ1,100		;16-bitove odcitání cisla 100 od vysledku
SBCI UDAJ2,0
INC CIF3
RJMP ZNOVU_3
MENSI_3:

ZNOVU_2:
CPI UDAJ1,10		;8-bitova podminka mensi nez 10
BRLO MENSI_2
SUBI UDAJ1,10		;8-bitove odcitání cisla 10 od vysledku
INC CIF2
RJMP ZNOVU_2
MENSI_2:

MOV CIF1,UDAJ1


POSUN_ZNOVU:
CLR REG
CP CIF7,REG
BRNE POSUN
CP CIF6,REG
BRNE POSUN
CP CIF5,REG
BRNE POSUN
RJMP POSUN_KONEC
POSUN:
MOV CIF1,CIF2
MOV CIF2,CIF3
MOV CIF3,CIF4
MOV CIF4,CIF5
MOV CIF5,CIF6
MOV CIF6,CIF7
CLR CIF7
INC ROZREG
RJMP POSUN_ZNOVU
POSUN_KONEC:

KONEC_OBNOVY:
RET




; preruseni ridici multiplex a zdroj 1Hz
CITAC0:
RCALL MULT
DEC MULTREG
BRNE MULTHOP
LDI MULTREG,4
MULTHOP:

DEC DELREG
BRNE DELHOP
LDI DELREG,125
DEC DELREG2
BRNE DELHOP
LDI DELREG2,5
RCALL OBNOVA
DELHOP:

RETI