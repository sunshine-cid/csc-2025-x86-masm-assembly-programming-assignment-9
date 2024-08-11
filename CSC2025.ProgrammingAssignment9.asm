; Student
; Professor
; Class: CSC 2025 XXX
; Week 9 - Programming Homework #9
; Date
; Interactive program takes a floating point number as input, rounds it to a certain precision level, and displays it in both Decimal and Scientific Notation

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
    
    ; Various messages and strings to be used throughout the program
    msgFloatInput BYTE "Enter a number with at least 5 decimal places: ", 0
    msgFloatOriginal BYTE "The floating point number entered was: ", 0
    msgPrecisionInput BYTE "Enter a precision value between 1 and 4: ",0
    msgPrecisionPreamble BYTE "You selected to set the precision to ",0
    msgPrecisionEnd BYTE " decimal places. ",0
    msgPrecisionOutOfBounds BYTE "The number entered was not between 1 and 4. Please choose another number.", 0
    msgFloatPreamble BYTE "Here's the FLoating Point Number with a Precision of ", 0
    msgFloatScience BYTE " in Scientific Nototion: ",0
    msgFloatDecimal BYTE " in Decimal Nototion: ",0

    orgFloatNumber REAL10 0.0 ; This holds the original typed value for the Float Number
    modFloatNumber REAL10 0.0 ; This holds the Modified value for the Float Number
    intScience DWORD 0 ; This will store the Integer value when doing the *10 * precision and /10 * precision for the Scientific Notation
    integerPart DWORD 0 ; This will store the Integer Part of the Decimal Notation
    fracPart DWORD 0 ; This will store the Fractional Part of the Decimal Notation
    factor REAL4 10.0 ; Factor by which to scale the fractional part
    precision DWORD 1 ; Default level of precision, is almost immediately over-written by the user entered value
    correctiveFactor DWORD 1 ; An integer is required to adjust for rounding problems with Decimal Notation

    strPeriod BYTE ".",0 ; String value of a period to be used when displaying the Decimal Notation

    compFrac DWORD 1000 ; Fraction Comparison value to be decrimented in the CompFracPrecDisplayZero procedure
    compPrec DWORD 4 ; Precision Comparison value to be decrimented in the CompFracPrecDisplayZero procedure

    ctrlRound WORD ? ; Variable to store and edit the rounding mode

.code


;-------------------------------- CompFracPrecDisplayZero Procedure 
;	Functional Details: This procedure takes in information in the form of 
;   variables compFrac(1000) and compPrec(4) as well as fracPart and precision.
;   It then compares fracPart to the initial value of 1000, if fracPart is 
;   greater or equal to EAX(1000) we then test to see if precision is less 
;   than ECX. IF either of those is true we decriment the counter (ECX) and 
;   decriment the EAX register by dividing it by 10. Then we repeat. To 
;   simplify this process allows us to determine if we needed zeros to be 
;   displayed before our decimal number in the decimal notation portion of 
;   our program.
;	Registers:  EAX is used to hold a comparison value(initially 1000), and 
;               later holds zero when we call WriteDec to display leading zeros.
;               EBX holds 10 so we can divide EAX by 10 when we 'decriment' it.
;               ECX holds our precision level which also acts as a counter.
;	Memory Locations: fracPart and precision variables are referenced
CompFracPrecDisplayZero PROC USES EAX EBX ECX
    
CFPDZLoop:

    ; if fracPart < 1000, 100, 10, 1
    cmp fracPart, eax
    jge CFPDZDec
    
    ; && precision >= 4, 3, 2, 1 (ECX)
    cmp precision, ecx
    jl CFPDZDec
    
    ; display 0
    push eax
    mov eax, 0
    call WriteDec
    pop eax

CFPDZDec: ; Loop decriment section
    
    ; The following code 'decriments' eax by dividing it by 10
    mov edx,0
    mov ebx, 10
    div ebx
    
    loop CFPDZLoop ; Automatically decriment ECX

    ret
