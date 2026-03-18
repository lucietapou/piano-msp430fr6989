/*
 * teclado.h
 *
 *  Created on: 4 dic. 2025
 *      Author: Usuario
 */

#ifndef TECLADO_H_
#define TECLADO_H_
#include <stdint.h>

#define TAMBUFTEC 16
#define NOTECLA -1
#define ETX 3
void kbIni (void);
char kbBarrido (void);
char kbLeeTecla (void);
#endif /* TECLADO_H_ */
