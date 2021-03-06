WARNING = -Wall -Wshadow --pedantic
ERROR = -Wvla -Werror
GCC = gcc -std=c99 -g $(WARNING) $(ERROR) 
VAL = valgrind --tool=memcheck --log-file=vallog --leak-check=full --verbose --track-origins=yes


SRCS = pa3.c package.c list.c
OBJS = $(SRCS:%.c=%.o)

pa3: $(OBJS)
	$(GCC) $(OBJS) -o pa3

.c.o: 
	$(GCC) -c $*.c 

testall: test1 test2 test3 test4 test5

test1: pa3
	./pa3 3.po 3.pr 3.dim 3.pck
test2: pa3
	./pa3 8.po 8.pr 8.dim 8.pck
test3: pa3
	./pa3 500.po 500.pr 500.dim 500.pck 
test4: pa3
	./pa3 100.po 100.pr 100.dim 100.pck   
test5: pa3
	./pa3 1K.po 1K.pr 1K.dim 1K.pck   

memory: pa3
	$(VAL) ./pa3 1K.po 1K.pr 1K.dim 1K.pck


clean: # remove all machine generated files
	rm -f pa3 *.o output? 