CompFracPrecDisplayZero ENDP

;-------------------------------- Main Procedure 
;	Functional Details: PRactically this program asks for a floating point 
;   number with 5 decimal places and a precision lkevel. Then the program 
;   rounds that number to the precision level and displays the rounded number 
;   in both Scientific and Decimal Notation.
;	Registers:  ST(0) is used to hold and calculate against floating point 
;               values.
;               EAX is used to take in the precision variable value, and used 
;               to hold integer values which are displayed via WriteDec and 
;               WriteInt.
;               ECX is used repeatedly as a counter during precision calculations.
;               EDX is used repeatedly to hold the offset for strings which 
;               are displayed.
;	Memory Locations: orgFloatNumber holds our original floating point number.
;   modFloatNumber holds the Modified value for the floating point number.
;   intScience stores the integer value when doing the *10 * precision and 
;   /10 * precision for the scientific notation.
;   integerPart stores the integer part of the decimal notation.
;   fracPart stores the fractional part of the decimal notation.
;   factor is the factor by which to scale the fractional part and is also used 
;   to increase and reduce our number position for manual correctional rounding.
;   precision is used to store our user-defined level of precision
;   correctiveFactor is used to store the int 1 which we add to several nukmbers 
;   to get 5 to round correctly to 6. By defauly .55555 is .5555, not .5556
main PROC
    finit ; Initialize the FPU

    ; Display the enter float message
    mov edx, OFFSET msgFloatInput
    call WriteString
    ;Read the float from user input
    call ReadFloat

    ;Store ST(0) in orgFloatNumber, FST doesn't work for some reason, so FSTP it off the stack to store it, then put it back into ST(0)
    fstp orgFloatNumber
    fld orgFloatNumber

    ;Dislpay the numbered entered
    mov edx, OFFSET msgFloatOriginal
    call WriteString
    call WriteFloat
    call Crlf ; Drop down a line for formatting purposes


    ; User enter the precision value
MainPrecisionQuestion:
    
    mov edx, OFFSET msgPrecisionInput
    call WriteString

    ; Specifically read the decimal, and store it in precision
    call ReadDec
    mov precision, eax
    
    ; If precision is >4 Display and error and ask again
    cmp precision, 4
    jg MainPrecisionOutOfBounds

    ; If precision is <1 Display and error and ask again
    cmp precision, 1
    jl MainPrecisionOutOfBounds

    ; Display the 'you chose' precision message
    mov edx, OFFSET msgPrecisionPreamble
    call WriteString
    call WriteDec
    mov edx, OFFSET msgPrecisionEnd
    call WriteString
    call Crlf ; Drop down one line for formatting purposes

    ; ---------- Math for Science Notation
    
    ; Multiply our float by 10 per times of precision
    mov ecx, precision
MainSciencePrecisionLoop:
    fld factor ; ST(0) = 10, ST(1) = After decimal part of floatNumber
    fmulp   
    loop MainSciencePrecisionLoop

    ; We need to scale up by one more precision to have this correctively round
    fld factor
    fmulp
    fld factor
    fmulp

    ; Add the corrective factor so the last number in our decimal rounds correctly
    fild correctiveFactor
    fadd
    
    ; divide back down so our number is in the correct position
    fld factor ; ST(0) = 10
    fdiv
    fld factor
    fdiv

    ; Covert to int which rounds to precision
    fistp intScience

    ; Load from int into flp and divide into correct multiple of 10
    fild intScience
    
    ; Divide by 10 into our correct number position
    mov ecx, precision
