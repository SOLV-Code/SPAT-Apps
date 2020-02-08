install.packages("devtools") # Install the devtools package
library(devtools) # Load the devtools package.
install_github("SOLV-Code/SPATFunctions-Package", 
				dependencies = TRUE,
                build_vignettes = FALSE,force = TRUE)
library(SPATFunctions)

# Load the function that does the model set-up and launches the GUI
source("LaunchFunction.R")

# Run the function to launch locally
launchSPAT(appDir.use="CorrelationAnalysis", local=TRUE)







