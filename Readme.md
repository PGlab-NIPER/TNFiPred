* Install 64-bit Java Run Time envirnoment (JRE) from following link:
https://www.java.com/en/download/manual.jsp

* Download and install R language from following link:
https://cran.r-project.org/bin/windows/base/

* Make sure to add the path of R language to the sytem environment variables.
For adding path of R language to system environment variable use following command:                        
```bash
pathman /au C:\Program Files\R\R-4.1.1\bin\x64\
```                                                                               
Above command is for R version 4.1.1, change it according to the R version installed               
For example for R version 4.2.0:                                                       
```bash
pathman /au C:\Program Files\R\R-4.2.0\bin\x64\
```
* Open R terminal and execute following command to install all necessary R packages:
```bash
install.packages(c('caret','rcdk','shiny','shinycsslaoder', 'randomForest'),repos='https://cloud.r-project.org', dependencies=TRUE)
```

* Open the runme.bat file 
Application will launch in new window of your default internet browser
