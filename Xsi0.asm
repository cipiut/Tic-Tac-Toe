.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "X si O",0
area_width EQU 360
area_height EQU 380
area DD 0
format db "%d %d",10,0

;date pentru verificare matrice
;matrice 
m1 	dd 0,0,0
	dd 0,0,0
	dd 0,0,0
;pozitia mouse-ului in canvas
xpos DD 0
ypos DD 0
;Contor pentru mutare
mutare DD 1
;Cand ajunge la 9 insemna ca e egal
contor_egalitate DD 0
;Game_State
GameOver DD 0
;salvam datele din registre pt verificare GameOver
save1 dd 0
save2 dd 0
save3 dd 0
save4 dd 0

;variabilele pentru scor
zeciX dd 0
zeciY dd 0
unitatiX dd 0
unitatiY dd 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 20
symbol_height EQU 20
include digits.inc
include letters.inc

.code
;verificare linie ,coloana si diagonala
linie macro n
local et_1,et_rau,et_bine,gata
	mov save1,ecx
	mov save2,ebx
	mov save3,edx
	mov save4,esi
	et_1:
	mov ecx,12
	mov eax , n
	mul ecx
	mov esi ,eax
	mov eax ,0
	mov ecx,m1[esi][0]
	mov ebx,m1[esi][4]
	mov edx,m1[esi][8]
		cmp ecx,ebx
		jne et_rau
		cmp ebx,edx
		jne et_rau
		jmp et_bine
	et_rau:
		mov eax,0
		jmp gata
	et_bine:
		mov eax,1
		cmp ecx,eax
		je gata
		mov eax,2
		cmp ecx,eax
		je gata
		mov eax ,0
		jmp gata
	gata:
		mov ecx,save1
		mov ebx,save2
		mov edx,save3
		mov esi,save4
ENDM

coloana macro n
local et_1,et_rau,et_bine,gata
	mov save1,ecx
	mov save2,ebx
	mov save3,edx
	mov save4,esi
	et_1:
	mov ecx,4
	mov eax , n
	mul ecx
	mov esi ,eax
	mov eax ,0
	mov ecx,m1[0][esi]
	mov ebx,m1[12][esi]
	mov edx,m1[24][esi]
		cmp ecx,ebx
		jne et_rau
		cmp ebx,edx
		jne et_rau
		jmp et_bine
	et_rau:
		mov eax,0
		jmp gata
	et_bine:
		mov eax,1
		cmp ecx,eax
		je gata
		mov eax,2
		cmp ecx,eax
		je gata
		mov eax ,0
		jmp gata
	gata:
		mov ecx,save1
		mov ebx,save2
		mov edx,save3
		mov esi,save4
ENDM

diagonala macro n
local p,et_1,et_2,et_bine,et_rau,gata
	mov save1,ecx
	mov save2,ebx
	mov save3,edx
	mov save4,esi
	p:
		mov eax ,0
		cmp eax,n
		je et_1
	et_2:
		mov ecx,m1[0][8]
		mov ebx,m1[12][4]
		mov edx,m1[24][0]
		cmp ecx,ebx
		jne et_rau
		cmp ebx,edx
		jne et_rau
		jmp et_bine
	et_1:
		mov ecx,m1[0][0]
		mov ebx,m1[12][4]
		mov edx,m1[24][8]
		cmp ecx,ebx
		jne et_rau
		cmp ebx,edx
		jne et_rau
		jmp et_bine
	et_rau:
		mov eax,0
		jmp gata
	et_bine:
		mov eax,1
		cmp ecx,eax
		je gata
		mov eax,2
		cmp ecx,eax
		je gata
		mov eax ,0
		jmp gata
	
	gata:
		mov ecx,save1
		mov ebx,save2
		mov edx,save3
		mov esi,save4
	
ENDM

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

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	jmp afisare_litere
	
