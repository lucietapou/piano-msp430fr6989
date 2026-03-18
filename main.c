#include <msp430.h>
#include <stdint.h>
#include <string.h>
#include "pt.h"
#include "lcd.h"
#include "cs.h"
#include "st.h"
#include "teclado.h"

extern void sndIni(void);
extern void sndMute(int mute);
extern void sndNota(int octava, int notaIndex);


#define FTA     32768
#define FST     200         // 200 Hz
#define VCCR0  ((FTA/FST) - 1)

int Oct = 5;
int Led = 1;
puerto_t led2;


void ActualizarBateria(void);
void GestionarLed(void);
void GestionarTeclado(void);

int main(void) {
    WDTCTL = WDTPW | WDTHOLD;
    PM5CTL0 &= ~LOCKLPM5;

    //LED2 (P9.7)
    led2 = ptConfigura(9, 7, PT_SALIDA | PT_ACTIVOALTA);
    ptEscribe(led2, 0);


    lcdIni();
    csIniLFXT();
    kbIni();        // Teclado
    sndIni();       // Sonido
    stIni(VCCR0);   // Timer

    __enable_interrupt();



    ActualizarBateria();

    while(1) {
        //Tarea 1: Teclado
        GestionarTeclado();

        //Tarea 2: Animación LED
        GestionarLed();
        LPM3;

    }
}

void GestionarTeclado(void) {
    char tecla = kbLeeTecla();

    static int Mute = 0;
    if(tecla == 0 || (uint8_t)tecla == 255){
        return;
    }

    // si es ext silenciar y borrar
    if(tecla == 3) {
        sndNota(0,0);
        lcdBorra();
        return;
    }

    // Cambio de octava
    if(tecla == '+') {
        if(Oct<6) {
            Oct++;
            ActualizarBateria();
            return;
        }
    }
    if(tecla == '-') {
        if(Oct>4) {
            Oct--;
            ActualizarBateria();
            return;
        }
    }

    // MUTE
    if(tecla == 7) {
        Mute ^= 1;  //xor mute
        sndMute(Mute);
        lcdIconos(Mute);
        return;
    }

    // si Cr pulsado
    if(tecla == 13) {
       Led ^= 1;   //xor led
       if(Led==0) {
           ptEscribe(led2,0);
       }
       return;
    }

    // --- Notas musicales ---
    const char* nombresNotas[12] = {
        "Do  ", "Do* ", "Re  ", "Re* ", "Mi  ", "Fa  ",
        "Fa* ", "Sol ", "Sol*", "La  ", "La* ", "Si  "
    };
    const char asciiNotas[12] = {'c','C','d','D','e','f','F','g','G','a','A','b'};

    int i;
    for(i=0; i<12; i++){
        if(tecla == asciiNotas[i]){ //busca coincidencia de notas para después escribir
            lcdPintaIzq(nombresNotas[i][0]);
            lcdPintaIzq(nombresNotas[i][1]);
            lcdPintaIzq(nombresNotas[i][2]);
            lcdPintaIzq(nombresNotas[i][3]);
                sndNota(Oct,i);
            break;
        }
    }
}

void ActualizarBateria(void) {
    if(Oct == 4) lcdBateria(3);   // 1|2
    if(Oct == 5) lcdBateria(15);  // 1|2|4|8
    if(Oct == 6) lcdBateria(63);  // Todos
}

void GestionarLed(void) {
    if(Led==0){
        return;
    }
    static int ticks = 0;
    int ticsmax = 0; //num de ticks cada cambio de estado

    // FST = 200 Hz
    if(Oct == 4) {
        ticsmax = 100; // 1 Hz
    }
    if(Oct == 5){
        ticsmax = 6;   // 16 Hz
    }
    if(Oct == 6) {
        ticsmax = 3;   // 32 Hz
    }
    ticks++;
    if(ticks >= ticsmax) {   //cuando hayan pasado los ticks por octava cambio led
        if(ptLee(led2)) {
            ptEscribe(led2, 0);
        }
        else ptEscribe(led2, 1);
        ticks = 0;
    }
}
