'Frequenzzähler bis ca. 5 MHz, mit ex. 20 MHz Oszillator
'in Anlehnung an Elektor 7-8 2005 70 / Hergen Breitzke
$regfile = "ATtiny2313.dat"   'spezifiziert den Prozessor
$crystal = 20000000           'benutzt den exernen Oszillator ohne Teiler durch 8
'Lock Bits auf ext. Oszillator setzen nicht vergessen!
Config Pind.1 = Output        'LED für Torzeit
Config Pind.0 = Input         'Taster für ungekürzte Anzeige
Portd.0 = 1                   'pull-up R ein
Config Lcdpin = Pin , Db4 = Portb.1 , Db5 = Portb.2 , Db6 = Portb.3 , Db7 = Portb.4 , E = Portb.0 , Rs = Portd.6
Config Lcd = 16 * 2
Config Lcdbus = 4
Config Lcdmode = Port
Config Timer0 = Timer , Prescale = 1024
Config Timer1 = Counter , Edge = Rising

'*******************************************
Dim Temp As Long              'to ensure proper calculations these variables have to be "long"
Dim Ovf0 As Long
Dim Ovf1 As Long
Dim Freq As Long
Dim Anzeige As String * 7
Dim Anzeigevorne As String * 3
Dim Anzeigehinten As String * 4
Dim Pos As Byte

Enable Interrupts
Enable Timer0                 'Timer interrupt
On Timer0 Incr_ovf0
Enable Timer1                 'Counter interrrupt
On Timer1 Incr_ovfl

'************** main loop ***********************
Cls
Lcd "Start"
Do
   Portd.1 = 1                'Zählertor auf
   Timer0 = 0                 'reset timer and counter
   Counter1 = 0
   Ovf0 = 0
   Ovf1 = 0

   While Ovf0 <= 75           'little bit less then one second loop @ 20 MHz
   nop
   Wend
   Waitus 3900                'compensate the timing error
   Portd.1 = 0                'Zählertor zu
   Disable Timer0             'Stop Timer0
   Disable Counter1           'stop the counter

   Temp = Ovf1 * 65536        'calculate the frequency
   Freq = Temp + Counter1
   Cls                        'LCD löschen
   Locate 1 , 1
   Anzeige = Str(freq)

   Select Case Freq
   Case Is >= 1000000 : Goto Mhz
   Case Is >= 100000 : Goto Khzxxx
   Case Is >= 10000 : Goto Khzxx
   Case Is > 1000 : Goto Khzx
   End Select

'1-999 Hz Bereich
   Pos = 7 - Len(anzeige)
   Locate 1 , Pos
   Lcd Freq ; " Hz"
   Goto Weitergehts

Mhz:
   Anzeigevorne = Left(anzeige , 1)
   Anzeigehinten = Mid(anzeige , 2 , 4)
   Lcd Anzeigevorne ; "." ; Anzeigehinten ; " MHz"
   Goto Weitergehts
Khzxxx:
   Anzeigevorne = Left(anzeige , 3)
   Anzeigehinten = Mid(anzeige , 4 , 2)
   Lcd Anzeigevorne ; "." ; Anzeigehinten ; " KHz"
   Goto Weitergehts
Khzxx:
   Anzeigevorne = Left(anzeige , 2 )
   Anzeigehinten = Mid(anzeige , 3 , 3)
   Lcd Anzeigevorne ; "." ; Anzeigehinten ; " KHz"
   Goto Weitergehts
Khzx:
   Anzeigevorne = Left(anzeige , 1 )
   Anzeigehinten = Mid(anzeige , 2 , 4)
   Lcd " " ; Anzeigevorne ; "." ; Anzeigehinten ; " KHz"
   Goto Weitergehts

Weitergehts:
Locate 2 , 1                  'zweite LCD-Zeile ansteuern
If Pind.0 = 0 Then Lcd Anzeige ; " Hz"       ' Taster gedrückt: ungekürzte Anzeige in Zeile 2

   Cursor Off
   'start the timer and counter
   Enable Timer0
   Enable Counter1
Loop

'*****************************************
Incr_ovfl:
   Incr Ovf1                  'increment timer interrupt counting variable
   Return

'*****************************************
Incr_ovf0:
   Incr Ovf0                  'increment counter interrupt counting variable
   Return

End                           'end program