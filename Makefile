opts := -arch x86_64 -std=c++11 -fobjc-arc -fblocks -lobjc
fws := -framework Foundation -framework JavaScriptCore
libs := -lc++
exec := Prog
src := ${wildcard *.mm}
wrapper := xcrun --sdk macosx -r

# Using gandalf
device_udid := 40816faa44f9960a4a45aaaf56c4482ca6b07270

.PHONY:deploy clean

all:
	${wrapper} clang++ ${opts} ${fws} ${libs} ${src} -o ${exec}

run:all
	./${exec}

deploy:all
	@./deploy.ml ${exec} ${device_udid}

clean:
	rm -f ${exec}
