.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FLAPPY BIRD
;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern rand: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

; sirlen1 DD 170, 210, 50, 120, 190, 260, 110, 60, 140, 230
; sirlen2 DD 120, 70, 240, 170, 90, 30, 180, 230, 150, 50
; sirydown DD 292, 342, 172, 242, 322, 382, 252, 182, 192, 362

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

bird_dimensions EQU 40

include digits.inc
include letters.inc
include bird.inc

ok dd 0
cont dd 0

patrat_x dd 295
patrat_y dd 215

prizex dd 610
prizey dd 205

obstacle_x1 dd 610
obstacle_x2 dd 610
obstacle_x3 dd 610

obstacle_yup dd 0

obstacle_ydown1 dd 292
obstacle_ydown2 dd 342
obstacle_ydown3 dd 172

lenup1 dd 170
lenup2 dd 210
lenup3 dd 50

lendown1 dd 120
lendown2 dd 70
lendown3 dd 240

iscollision DD 0
colect dd 1

ok1 dd 1
ok2 dd 1
ok3 dd 1
vitezaobs dd 15
okvit dd 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

del_square macro x, y
local loopsq, loopsq1
	mov eax, y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax,ebx
	shl eax,2
	add eax,area
	mov ecx, 40
	mov ebx,40
loopsq:
	mov ecx, 40
loopsq1:
	mov dword ptr[eax], 0FFFFFFh
	add eax,4
loop loopsq1
	
	sub eax,160
	dec ebx
	mov ecx, ebx
	add eax,area_width * 4
loop loopsq
	mov ecx, 40

endm


make_bird macro x, y
local loopsq, loopsq1, simbol_pixel_alb, simbol_pixel_next
mov edx, y
	lea esi, bird
	cmp edx,0
	jl fin
	mov edx, y
	cmp edx,480
	jg fin
	
	mov eax, y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax,ebx
	shl eax,2
	add eax,area
	mov ecx, 40
	mov ebx,40
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	
	;-----------------------------------------------------------
loopsq:
	mov ecx, 40
loopsq1:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [eax], 0
	jmp simbol_pixel_next
	
	mov dword ptr[eax], 0cae9FFh
	simbol_pixel_alb: 
	mov dword ptr[eax], 0FFFFFFh
	simbol_pixel_next:
	add eax,4
	inc esi
loop loopsq1
	sub eax,160
	dec ebx
	mov ecx, ebx
	add eax,area_width * 4
loop loopsq
	mov ecx, 40
fin:


endm	
	
make_square macro x, y
local loopsq, loopsq1, fin
	mov edx, y
	cmp edx,0
	jl fin
	mov edx, y
	cmp edx,480
	jg fin
	
	mov eax, y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax,ebx
	shl eax,2
	add eax,area
	mov ecx, 10
	mov ebx, 10
loopsq:
	mov ecx, 10
loopsq1:
	mov dword ptr[eax], 0AA00FFh
	add eax,4
loop loopsq1
	sub eax, 40
	dec ebx
	mov ecx, ebx
	add eax,area_width * 4
loop loopsq
	mov ecx, 10
fin:
	
endm
	
make_line macro x, y
local loopob, loopob1
	mov eax, y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax,ebx
	shl eax,2
	add eax,area
	mov ecx, area_width
	mov ebx, 10
loopob:
	mov ecx, area_width
loopob1:
	mov dword ptr[eax], 0b99e99h
	add eax,4
loop loopob1
	
	sub eax, 2560
	dec ebx
	mov ecx, ebx
	add eax,area_width * 4
loop loopob
	mov ecx, area_width
	
endm
	
make_obstacle macro x, y, heightob
local loopob, loopob1
	mov eax, y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax,ebx
	shl eax,2
	add eax,area
	mov ecx, 30
	mov ebx, heightob
loopob:
	mov ecx, 30
loopob1:
	mov dword ptr[eax], 0FFAADDh
	add eax,4
loop loopob1
	
	sub eax, 120
	dec ebx
	mov ecx, ebx
	add eax,area_width * 4
loop loopob
	mov ecx, 30
	
endm


del_obstacle macro x, y, heightob
local loopob, loopob1
	mov eax, y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax,ebx
	shl eax,2
	add eax,area
	mov ecx, 30
	mov ebx, heightob
