/bin/sh

# Releaseビルド以外は終了
if [ "${CONFIGURATION}" != "Release" ]; then
    exit 0
fi


plistBuddy="/usr/libexec/PlistBuddy"
infoPlistFile="${SRCROOT}/${INFOPLIST_FILE}"

# バージョン番号
versionNumber=$($plistBuddy -c "Print CFBundleShortVersionString" "${infoPlistFile}")

# ビルド番号
oldBuildNumber=$($plistBuddy -c "Print CFBundleVersion" "${infoPlistFile}")

if [[ -z "${oldBuildNumber}" ]]; then
    echo "oldBuildNumber get failed"
    exit 1
fi

echo "versionNumber = ${versionNumber}"
echo "oldBuildNumber = ${oldBuildNumber}"

# ビルド番号を.で分割
buildArray=(`echo $oldBuildNumber | tr -s '.' ' '`)
echo ${buildArray[0]}
echo ${buildArray[1]}
echo ${buildArray[2]}
echo ${buildArray[3]}


# バージョン番号とビルド番号が同じ場合
if [ "${versionNumber}" = "${buildArray[0]}.${buildArray[1]}.${buildArray[2]}" ]; then

    # 4桁目が無い場合は、0から開始
    if [[ -z "${buildArray[3]}" ]]; then
        buildSuffixNumber=0

    # 4桁目が有る場合は、インクリメント
    else
        buildSuffixNumber=$(( ${buildArray[3]} + 1 ))
        echo "update buildSuffixNumber"
    fi

# バージョン番号とビルド番号が異なる場合は、0から開始
else
    buildSuffixNumber=0
fi

echo "buildSuffixNumber = ${buildSuffixNumber}"

# 新しいビルド番号
newBuildNumber="${versionNumber}.${buildSuffixNumber}"
echo "${newBuildNumber}"

# plistへ書き込み
$($plistBuddy -c "Set :CFBundleVersion ${newBuildNumber}" "${infoPlistFile}")
echo "update buildNumber success"
