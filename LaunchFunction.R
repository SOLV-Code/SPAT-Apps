# THIS DEFINES THE FUNCTION THAT LAUNCHES THE GUI IN A BROWSER
# The actual GUI lives in ui.R.
# The function call using the GUI output as an input lives in server.R



launchSPAT<- function(appDir.use=NULL,local=TRUE){

# just keeping this around for consistency with earlier scripts
# and as a placholder for potential future steps.

if(!local){warning("need URL");stop()  }#browseURL("")}

if(local){

library(shiny)


if(is.null(appDir.use)){warning("need app dir");stop() }

# run the app
runApp(appDir = appDir.use)




} # end if local


} # end function launchSPAT 