evt_click:
	mov ebx,[ebp+arg2]
	mov xpos,ebx
	mov edx,mutare
	mov ebx,[ebp+arg3]
	mov ypos,ebx
	;verificam daca suntem pe tabla de joc
	jmp reset
	mutare_et:
		Eroare:
		cmp GameOver,0
		jne mutare_contor
		linie 0
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		linie 1
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		linie 2
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		coloana 0
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		coloana 1
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		coloana 2
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		diagonala 0
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		diagonala 1
		cmp eax,0
		jne Verifcare_linie_coloana_diagonala
		
		Verifcare_linie_coloana_diagonala:
			mov GameOver,eax
			cmp GameOver,1
			je Xcastiga
			cmp GameOver,2
			je Ycastiga
			jmp mutare_contor
			
			Xcastiga:
				inc unitatiX
				cmp unitatiX,10
				je zeciX0
				jmp mutare_contor
				zeciX0:
					mov unitatiX,0
					inc zeciX
					jmp mutare_contor
	
			Ycastiga:
				inc unitatiY
				cmp unitatiY,10
				je zeciY0
				jmp mutare_contor
				zeciY0:
					mov unitatiY,0
					inc zeciY
					jmp mutare_contor
			
		mutare_contor:
			cmp edx,1
			jne mutare2
			inc edx
			add contor_egalitate,1
			jmp iesire
			mutare2:
			dec edx
			add contor_egalitate,1
			jmp iesire
			
	reset:
	cmp xpos ,170
	ja urm1
	jmp verif_mat
		urm1:
		cmp ypos ,300
		ja urm2
		jmp verif_mat
			urm2:
			cmp xpos ,190
			jb urm3
			jmp verif_mat
				urm3:
				cmp ypos ,320
				jb urm4
				jmp verif_mat
				urm4:
				mov esi,0
				afisare_mat:
				mov m1[esi][0],0
				mov m1[esi][4],0
				mov m1[esi][8],0
				add esi,12
					cmp esi ,36
					jb afisare_mat
				mov edx ,1
				mov contor_egalitate,0
				mov GameOver,0
				jmp iesire	
				
	verif_mat:
	cmp xpos ,290
	ja iesire
	cmp ypos ,240
	ja iesire
	cmp xpos ,70
	jb iesire
	cmp ypos ,80
	jb iesire
	
	cmp ypos ,190
	jb continuare
		cmp xpos ,140
			ja continuare
			cmp m1[24][0],0
			jne iesire
			mov m1[24][0],edx
			jmp mutare_et

	continuare:
	cmp ypos ,190
	jb continuare1
		cmp xpos ,220
			ja continuare1
			cmp m1[24][4],0
			jne iesire
			mov m1[24][4],edx
			jmp mutare_et

	continuare1:
	cmp ypos ,190
	jb continuare2
		cmp xpos ,290
			ja continuare2
			cmp m1[24][8],0
			jne iesire
			mov m1[24][8],edx
			jmp mutare_et
			
	continuare2:
	cmp ypos ,130
	jb continuare3
		cmp xpos ,140
			ja continuare3
			cmp m1[12][0],0
			jne iesire
			mov m1[12][0],edx
			jmp mutare_et
			
	continuare3:
	cmp ypos ,130
	jb continuare4
		cmp xpos ,220
			ja continuare4
			cmp m1[12][4],0
			jne iesire
			mov m1[12][4],edx
			jmp mutare_et
			
	continuare4:
	cmp ypos ,130
		jb continuare5
			cmp xpos ,290
			ja continuare5
			cmp m1[12][8],0
			jne iesire
			mov m1[12][8],edx
			jmp mutare_et
			
	continuare5:
	cmp ypos ,80
		jb continuare6
			cmp xpos ,140
			ja continuare6
			cmp m1[0][0],0
			jne iesire
			mov m1[0][0],edx
			jmp mutare_et
			
	continuare6:
	cmp ypos ,80
		jb continuare7
			cmp xpos ,220
			ja continuare7
			cmp m1[0][4],0
			jne iesire
			mov m1[0][4],edx
			jmp mutare_et
			
	continuare7:
		cmp m1[0][8],0
		jne iesire
		mov m1[0][8],edx
		jmp mutare_et	
		
	iesire:
	mov mutare ,edx;
	mov edi, area
	mov ecx, area_height
	mov ebx, [ebp+arg3]
	and ebx, 7

