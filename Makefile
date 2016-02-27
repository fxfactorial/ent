opts := -arch armv7 -std=c++11 -fobjc-arc -fblocks -lobjc
fws := -framework Foundation -framework JavaScriptCore
libs := -lc++
exec := Prog
wrapper := xcrun --sdk iphoneos -r
device := '10.0.0.33'

.PHONY:deploy

all:
	${wrapper} clang++ ${opts} ${fws} ${libs} main.mm -o ${exec}

deploy:all
	@./deploy.ml ${exec} ${device}
