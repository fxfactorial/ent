opts := -arch armv7 -std=c++11 -fobjc-arc -fblocks -lobjc
fws := -framework Foundation -framework JavaScriptCore
libs := -lc++
exec := Prog
wrapper := xcrun --sdk iphoneos -r
# Using gandalf
device_udid := 40816faa44f9960a4a45aaaf56c4482ca6b07270

.PHONY:deploy clean

all:
	${wrapper} clang++ ${opts} ${fws} ${libs} main.mm -o ${exec}

deploy:all
	@./deploy.ml ${exec} ${device_udid}

clean:
	rm -f ${exec}
