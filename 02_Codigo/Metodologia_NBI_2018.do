cls
clear all
*******************************************************************************************
* BASE DE DATOS:	ENAHO
* PROYECTO: 		INDICADORES ECONÓMICOS Y SOCIALES                           		
* TÍTULO:			METODOLOGÍA DE CÁLCULO DE NBIs
* AÑO:				2018
* AUTOR: 			Nicolas Marroquin
*******************************************************************************************

*** Outline:
/*
    1. Ruta de trabajo y globals
		1.1. Configurar usuarios
		1.2. Configurar carpetas
    2. Importar archivos .sas y convertirlos a .dta
    3. Cálculo de las Necesidades Básicas Insatisfechas (NBIs)
		3.1. NBI1: Vivienda inadecuada
		3.2. NBI2: Vivienda con hacinamiento
			3.2.1. Total de habitaciones por vivienda
			3.2.2. Total de miembros por vivienda
			3.2.3. Total de miembros por hogar
			3.2.4. Cálculo del NBI2
		3.3. NBI3: Hogares con vivienda sin servicios higiénicos
		3.4. NBI4: Hogares con niños que no asisten a la escuela
		3.5. NBI5: Hogares con alta dependencia economica
    4. Agrupar y recodificar los NBIs
		4.1. Agrupar los NBIs
		4.2. Recodificar los NBIs
*/

*******************************************************************************************
*** PART 1: Ruta de trabajo y globals
*******************************************************************************************
	
*** 1.1. Configurar usuarios

	if ("`c(username)'" == "renzomarroquin") {
		global project "D:\Nicolas\Pobreza"
	}
	
	if ("`c(username)'" == "rnico") { 
		global project "D:\Nicolas\Pobreza"
	}
	
	if ("`c(username)'" == "PIERO ALEJANDRO") { 
		global project "D:\Nicolas\Pobreza"
	}
	
*** 1.2. Configurar carpetas

	/*Los usuarios deben tener la misma estrutctura de carpetas*/
	global 		base_de_datos	"${project}\01_Base_de_datos"
	global 		codigo			"${project}\02_Codigo"
	global 		resultados		"${project}\03_Resultados"
	
*******************************************************************************************
*** PART 2: Importar archivos .sas y convertirlos a .dta
*******************************************************************************************
	
	import spss "$base_de_datos/enaho01-2018-100.sav",  case(lower) clear 
	tempfile	`enaho01-2018-100'
	saveold 	enaho01-2018-100, replace 

	import spss "$base_de_datos/enaho01-2018-200.sav",  case(lower) clear
	tempfile	`enaho01-2018-200'
	saveold 	enaho01-2018-200, replace 

	import spss "$base_de_datos/enaho01a-2018-300.sav", case(lower) clear
	tempfile	`enaho01a-2018-300'
	saveold 	enaho01a-2018-300, replace 

	import spss "$base_de_datos/enaho01a-2018-500.sav", case(lower) clear  
	tempfile	`enaho01a-2018-500'
	saveold 	enaho01a-2018-500, replace 

*******************************************************************************************
*** PART 3: Cálculo de las Necesidades Básicas Insatisfechas (NBIs)
*******************************************************************************************	
	
*** 3.1. NBI1: Vivienda inadecuada

	use 		"enaho01-2018-100", clear
	gen 		xnbi1 = p101 == 6 | p102 == 8 | ((inlist(p102, 5, 6, 7, 9) & p103 == 6))
	sort 		conglome vivienda hogar
	collapse 	(max) xnbi1, by(conglome vivienda)
	tempfile	`nbi1_2018'
	saveold 	nbi1_2018, replace
	
*** 3.2. NBI2: Vivienda con hacinamiento

*** 3.2.1. Total de habitaciones por vivienda

	use 		"enaho01-2018-100.dta", clear 
	generate 	tothab = p104 if p104 != 0 & p104 != .
	generate 	nhogar = real(substr(hogar, 2, 1))
	sort 		conglome vivienda
	collapse 	(sum) tothab (max) nhogar if tothab != ., by(conglome vivienda)
	tempfile	`habitviv'
	saveold 	habitviv, replace
	
*** 3.2.2. Total de miembros por vivienda

	use 		"enaho01-2018-200.dta", clear
	generate 	mieperviv = p204 == 1 if p203 != 8 & p203 != 9
	sort 		conglome vivienda
	collapse 	(sum) mieperviv, by(conglome vivienda)
	tempfile	`mieperviv'
	saveold 	mieperviv, replace

*** 3.2.3. Total de miembros por hogar

	use 		"enaho01-2018-200.dta", clear
	generate 	mieperho = p204 == 1 if p203 != 8 & p203 != 9
	sort 		conglome vivienda hogar
	collapse 	(sum) mieperho, by(conglome vivienda hogar)
	tempfile	`mieperho'
	saveold 	mieperho, replace

