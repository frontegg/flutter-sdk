flutter pub get
cd example
for dir in */ ; do
    echo ${dir}
    cd ${dir}
    pwd
    flutter clean
    flutter build apk
    flutter clean
    flutter build ios --release
    cd ..
    pwd
    if [ "$#" -gt 0 ]; then shift; fi
    # shift
done