MainScienceFactorLoop:
    fld factor ; ST(0) = 10, ST(1) = After decimal part of floatNumber
    fdiv   
    loop MainScienceFactorLoop

    ; Pop ST(0) into modFloatNumber
    fstp modFloatNumber

    ; ---------- Math for Decimal Notation
    ; Load the floating-point number
    fld orgFloatNumber ; ST(0) = orgFloatNumber

    ; In order to get numbers like 555.55555 to truncate properly we need to do some number manipulation
    fld factor ; ST(0) = 10
    fmulp
    
    ; load and subtract the corrective factor. Since we're truncating we need to reduce the number by 4, otherwise improper representation happens (i.e 999.99999 becomes 999.10000)
    fild correctiveFactor
    fsub
    fild correctiveFactor
    fsub
    fild correctiveFactor
    fsub
    fild correctiveFactor
    fsub

    ; Divide back down to our number
    fld factor ; ST(0) = 10
    fdiv

    ; Extract the integer part
    fistp integerPart ; Convert ST(0) to integer and store in integerPart

    ; Reload the floating-point number
    fld orgFloatNumber ; ST(0) = floatNumber
    fild integerPart ; ST(0) = integerPart
    fsub ; ST(0) = modFloatNumber - integerPart (fractional part)
    fabs ; ABS the fractional part to correct negative and calculation errors

    ; Convert the fractional part to an integer by multiplying by [factor] [precision] times
    mov ecx, precision
MainDecimalPrecisionLoop:
    fld factor ; ST(0) = 10, ST(1) = After decimal part of floatNumber
    fmulp ; ST(0) = 10 * fracPart
    loop MainDecimalPrecisionLoop
    
    ; We need to scale up by one more precision to have this correctively round
    fld factor
    fmulp

    ; Add the corrective factor so the last number in our decimal rounds correctly
    fild correctiveFactor
    fadd

    ; divide back down so our number is in the correct position
    fld factor ; ST(0) = 10
    fdiv

    fistp fracPart ; Convert to integer and store in fracPart

    ; Display our number in Decimal Notation
    ; Display the float preamble message
    mov edx, OFFSET msgFloatPreamble
    call WriteString

    ; Display the precision number
    mov eax, precision
    call WriteDec
    
    ; Dislpaly the Decimal Notation message
    mov edx, OFFSET msgFloatDecimal
    call WriteString

    ; Display the integer part
    mov eax, integerPart
    call WriteInt

    ; Display the decimal point
    mov edx, OFFSET strPeriod
    call WriteString

    ; Display the fractional part
    ; First, we need to check to see if there were any leading zeros, and if so display them
    mov eax, compFrac ; move into eax the comparitive fraction value
    mov ecx, compPrec ; move into ecx the comparitive precision value
    call CompFracPrecDisplayZero

    ; Then we move the fractional part into EAX for display
    mov eax, fracPart
    ; But first, if fracPart equals zero it was already displayed by CompFracPrecDisplayZero, so it can be skipped
    cmp fracPart, 0
    je MainDecimalSkipZero

    ;Otherwise display the fractional part
    call WriteDec

MainDecimalSkipZero:

    call Crlf ; Line feed for formatting purposes

    ; Display floatNumber in Scientific Notation
    ; Diaplay the float message preamble
    mov edx, OFFSET msgFloatPreamble
    call WriteString

    ; Display the precision value
    mov eax, precision
    call WriteDec
    
    ; Dislpaly the Scientific Notation message
    mov edx, OFFSET msgFloatScience
    call WriteString

    ; Load the modified Float Number to be displayed in Scientific Notation by WriteFloat
    fld modFloatNumber
    call WriteFloat ; Documentation should say this DOESN'T pop ST(0) off the fStack

    call Crlf ; Line feed for formatting purposes

    ; End the program
    exit

; This section is the jump point for if the user entered precision value was under 1 or over 4
MainPrecisionOutOfBounds:

    ; Dislpay the precision out of bounds error message, return to ask for precision input again
    mov edx, OFFSET msgPrecisionOutOfBounds
    call WriteString
    call Crlf ; Line feed for formatting purposes

jmp MainPrecisionQuestion

main ENDP

END main