loopob:
	mov ecx, 30
loopob1:
	mov dword ptr[eax], 0FFFFFFh
	add eax,4
loop loopob1
	
	sub eax,120
	dec ebx
	mov ecx, ebx
	add eax,area_width * 4
loop loopob
	mov ecx, 30
	
endm

collisionmargini macro py
local fin1, isocs
    ; mov ebx, py
    ; cmp ebx, 10
	; jg fin1
	mov ebx, py
	cmp ebx, 10
	jl isocs
	
	mov ebx, py
	cmp ebx, 360
	jg isocs
	
	; mov ebx, py
	; cmp ebx, 370
	; jl fin1
jmp fin1
isocs:
mov iscollision, 1

fin1:

endm

collision macro obx, oby, obh, px, py
local fin1
	mov ebx, px
	add ebx, 34
	cmp ebx, obx
	jl fin1

	mov ebx, obx
	add ebx, 30
	cmp px, ebx
	jg fin1
	
	mov ebx, oby
	add ebx, obh
	cmp py, ebx
	jg fin1
	
	mov ebx, py
	add ebx, 36
	cmp ebx, oby
	jl fin1

mov iscollision, 1
fin1:

endm

collect macro obx, oby, px, py
local fin1
	mov ebx, px
	add ebx, 40
	cmp ebx, obx
	jl fin1

	mov ebx, obx
	add ebx, 10
	cmp px, ebx
	jg fin1
	
	mov ebx, oby
	add ebx, 10
	cmp py, ebx
	jg fin1
	
	mov ebx, py
	add ebx, 40
	cmp ebx, oby
	jl fin1

mov colect, 0

fin1:	

endm




; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax,iscollision
	cmp eax,1
	je collab
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	del_square patrat_x,patrat_y
	sub patrat_y, 50
	
	jmp afisare_litere
	
evt_timer:
	inc counter
	del_square patrat_x,patrat_y
	add patrat_y, 20
	
evt_scor:
	
	mov ebx, patrat_x
	cmp ebx, obstacle_x1
	jl cnt1
	mov ecx, ok1
	cmp ecx, 1
	jne cnt1
	inc cont
	mov ok1, 0
	cnt1:
	
	mov ebx, patrat_x
	cmp ebx, obstacle_x2
	jl cnt2
	mov ecx, ok2
	cmp ecx, 1
	jne cnt2
	inc cont
	mov ok2, 0
	cnt2:
	
	mov ebx, patrat_x
	cmp ebx, obstacle_x3
	jl cnt3
	mov ecx, ok3
	cmp ecx, 1
	jne cnt3
	inc cont
	mov ok3, 0
	cnt3:

afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 520, 440
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 510, 440
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 500, 440
	
	mov eax, cont
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 360, 440
	
	;scriem un mesaj
	make_text_macro 'P', area, 30, 420
	make_text_macro 'R', area, 40, 420
	make_text_macro 'O', area, 50, 420
	make_text_macro 'I', area, 60, 420
	make_text_macro 'E', area, 70, 420
	make_text_macro 'C', area, 80, 420
	make_text_macro 'T', area, 90, 420
	
	make_text_macro 'L', area, 50, 440
	make_text_macro 'A', area, 60, 440
	
	make_text_macro 'A', area, 20, 460
	make_text_macro 'S', area, 30, 460
	make_text_macro 'A', area, 40, 460
	make_text_macro 'M', area, 50, 460
	make_text_macro 'B', area, 60, 460
	make_text_macro 'L', area, 70, 460
	make_text_macro 'A', area, 80, 460
	make_text_macro 'R', area, 90, 460
	make_text_macro 'E', area, 100, 460
	
	del_square prizex, prizey
	del_obstacle obstacle_x1, obstacle_yup, lenup1
	del_obstacle obstacle_x1, obstacle_ydown1, lendown1
	del_obstacle obstacle_x2, obstacle_yup, lenup2
	del_obstacle obstacle_x2, obstacle_ydown2, lendown2
	del_obstacle obstacle_x3, obstacle_yup, lenup3
	del_obstacle obstacle_x3, obstacle_ydown3, lendown3
	
	mov eax, cont
	mov ebx, 3
	div ebx
	cmp edx, 0
	jne nuinc
	cmp okvit, 1
	jne nuinc
	add vitezaobs, 3
	mov okvit, 0
	nuinc:
	
	cmp obstacle_x1, 20
	jle arrayinit1
	mov ebx, vitezaobs
	sub obstacle_x1, ebx
	jmp jumpinstr1
	arrayinit1: 
		mov obstacle_x1, 620
		mov ok1, 1
	mov ebx, 290
	call rand
	div ebx
	mov lenup1, edx
	mov obstacle_ydown1, edx
	add obstacle_ydown1, 120
	mov ecx, 412
	sub ecx, obstacle_ydown1
	mov lendown1, ecx
	jumpinstr1:
	
	cmp obstacle_x2, 15
	jle arrayinit2
	cmp counter,11
	jl ob12
	mov ebx, vitezaobs
	sub obstacle_x2, ebx
	ob12:
	jmp jumpinstr2
	arrayinit2: 
		mov obstacle_x2, 620
		mov ok2, 1
	mov ebx, 290;
	call rand
	div ebx
	mov lenup2, edx
	mov obstacle_ydown2, edx
	add obstacle_ydown2, 120
	mov ecx, 412
	sub ecx, obstacle_ydown2
	mov lendown2, ecx
	jumpinstr2:
	
	cmp obstacle_x3, 20
	jle arrayinit3
	cmp counter,22
	jl ob13
	mov ebx, vitezaobs
	sub obstacle_x3, ebx
	ob13:
	jmp jumpinstr3
	arrayinit3: 
		mov obstacle_x3, 620
		mov ok3, 1
	mov ebx, 290
	call rand
	div ebx
	mov lenup3, edx
	mov obstacle_ydown3, edx
	add obstacle_ydown3, 120
	mov ecx, 412
	sub ecx, obstacle_ydown3
	mov lendown3, ecx
	jumpinstr3:
	
	cmp prizex, 20
	jle arrayinit4
	sub prizex, 14
	jmp jumpinstr4
	arrayinit4: 
	mov ebx, 390
	call rand
	div ebx
	mov prizey, edx
		mov prizex, 620
	jumpinstr4:
	
	collab:
	mov ebx, colect
	cmp ebx, 0
	je notcollect
	
	make_square prizex, prizey
	
	notcollect:
	
	cmp prizex, 620
	jl numov
	mov colect, 1
	numov:
	
	make_bird patrat_x, patrat_y
	make_obstacle obstacle_x1, obstacle_yup, lenup1
	make_obstacle obstacle_x1, obstacle_ydown1, lendown1
	cmp counter,11
	jl ob1
	make_obstacle obstacle_x2, obstacle_yup, lenup2
	make_obstacle obstacle_x2, obstacle_ydown2, lendown2
	ob1:
	cmp counter,22
	jl ob2
	make_obstacle obstacle_x3, obstacle_yup, lenup3
	make_obstacle obstacle_x3, obstacle_ydown3, lendown3
	ob2:
	
	collect prizex, prizey,patrat_x, patrat_y
	collisionmargini patrat_y
	collision obstacle_x1, obstacle_yup, lenup1, patrat_x, patrat_y
	collision obstacle_x1, obstacle_ydown1, lendown1, patrat_x, patrat_y
	collision obstacle_x2, obstacle_yup, lenup2, patrat_x, patrat_y
	collision obstacle_x2, obstacle_ydown2, lendown2, patrat_x, patrat_y
	collision obstacle_x3, obstacle_yup, lenup3, patrat_x, patrat_y
	collision obstacle_x3, obstacle_ydown3, lendown3, patrat_x, patrat_y
	
	mov eax, iscollision
	cmp eax, 0 
	je col
	make_text_macro 'G', area, 250, 440
	make_text_macro 'A', area, 260, 440
	make_text_macro 'M', area, 270, 440
	make_text_macro 'E', area, 280, 440
	make_text_macro 'O', area, 290, 440
	make_text_macro 'V', area, 300, 440
	make_text_macro 'E', area, 310, 440
	make_text_macro 'R', area, 320, 440
	col:
	
	make_line 1, 0
	make_line 1, 410
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);

	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
