  
  '*********************************************************************************
  # BASE DE DATOS:	ENCUESTA NACIONAL DE HOGARES (ENAHO)
  # PROYECTO: 		  INDICADORES SOCIOECONÓMICOS
  # TÍTULO:         MASTER DATA
  # PERIODO:				2014-2022
  # AUTOR: 			    NICOLAS MARROQUIN
  *********************************************************************************'
  
  # Outline: -----------------------------------------------------------------------
  	
  {'
  1. Ruta de trabajo y globals
    1.1. Instalar paquetes requeridos
    1.2. Configurar usuarios
    1.3. Configurar carpetas
    1.4. Configurar ejecución
  2. Importar base de datos
  3. Limpieza de base de datos
  4. Construcción de indicadores
  5. Reporte de resultados
  '}
  
  # ********************************************************************************
  # PART 1: Ruta de trabajo y globals ----------------------------------------------
  # ********************************************************************************

  rm(list = ls())         # Limpiar memoria
  options(scipen = 999)   # Deshabilitar la notación científica
  cat("\014")             # Limpiar consola
  graphics.off()          # Limpiar gráficos
  
  ## 1.1. Instalar librerias requeridas --------------------------------------------

  if (!require("pacman")) {install.packages("pacman")}
  pacman::p_load("data.table", "survey", "summarytools", "readstata13", "magrittr", 
                 "dplyr", "readxl", "stringr", "openxlsx", "tidyr", "ggplot2", "readr",
                 "stringi", "summarytools", "srvyr", "lubridate", "gganimate", "ggcorrplot",
                 "gridExtra", "ggthemes", "hrbrthemes", "magick", "scales", "RColorBrewer",
                 "devtools", "filesstrings")

  ## 1.2. Configurar usuarios ------------------------------------------------------

  if (Sys.info()[["user"]] == "rnico") {setwd("D:/Proyectos")}

  if (Sys.info()[["user"]] == "renzomarroquin") {setwd("D:/Proyectos")}
  
  ## 1.3. Configurar carpetas ------------------------------------------------------

  proyecto      <- paste(getwd(),  "01_Indicadores_socioeconomicos", sep = "/")
  base_de_datos <- paste(proyecto, "01_Raw_data", sep = "/")
  clean_data    <- paste(proyecto, "02_Clean_data", sep = "/")
  codigo        <- paste(proyecto, "03_Script", sep = "/")
  input         <- paste(proyecto, "04_Input", sep = "/")
  resultados    <- paste(proyecto, "05_Output", sep = "/")
  documentacion <- paste(proyecto, "06_Report", sep = "/")
  alerta        <- paste(proyecto, "07_Alerta", sep = "/")
  
  ## 1.4. Configurar ejecución -----------------------------------------------------

  import_data  <- FALSE
  clean_data   <- FALSE
  indicators   <- FALSE
  report_data  <- FALSE
  
  # ********************************************************************************
  # PART 2: Importar base de datos -------------------------------------------------
  # ********************************************************************************
  
  if (import_data) {
    source(paste(codigo,"01_Import_data.R", sep = "/"))
  }

  # ********************************************************************************
  # PART 3: Limpieza de base de datos ----------------------------------------------
  # ********************************************************************************

  if (clean_data) {
    source(paste(codigo,"02_Clean_data.R", sep = "/"))
  }
  
  # ********************************************************************************
  # PART 3: Construcción de indicadores --------------------------------------------
  # ********************************************************************************
  
  if (indicators) {
    source(paste(codigo,"03_Socioeconomic_indicators.R", sep = "/"))
  }
  
  # ********************************************************************************
  # PART 4: Reporte de resultados --------------------------------------------------
  # ********************************************************************************
  
  if (report_data) {
    source(paste(codigo,"04_Socioeconomic_results.R", sep = "/"))
  }