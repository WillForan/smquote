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

mv:
	mv screened.txt old/screened.`date +%F`
	mv buy.txt old/buy.`date +%F`

sell: buy.txt
	./currentData.pl buy.txt |tee sell.txt| awk '(NR>1){print $$1,($$2-$$3)/$$3}'

new: mv updatedb sell
