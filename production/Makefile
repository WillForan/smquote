init:
	Rscript -e "library(devtools);setwd('..');install(smquote)"
stock.db:
	sqlite3 stock.db < schema.sql

# do this after 5pm
updatedb:
	./historical.pl 

screened.txt:
	Rscript screen.R 

buy.txt: screened.txt
	./currentData.pl screened.txt > buy.txt
