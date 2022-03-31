# Makefile

prgs = sort partition

all: $(prgs)

sort: clean
	@echo "Run with spin..."; spin -a -DVERIFY_SORT quicksort.pml
	@echo "Compile with gcc..."; gcc -O2 pan.c -o sort 2> /dev/null
	@echo "Run sort test :"; ./sort

partition: clean
	@echo "Run with spin..."; spin -a -DVERIFY_PARTITION quicksort.pml
	@echo "Compile with gcc..."; gcc -O2 pan.c -o partition 2> /dev/null
	@echo "Run partition test :"; ./partition

test:
	@echo "Testing the quicksort with spin :"; spin -DSHOW_SORT quicksort.pml | sed 's/\s\+/ /g'

clean:
	@rm -f sort partition pan.*
