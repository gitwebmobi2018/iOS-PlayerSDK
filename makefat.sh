rm -rf archs
rm -rf ZixiPlayerSDK.framework
tar -xvf iOS/ZixiPlayerSDK.framework.tar.gz -C iOS
tar -xvf Simulator/ZixiPlayerSDK.framework.tar.gz -C Simulator

mkdir archs
lipo -extract i386 Simulator/ZixiPlayerSDK.framework/ZixiPlayerSDK -output archs/ZixiPlayerSDK_i386
lipo -extract x86_64 Simulator/ZixiPlayerSDK.framework/ZixiPlayerSDK -output archs/ZixiPlayerSDK_x8664
lipo -extract armv7 iOS/ZixiPlayerSDK.framework/ZixiPlayerSDK -output archs/ZixiPlayerSDK_armv7
lipo -extract arm64 iOS/ZixiPlayerSDK.framework/ZixiPlayerSDK -output archs/ZixiPlayerSDK_arm64
lipo -create archs/ZixiPlayerSDK_i386 archs/ZixiPlayerSDK_x8664 archs/ZixiPlayerSDK_armv7 archs/ZixiPlayerSDK_arm64 -output archs/ZixiPlayerSDK
rm -rf archs/ZixiPlayerSDK_*
cp -R iOS/ZixiPlayerSDK.framework/Headers archs/
cp -R iOS/ZixiPlayerSDK.framework/Modules archs/
cp -R iOS/ZixiPlayerSDK.framework/Info.plist archs/
mv archs ZixiPlayerSDK.framework
rm -rf iOS/ZixiPlayerSDK.framework
rm -rf Simulator/ZixiPlayerSDK.framework


