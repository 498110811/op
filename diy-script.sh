#!/bin/bash

#修改应用名称
replace_text() {
  search_text="$1" new_text="$2"
  sed -i "s/$search_text/$new_text/g" $(grep "$search_text" -rl ./ 2>/dev/null) || echo -e "\e[31mNot found [$search_text]\e[0m"
}

replace_text "Turbo ACC 网络加速" "网络加速"
replace_text "移动网络" "移动蜂窝"

# 修改主机名以及一些显示信息
#sed -i "s/hostname='*.*'/hostname='test'/" package/base-files/files/bin/config_generate
#sed -i "s/DISTRIB_ID='*.*'/DISTRIB_ID='OpenWrt'/g" package/base-files/files/etc/openwrt_release
#sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='OpenWrt'/g"  package/base-files/files/etc/openwrt_release
#sed -i '/(<%=pcdata(ver.luciversion)%>)/a\      built by test' package/lean/autocore/files/x86/index.htm
#echo -n "$(date +'%Y%m%d')" > package/base-files/files/etc/openwrt_version
#curl -fsSL https://raw.githubusercontent.com/ywt114/diy/main/banner_test > package/base-files/files/etc/banner

# 修改默认皮肤
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-ssl-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-light/Makefile

# 开启wifi选项
sed -i 's/disabled=*.*/disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/ssid=*.*/ssid=Xiaomi_402/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 设置wifi加密方式为psk2+ccmp,wifi密码为88888889
#sed -i 's/encryption=none/encryption=psk2+ccmp/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
#sed -i '/set wireless.default_radio${devidx}.encryption=psk2+ccmp/a\\t\t\tset wireless.default_radio${devidx}.key=88888889' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 设置无线的国家代码为CN,wifi的默认功率为20
sed -i 's/country=US/country=CN/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.radio${devidx}.disabled=0/a\\t\t\tset wireless.radio${devidx}.txpower=20' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 修改默认IP
#sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 删除ipv6前缀
sed -i 's/auto//' package/base-files/files/bin/config_generate

# 移除要替换的包
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/packages/net/msd_lite
#rm -rf feeds/packages/net/smartdns
#rm -rf feeds/luci/themes/luci-theme-argon
#rm -rf feeds/luci/themes/luci-theme-argon-mod
#rm -rf feeds/luci/applications/luci-app-argon-config
#rm -rf feeds/luci/themes/luci-theme-netgear
#rm -rf feeds/luci/applications/luci-app-mosdns
#rm -rf feeds/luci/applications/luci-app-netdata
#rm -rf feeds/luci/applications/luci-app-serverchan
#rm -rf feeds/package/helloworld
rm -rf feeds/packages/lang/golang
#rm -rf feeds/packages/lang/rust
#rm -rf feeds/packages/net/v2ray-geodata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
git_sparse_clone main https://github.com/djylb/nps-openwrt luci-app-npc package/luci-app-npc
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash package/luci-app-openclash
git_sparse_clone main https://github.com/xiaorouji/openwrt-passwall luci-app-passwall package/luci-app-passwall
git_sparse_clone main https://github.com/xiaorouji/openwrt-passwall2 luci-app-passwall2 package/luci-app-passwall2
git clone https://github.com/sirpdboy/luci-app-lucky.git package/luci-app-lucky
git clone https://github.com/xiaoxiao29/luci-app-adguardhome.git package/luci-app-adguardhome
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush package/luci-app-wechatpush
git_sparse_clone main https://github.com/kiddin9/kwrt-packages wrtbwmon package/wrtbwmon
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
git clone https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
#git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
#git_sparse_clone main https://github.com/498110811/packages_rust rust feeds/packages/lang/rust
#新增风扇通用控制插件
# git_sparse_clone main https://github.com/kiddin9/kwrt-packages fancontrol package/fancontrol
# git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-fancontrol package/luci-app-fancontrol
git_sparse_clone main https://github.com/fanteral/luci-app-fancontrol luci-app-fancontrol package/luci-app-fancontrol

git_sparse_clone main https://github.com/kiddin9/kwrt-packages cloudreve package/cloudreve
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-cloudreve package/luci-app-cloudreve
# git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-guest-wifi package/luci-app-guest-wifi
# git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-npc package/luci-app-npc
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-pikpak-webdav package/luci-app-pikpak-webdav
git_sparse_clone main https://github.com/kiddin9/kwrt-packages pikpak-webdav package/pikpak-webdav

# 科学上网插件
#git clone --depth=1 https://github.com/fw876/helloworld.git package/luci-app-ssr-plus
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2

# Themes
#git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
#git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon
#git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config
#git clone --depth=1 https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/luci-theme-infinityfreedom
#git_sparse_clone main https://github.com/haiibo/packages luci-theme-atmaterial luci-theme-opentomcat luci-theme-netgear
git clone --depth=1 https://github.com/kenzok78/luci-theme-design package/luci-theme-design
git clone --depth=1 https://github.com/kenzok78/luci-app-design-config package/luci-app-design-config

# 更改 Argon 主题背景
#cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 晶晨宝盒
#git_sparse_clone main https://github.com/ophub/luci-app-amlogic luci-app-amlogic
#sed -i "s|firmware_repo.*|firmware_repo 'https://github.com/haiibo/OpenWrt'|g" package/luci-app-amlogic/root/etc/config/amlogic
# sed -i "s|kernel_path.*|kernel_path 'https://github.com/ophub/kernel'|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8_PLUS|g" package/luci-app-amlogic/root/etc/config/amlogic

# SmartDNS
#git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# msd_lite
#git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
#git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# MosDNS
#git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
#git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
#git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Alist
#git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# DDNS.to
#git_sparse_clone main https://github.com/linkease/nas-packages-luci luci/luci-app-ddnsto
#git_sparse_clone master https://github.com/linkease/nas-packages network/services/ddnsto

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 友善uboot
#sed -i '/^UBOOT_TARGETS := rk3528-evb rk3588-evb/s/^/#/' package/boot/uboot-rk35xx/Makefile

# x86 型号只显示 CPU 型号
#sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by LEDE/g" package/lean/default-settings/files/zzz-default-settings

# 修复 hostapd 报错
#cp -f $GITHUB_WORKSPACE/script/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# 修复 armv8 设备 xfsprogs 报错
#sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

# 修改 Makefile
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 取消主题默认设置
#find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 调整 V2ray服务器 到 VPN 菜单
# sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/controller/*.lua
# sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/model/cbi/v2ray_server/*.lua
# sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/view/v2ray_server/*.htm

./scripts/feeds update -a
./scripts/feeds install -a
