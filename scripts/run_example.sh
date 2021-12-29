flutter pub get
cd example
for dir in */ ; do
    echo ${dir}
    cd ${dir}
    pwd
    flutter clean
    flutter build apk --no-sound-null-safety
    flutter clean
    flutter build ios --no-sound-null-safety
    cd ..
    pwd
    if [ "$#" -gt 0 ]; then shift; fi
    # shift
done