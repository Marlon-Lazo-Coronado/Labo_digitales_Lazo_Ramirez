#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#define LED_REGISTERS_MEMORY_ADD 0x00010190 //0x00013FF8  0x0010000
static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD)=i;}
//Como el ejercicio solo vale 5% no vale la pena matarse haciendo una lista con estruc
void main() {
	//Declaramos punteros base
	volatile uint32_t * direccion_dir = NULL;
	volatile uint32_t * direccion_dat = NULL;
	//Usamos algebra de punteros para el calculo
	// 4096 32bit words = 16kB memory
	uint32_t base = 16384; //4i = 4*4096 = 16384
	direccion_dir = direccion_dir + 4096; // nos desplazamos 4096 para ir a la direccion 16384
	direccion_dat = direccion_dat + 4096 + 1;
	//Como en cada iteracion se procesan 2 espacios, el tamaño del for es ((3*4096)/2)=6144
	for (uint32_t i=0; i<=6144; i++){
		//===============Proceso de las direcciones=========================================================
		*direccion_dir = base+8*(i+1); //calculamos y guardamos las direciones de los numeros
		direccion_dir = direccion_dir +1;
		direccion_dir = direccion_dir +1;//Calculo de las direcciones que guardan direcciones, se desplaza i espacios de memoria
		//===============Proceso de los datos===============================================================
		//Es la misma que la de direcciones pero un espacio adelante
		*direccion_dat = i; //guardamos el entero.
		direccion_dat = direccion_dat + 1;
		direccion_dat = direccion_dat + 1;
		if((i>6133) && ((i%2) != 0)){
			putuint(i);
		}
		else {
			putuint(0);
		}
	}
}
//=====================Formulas========================================================
//		direccion_direcciones = i*8	, i espacio de memoria
//		i=0 => 0
//		i=1 => 8
//		i=2 => 16
//		i=3 => 24
//		i=4 => 32
//		i=4096 => 32768

//		direccion_datos = i*8 + 4	, i espacio de memoria, indice y dato
