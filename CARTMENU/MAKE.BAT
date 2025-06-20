@echo off
echo ====== Apagando a ROM antiga =====
del ROM\MENU.ROM
echo ======= Compilando nova ROM ======
pasmo MENU.ASM ROM\MENU.ROM
echo ============= Pronto =============
openmsx -cart ROM\MENU.ROM
