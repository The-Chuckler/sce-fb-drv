; S1 git disasm prefixes go brrrrr
; lol, i rlly like them tbh
; We need to just take the javascript
; we wrote and convert it to asm
; then make a display using sprites
; or some thinge
; "THE NEXT CODE COULD BE ANYTHINGE!!
; PREPAREST THINE ASS"



GM_CubeTest:
 music	mus_Stop									; stop music
 jsr	(Clear_KosPlus_Module_Queue).w							; clear KosPlusM PLCs
 ResetDMAQueue										; clear DMA queue
 jsr	(Pal_FadeToBlack).w
 disableInts
 move.l	#VInt,(V_int_addr).w
 move.l	#HInt,(H_int_addr).w
 disableScreen
 jsr	(Clear_DisplayData).w
 lea	Level_VDP(pc),a1
 jsr	(Load_VDP).w
 jsr	(Clear_Palette).w
 clearRAM RAM_start, (RAM_start+$2000)							; clear foreground buffers
 clearRAM Object_RAM, Object_RAM_end							; clear the object RAM
 clearRAM Lag_frame_count, Lag_frame_count_end						; clear variables
 clearRAM Camera_RAM, Camera_RAM_end							; clear the camera RAM
 clearRAM Oscillating_variables, Oscillating_variables_end				; clear variables

	; clear
 move.b	d0,(Water_full_screen_flag).w
 move.b	d0,(Water_flag).w
 move.w	d0,(Current_zone_and_act).w
 move.w	d0,(Apparent_zone_and_act).w
 move.b	d0,(Last_star_post_hit).w
 move.b	d0,(Debug_mode_flag).w

	; load main palette
 lea (Pal_Custom4TitCrd).l,a1
 lea	(Target_palette).w,a2
 jsr	(PalLoad_Line32).w

 lea (Map_ScrBuf).l,a1
 move.l	#vdpComm(VRAM_Plane_A_Name_Table,VRAM,WRITE),d0
 moveq	#40-1,d1
 moveq	#28-1,d2
 jsr	(Plane_Map_To_VRAM).l		; Copy screen mappings to VRAM

.waitplc
 move.b	#VintID_Fade,(V_int_routine).w
 jsr	(Process_KosPlus_Queue).w
 jsr	(Wait_VSync).w
 jsr	(Process_KosPlus_Module_Queue).w
 tst.w	(KosPlus_modules_left).w
 bne.s	.waitplc

scrbufsz = (ArtUnc_PlH_end - ArtUnc_PlH)

	; Load uncompressed art:
 lea (ArtUnc_PlH).l,a0
 lea (ScrRAMbuff).l,a1
 move.w #bytesToLcnt(scrbufsz),d0

.MvArtToRam
 move.l (a0)+,(a1)+
 dbf d0, .MvArtToRam

 move.b	#VintID_Menu,(V_int_routine).w
 jsr	(Wait_VSync).w
 enableScreen
 jsr	(Pal_FadeFromBlack).w
.loop
 move.b	#VintID_Menu,(V_int_routine).w
 jsr	(Wait_VSync).w

; These couldn't have been positioned better.
; Macro definitions:

	; Sync ram buffer with on-screen one:
RefreshScreen macro
  QueueStaticDMA ScrRAMbuff,scrbufsz,$0*$20
 endm

	; TODO: Clear the entire ram buffer:

	; Take x,y,color info to plot pixel
	; on screen (hot garbage):
PlotPx macro xpos,ypos,col
 move.w xpos,d0
 move.b ypos,d1
 move.b col,d4

 bsr.s DoPixelStuff
 endm

	; Test pixel:
 PlotPx #231,#$0A,#$0F

	; reload plane after changing ram map:
 RefreshScreen

 bra.s .loop


; ===============================

ScrRAMbuff = Chunk_table


; Okay, so, what does this routine take?
; We take screen pixel x,y coordinates and
; transform them into an offset we can put
; in our one-dimensional array, which is a copy
; of the screen tiles.
; d0 is the x position, 0 being the left most
; pixel and so on.
; d1 is the y position, 0 is at the top of the
; screen and the first y pixel.
; d4 is the color.
; d2 is used internally for the remainders
; of divisions, and
; d3 is the bit mask we AND numbers with.
DoPixelStuff:
	; horizontal evenness check one:
 btst #0,d0
 beq.s .XposEven
 bset #7,d4

.XposEven

; ===========================================
	; xpos code:
 move.w d0,d2	; copy d0 to d2
 moveq #7,d3	; d3 is our bit mask

 and.w d3,d2	; d2 is the remainder of xpos/8
 not.w d3	; mask other part of number
 and.w d3,d0	; d0 now has no remainder.

 lsl.w #2,d0	; xpos/8*32, number of horizontal
		; pixels in a tile * size of tile
 lsr.w d2	; Bytes each contain two pixels,
		; so we divide our pixels by 2
		; to know what byte to land on.

 or.w d2,d0	; Add both positons into one

; ===========================================
	; Begin calculating our y offset:
 move.b d1,d2	; separate remainder ofc
 and.b d3,d1    ; d1 has no remainder, then
 not.b d3	; flip our mask around and
 and.b d3,d2	; have d2 as the remainder.
 lsl.b #2,d2	; smol offset * tile length
		; in bytes
 lsr.b #2,d1	; We divide our ypos by the
		; number of pixels in a tile(8)
		; then *2 bc we use word table

 move.w CoolTable(pc,d1.w),d1
 or.w d2,d1	; add back in-tile pos

; ===========================================
	; Color pixel at calculated offset:
 lea (ScrRAMbuff).l,a0
 add.w d0,a0    ; increase offset horizontally
 add.w d1,a0	; increase offset vertically
 move.b (a0),d2

 not.b d3	; bit mask our beloved
 lsl.b d3
 btst #7,d4
 bclr #7,d4	; cheeky little trick >:3
 bne.s .XposUnEven

	; when our position is even:
 not.b d3
 lsl.b #4,d4

.XposUnEven
 and.b d3,d2
 or.b d4,d2
 move.b d2,(a0) ; half byte done.

 rts


; Demo data:
yscrlen = 40*8*4

CoolTable:
 dc.w 0,yscrlen*1,yscrlen*2,yscrlen*3
 dc.w yscrlen*4,yscrlen*5,yscrlen*6

 ; please continue table when plane map done
 ; thanks ^^
 even

	; test art:
ArtUnc_PlH:
 rept 40*15
 dc.b $22,$22,$22,$22
  rept 3
   dc.b $25,$15,$15,$11
   dc.b $21,$51,$51,$51
  endm
 dc.b $11,$11,$11,$11
 endm

ArtUnc_PlH_end:
 even

	; test palette:
Pal_Custom4TitCrd:
 dc.w $000, $e00, $0e0, $00e, $ee0, $0ee, $e0e
 dc.w $e8e, $8ee, $ee8, $e66, $eee

	; test plane map (incomplete):
Map_ScrBuf:
 binclude "Screens/CubeTest/TestMap.unc"
 even
