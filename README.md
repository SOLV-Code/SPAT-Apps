# SPAT Apps
Prototype apps using the [SPATFUnctions](https://github.com/SOLV-Code/SPATFunctions-Package) Package.

Active apps:
* SPAT Correlation Analysis ([online](https://solv-code.shinyapps.io/spat_correlationanalysis/)): Compare data series side-by-side, explore correlations over time between 2 series, and cluster series in a correlation matrix. Data format is a table with a **yr** column and 2 or more variable columns. The built-in data set for illustration is *SPATData_EnvCov*, which includes R/S for 18 stocks of Fraser River Sockeye Salmon and various environmental covariates (e.g. river discharge, sea surface temperature).

## How to run the apps locally

Running the apps locally improves speed and doesn't rely on internet access, but requires user to install some programs and packages ahead of time. 

There are 2 options for running the apps locally. Both require that you first install and load the *SPAT Functions* package.


### R GUI

Install [Base R](https://cran.r-project.org/mirrors.html),  download the app folder (e.g. [Correlation Analysis] and the launch scripts, open *1_LaunchGUI.R*, and run the script, which includes the package install.



### RStudio

Install [RStudio](https://rstudio.com/products/rstudio/download/), download the app folder (e.g. [Correlation Analysis], install SPAT Functions using the code below, open *ui.R*, and click "Run App"

```
install.packages("devtools") # Install the devtools package
library(devtools) # Load the devtools package.
install_github("SOLV-Code/SPATFunctions-Package", 
				dependencies = TRUE,
                build_vignettes = FALSE,force = TRUE)
library(SPATFunctions)

```