*** 3.2.4. Total de miembros por vivienda
	use	 		habitviv, clear
	sort 		conglome vivienda
	merge 1:1 	conglome vivienda using mieperviv, nogen

	/* Reemplazar la omisión de habitaciones en la vivienda */
	replace 	tothab = nhogar if tothab == 0 | tothab == .

*** 3.2.5.  Cálculo del NBI2
	
	generate 	xnbi2 = (mieperviv / tothab) > 3.4 if mieperviv != . & tothab != 0
	sort 		conglome vivienda
	keep 		conglome vivienda xnbi2
	tempfile	`nbi2_2018'
	saveold 	nbi2_2018, replace
	
*** 3.3. NBI3: Hogares con vivienda sin servicios higiénicos

	use 		"enaho01-2018-100.dta", clear
	gen 		xnbi3 = inlist(t111a, 6, 7, 9) if result <= 2
	sort 		conglome vivienda hogar
	collapse 	(max) xnbi3, by(conglome vivienda hogar)
	tempfile	`nbi3_2018'
	saveold 	nbi3_2018, replace

*** 3.4. NBI4: Hogares con niños que no asisten a la escuela
	
	use 		"enaho01a-2018-300.dta", clear
	generate 	xnbi4 = (p208a >= 6 & p208a <= 12) & inlist(p203, 1, 3, 5, 7) ///
				& p303 == 2 if real(mes) >= 1 & real(mes) <= 3
	replace 	xnbi4 = (p208a >= 6 & p208a <= 12) & inlist(p203, 1, 3, 5, 7) ///
				& (p306 == 2 | (p306 == 1 & p307 == 2)) if real(mes) >= 4 & real(mes) <= 12
	sort 		conglome vivienda hogar
	collapse 	(max) xnbi4, by(conglome vivienda hogar)
	tempfile	`nbi4_2018'
	saveold 	nbi4_2018, replace

*** 3.5. NBI5: Hogares con alta dependencia economica

*** 3.5.1. Educación del jefe de hogar
	
	use 		"enaho01a-2018-300.dta", clear
	keep if 	p203 == 1
	generate 	edujef = ((p301a == 1 | p301a == 2) | (p301a == 3 & ///
				(inlist(p301b, 0, 1, 2))) | (p301a == 3 & (p301c == 1 | p301c == 2 ///
				| p301c == 3))) & p203==1
	keep 		conglome vivienda hogar edujef
	sort 		conglome vivienda hogar
	tempfile	`edujefe'
	saveold 	edujefe, replace

*** 3.5.2. Ocupado	
	
	use 		"enaho01a-2018-500.dta", clear
	generate 	ocu= real(p500i) > 0 & ocu500 == 1 & p204 == 1 & p203 != 8 & p203 !=9
	sort 		conglome vivienda hogar
	collapse 	(sum)ocu, by(conglome vivienda hogar)
	tempfile	`ocu'
	save 		ocu, replace

*** 3.5.3. Juntar la base de ocu, edujefe y mieperho	

	use 		"enaho01-2018-100.dta", clear
	sort 		conglome vivienda hogar
	merge 1:1	conglome vivienda hogar using ocu, nogen
	sort 		conglome vivienda hogar
	merge 1:1	conglome vivienda hogar using edujefe, nogen
	sort 		conglome vivienda hogar
	merge 1:1	conglome vivienda hogar using mieperho, nogen

*** 3.5.4. Dependencia
	
	generate 	dep = mieperho if ocu == 0
	replace 	dep = (mieperho - ocu)/ocu if ocu > 0 & ocu !=.

*** 3.5.5. Cálculo del NBI5	

	generate 	xnbi5 = edujef == 1 & dep > 3
	sort 		conglome vivienda hogar
	keep 		conglome vivienda hogar xnbi5 mieperho
	tempfile	`nbi5_2018'
	saveold 	nbi5_2018, replace
	
*******************************************************************************************
*** PART 4: Agrupar y recodificar los NBIs
*******************************************************************************************		

*** 4.1. Agrupar los NBIs
	
	use 		"enaho01-2018-100.dta", clear
	sort 		conglome vivienda
	merge m:1	conglome vivienda using nbi1_2018, nogen
	sort 		conglome vivienda
	merge m:1	conglome vivienda using nbi2_2018, nogen
	sort 		conglome vivienda hogar
	merge m:1	conglome vivienda hogar using nbi3_2018, nogen
	sort 		conglome vivienda hogar
	merge m:1 	conglome vivienda hogar using nbi4_2018, nogen
	sort 		conglome vivienda hogar
	merge m:1	conglome vivienda hogar using nbi5_2018, nogen

*** 4.2. Recodificar los NBIs	

	recode xnbi1 (0 = .) (1 = .) if result >= 3
	recode xnbi2 (0 = .) (1 = .) if result >= 3
	recode xnbi3 (0 = .) (1 = .) if result >= 3
	recode xnbi4 (0 = .) (1 = .) if result >= 3
	recode xnbi5 (0 = .) (1 = .) if result >= 3
