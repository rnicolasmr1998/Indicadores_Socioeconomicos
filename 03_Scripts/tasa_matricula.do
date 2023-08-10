*********************************************************************************
* BASE DE DATOS:	Encuesta Nacional de Hogares (ENAHO)
* MODULO:			Educación
* PROYECTO: 		Tasa de matricula universitaria                           		
* AÑO:				2022
* AUTOR: 			Nicolas Marroquin
*********************************************************************************
	
*** Outline:
/*	
	1. Ruta de trabajo y globals
		1.1. Instalar paquetes requeridos
		1.2. Configurar usuarios
		1.3. Configurar carpetas
	2. Manejo y limpieza de datos
		2.1. Importar y almacenar datos
			2.1.1. Seleccionar variables
			2.1.2. Importar datos
			2.1.3. Almacenar base de datos
		2.2. Creación de variables
			2.2.1. Estudiantes universitarios (posgrado y pregrado)
			2.2.2. Cobertura de educacion superior
	3. Exportar base de datos
		3.1. Reducir variables
		3.2. Formato .xlsx
*/

*********************************************************************************
*** PART 1: Ruta de trabajo y globals
*********************************************************************************

*** 1.1. Instalar paquetes requeridos
	
	local packages xtable fre outreg2 asdoc
	foreach pgks in `packages' {
		capture which `pgks'
		if (_rc != 111) {
			display as text in smcl "Paquete {it:`pgks'} está instalado "
			}
		else {
			display as error in smcl `"Paquete {it:`pgks'} necesita instalarse."'
			capture ssc install `pgks', replace
			if (_rc == 601) {
				display as error in smcl `"Package `pgks' is not found at SSC;"' _newline ///
				`"Please check if {it:`pgks'} is spelled correctly and whether `pgks' is indeed a user-written command."'
			}
			else {
				display as result in smcl `"Paquete `pgks' ha sido instalado."'
				}
			}
	}
	
*** 1.2. Configurar usuarios

	if ("`c(username)'" == "renzomarroquin") {
		global project "D:\NICOLAS\05_TASA_MATRICULA_ENAHO"
	}
	
	if ("`c(username)'" == "rnico") { 
		global project "C:\Users\rnico\Documents\02_TRABAJO_SUNEDU\05_TASA_MATRICULA_ENAHO"
	} 
	
*** 1.3. Configurar carpetas

	// En las dos computadoras o usuarios deben tener la misma estrutctura de carpetas
	global base_de_datos	"${project}\01_BASE_DE_DATOS"
	global data_compilada	"${base_de_datos}\0_DATOS_COMPILADOS"
	global codigos			"${project}\02_CODIGO"
	global resultados		"${project}\03_RESULTADOS"
	
*********************************************************************************
*** PART 2: Manejo y limpieza de datos
********************************************************************************/

*** 2.1. Importar y almacenar datos

***	2.1.1. Seleccionar variables 
	
	local inicio 	2004
	local final		2022
	forvalues x=`inicio'/`final' {
	global	llave_hog	conglome vivienda hogar 
	global 	llave_ind	conglome vivienda hogar codperso 
	global	xlist_ind	p203 	 p204 	  p205 	p206 p207 p208a p209
	global 	xlist_reg	mes 	 ubigeo   dominio 	 estrato 
	global 	fecha "20221026"
	set more off

***	2.1.2. Importar datos
 	
	use $llave_ind $xlist_ind $xlist_ind $xlist_reg p308a p306 p301a fac* if (inlist(p204,1,2)) using "${base_de_datos}\\`x'\enaho01a-`x'-300.dta", clear

	rename _all, lower

	gen anio=`x'

	cap rename factor07   factor300
	cap rename fac*		  factor300 
	cap rename factor     factor300
	cap rename factorpob  factor300
	cap rename facpobtrim factor300
	cap rename facpobtr   factor300
	cap rename factora07  factor300
	cap rename factor07a  factor300
	cap rename facpob07   factor300

*** 2.1.3. Almacenar base de datos
	
	if `x'!=`inicio' {
	qui append using "${data_compilada}\base_aux.dta", force
	}
	qui saveold "${data_compilada}\base_aux.dta", replace
	}

*** 2.2. Creación de variables
	
*** 2.2.1. Estudiantes universitarios (posgrado y pregrado)

	/*Pregrado*/
	gen		matricula_pre = (p308a == 5 & p306 == 1)
	replace matricula_pre = . if inlist(p301a, 6, 7, 8, 9, 12) == 0
	
	label define 	matricula_pre 1 "Matriculado ES" 0 "No matriculado ES"
	label values 	matricula_pre matricula_pre
	label variable 	matricula_pre "Estudiante universitario matriculado (pregrado)"

	/*Posgrado*/
	gen		matricula_pos = (p308a == 6 & p306 == 1)
	replace matricula_pos = . if inlist(p301a, 6, 7, 8, 9, 12)==0
	
	label define 	matricula_pos 1 "Matriculado ES" 0 "No matriculado ES"
	label values 	matricula_pos matricula_pos
	label variable	matricula_pos "Estudiante universitario matriculado (posgrado)"

*** 2.2.2. Cobertura de educacion superior
	
	/* Actualmentre matriculado o haya culminado Pregrado*/
	gen alcance_pre = matricula_pre == 1 	| inlist(p301a, 10, 11) 

	/* Actualmentre matriculado o haya culminado Posgrado*/	
	gen alcance_pos = matricula_pos == 1 	| inlist(p301a, 11) 

*********************************************************************************
*** PART 3: EXPORTAR BASE DE DATOS
*********************************************************************************	

*** 3.1. Ruta de tablas

	cd "${resultados}"
	drop if inlist(mes,"01","02","03")

*** 3.2. Tasa de matricula universitaria (% de población con edades 17-24)	
	
	gen r_matr 		 = matricula_pre*100
	gen cluster_edad = (p208a >= 17 & p208a <= 24)

*** 3.3. Tasa de matricula universitaria
	
	xtable anio [iw = factor300] if cluster_edad == 1, c(mean r_matr) col row format(%5,2f)