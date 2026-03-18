/*
 * lcd.h
 *
 *  Created on: 6 nov. 2025
 *      Author: Alumnos
 */

#ifndef LCD_H_
#define LCD_H_

#include <stdint.h>

void lcdIni (void);
unsigned int lcda2seg(char c);
void lcdPintaIzq (char c);
void lcdPintaDer (char c);
void lcdBorraTodo (void);
void lcdBorra (void);
uint8_t lcdBateria (uint8_t b);
uint8_t lcdIconos (uint8_t map);
void lcdInterDigito (uint8_t map);
#endif /* LCD_H_ */
