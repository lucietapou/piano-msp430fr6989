/*
 * lcd.h
 *
 *  Created on: 6 nov. 2025
 *      Author: Alumnos
 */

#ifndef PT_H_
#define PT_H_
#include <stdint.h>
typedef uint8_t puerto_t;

puerto_t ptConfigura(int puerto, int bit, uint8_t modo);
int ptLee(puerto_t pt);
void ptEscribe(puerto_t pt, int valor);
int ptLeeFlanco(puerto_t pt);
void ptEscFlanco(puerto_t pt, int flancobajada);
int ptLeeHabIRQ(puerto_t pt);
void ptEscHabIRQ(puerto_t pt, int siono);
int ptLeeIRQ(puerto_t pt);
void ptBorraIRQ(puerto_t pt);


#define MD_IRQ BIT7
#define MD_SF BIT6
#define MD_POL BIT5
#define MD_INI BIT4
#define MD_FUNC1 BIT3
#define MD_FUNC0 BIT2
#define MD_TIPO1 BIT1
#define MD_TIPO0 BIT0
#define MD_FUNC BIT2|BIT3
#define MD_TIPO BIT0|BIT1
#define PT_NOIRQ (0<<7)
#define PT_IRQ (1<<7)
#define PT_FLANCOSUBIDA (0<<6)
#define PT_FLANCOBAJADA (1<<6)
#define PT_ACTIVOALTA (0<<5)
#define PT_ACTIVOBAJA (1<<5)
#define PT_LOW (0<<4)
#define PT_HIGH (1<<4)
#define PT_ESDIG (0<<2)
#define PT_FUNC1 (1<<2)
#define PT_FUNC2 (2<<2)
#define PT_FUNC3 (3<<2)
#define PT_ENTRADA (0<<0)
#define PT_ENTRADA_PULLUP (1<<0)
#define PT_ENTRADA_PULLDOWN (2<<0)
#define PT_SALIDA (3<<0)
#endif /* PT_H_ */