afisare_litere:
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	scor:
	make_text_macro 'X', area, 20, 10
	make_text_macro 'U', area, 40, 12
	make_text_macro 'U', area, 40, 37
	make_text_macro 'O', area, 20, 35
	add unitatiX,48
	make_text_macro unitatiX, area, 70, 10
	sub unitatiX,48
	add unitatiY,48
	make_text_macro unitatiY, area, 70, 35
	sub unitatiY,48
	
	AfisScorX:
	cmp zeciX,0
	je AfisScor0
	add zeciX,48
	make_text_macro zeciX, area, 50, 10
	sub zeciX,48
	
	AfisScor0:
	cmp zeciY,0
	je text_reset
	add zeciY,48
	make_text_macro zeciY, area, 50, 35
	sub zeciY,48
	
	;reset
	text_reset:
	make_text_macro 'R', area, 170, 300
	
	;Verficare pentru X
	vf1:
	cmp GameOver,1
	je game_state1
		jmp vf2
		game_state1:
		make_text_macro 'X', area, 130, 160
		make_text_macro 'W', area, 170, 160
		make_text_macro 'I', area, 190, 160
		make_text_macro 'N', area, 210, 160
		make_text_macro 'S', area, 230, 160
		jmp final_draw
	
	;Verficare pentru O
	vf2:
	cmp GameOver,2
	je game_state2
		jmp vf3
		game_state2:
		make_text_macro 'O', area, 130, 160
		make_text_macro 'W', area, 170, 160
		make_text_macro 'I', area, 190, 160
		make_text_macro 'N', area, 210, 160
		make_text_macro 'S', area, 230, 160
		jmp final_draw
	;Verficare pentru EGALITATE
	vf3:
	cmp GameOver,0
	je game_state3
		game_state3:
		cmp contor_egalitate,9
		jne afisare_Tabla
		make_text_macro 'E', area, 90, 160
		make_text_macro 'G', area, 110, 160
		make_text_macro 'D', area, 130, 160
		make_text_macro 'L', area, 150, 160
		make_text_macro 'I', area, 170, 160
		make_text_macro 'T', area, 190, 160
		make_text_macro 'D', area, 210, 160
		make_text_macro 'T', area, 230, 160
		make_text_macro 'E', area, 250, 160
		jmp final_draw
		
	afisare_Tabla:
	
	make_text_macro 'A', area, 130, 80
	make_text_macro 'A', area, 130, 100
	make_text_macro 'A', area, 130, 120
	make_text_macro 'A', area, 130, 140
	make_text_macro 'A', area, 130, 160
	make_text_macro 'A', area, 130, 180
	make_text_macro 'A', area, 130, 200
	make_text_macro 'A', area, 130, 220

	make_text_macro 'A', area, 210, 80
	make_text_macro 'A', area, 210, 100
	make_text_macro 'A', area, 210, 120
	make_text_macro 'A', area, 210, 140
	make_text_macro 'A', area, 210, 160
	make_text_macro 'A', area, 210, 180
	make_text_macro 'A', area, 210, 200
	make_text_macro 'A', area, 210, 220

	make_text_macro 'B', area, 70, 120
	make_text_macro 'B', area, 90, 120
	make_text_macro 'B', area, 110, 120
	make_text_macro 'C', area, 130, 120
	make_text_macro 'B', area, 150, 120
	make_text_macro 'B', area, 170, 120
	make_text_macro 'B', area, 190, 120
	make_text_macro 'C', area, 210, 120
	make_text_macro 'B', area, 230, 120
	make_text_macro 'B', area, 250, 120
	make_text_macro 'B', area, 270, 120

	make_text_macro 'B', area, 70, 180
	make_text_macro 'B', area, 90, 180
	make_text_macro 'B', area, 110, 180
	make_text_macro 'C', area, 130, 180
	make_text_macro 'B', area, 150, 180
	make_text_macro 'B', area, 170, 180
	make_text_macro 'B', area, 190, 180
	make_text_macro 'C', area, 210, 180
	make_text_macro 'B', area, 230, 180
	make_text_macro 'B', area, 250, 180
	make_text_macro 'B', area, 270, 180
	
	
	;afisam obiectele in matrice
	cmp m1[0][0],1
	jne sari1
	make_text_macro 'X', area, 95, 95
	sari1:
	cmp m1[0][0],2
	jne sari2
	make_text_macro 'O', area, 95, 95
	sari2:
	
	cmp m1[0][4],1
	jne sari3
	make_text_macro 'X', area, 170,95
	sari3:
	cmp m1[0][4],2
	jne sari4
	make_text_macro 'O', area, 170,95
	sari4:
	
	cmp m1[0][8],1
	jne sari5
	make_text_macro 'X', area, 245,95
	sari5:
	cmp m1[0][8],2
	jne sari6
	make_text_macro 'O', area, 245,95
	sari6:
	
	cmp m1[12][0],1
	jne sari7
	make_text_macro 'X', area, 95,150
	sari7:
	cmp m1[12][0],2
	jne sari8
	make_text_macro 'O', area, 95,150
	sari8:
	
	cmp m1[12][4],1
	jne sari9
	make_text_macro 'X', area, 170,150
	sari9:
	cmp m1[12][4],2
	jne sari10
	make_text_macro 'O', area, 170,150
	sari10:
	
	cmp m1[12][8],1
	jne sari11
	make_text_macro 'X', area, 245,150
	sari11:
	cmp m1[12][8],2
	jne sari12
	make_text_macro 'O', area, 245,150
	sari12:
	
	cmp m1[24][0],1
	jne sari13
	make_text_macro 'X', area, 95,210
	sari13:
	cmp m1[24][0],2
	jne sari14
	make_text_macro 'O', area, 95,210
	sari14:
	
	cmp m1[24][4],1
	jne sari15
	make_text_macro 'X', area, 170,210
	sari15:
	cmp m1[24][4],2
	jne sari16
	make_text_macro 'O', area, 170,210
	sari16:
	
	cmp m1[24][8],1
	jne sari17
	make_text_macro 'X', area, 245,210
	sari17:
	cmp m1[24][8],2
	jne final_draw
	make_text_macro 'O', area, 245,210
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	push 0
	call exit
end start
