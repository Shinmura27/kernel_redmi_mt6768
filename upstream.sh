#!/usr/bin/env bash

# Secret Variable for GH ACT
# KERNEL_NAME | Your kernel name
# TG_TOKEN | Your Telegram Bot Token
# TG_CHAT_ID | Your Telegram Channel / Group Chat ID
# GH_USERNAME | Your Github Username
# GH_EMAIL | Your Github Email
# GH_TOKEN | Your Github Token ( repo & repo_hook )
# GH_PUSH_REPO_URL | Your Repository for store compiled Toolchain ( without https:// or www. ) ex. github.com/xyz-prjkt/xRageTC.git

# Function to show an informational message
msg() {
    echo -e "\e[1;32m$*\e[0m"
}

err() {
    echo -e "\e[1;41m$*\e[0m"
}

# Set a directory
DIR="$(pwd ...)"

# Inlined function to post a message
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"
tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"

}
tg_post_build() {
	curl --progress-bar -F document=@"$1" "$BOT_MSG_URL" \
	-F chat_id="$TG_CHAT_ID"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$3"
}

# Build Info
rel_date="$(date "+%Y%m%d")" # ISO 8601 format
rel_friendly_date="$(date "+%B %-d, %Y")" # "Month day, year" format
builder_commit="$(git rev-parse HEAD)"

# Send a notificaton to TG
tg_post_msg "<b>$LLVM_NAME: Kernel Upstreamer Script Started</b>%0A<b>Date : </b><code>$rel_friendly_date</code>%0A<b>Linux Version : </b><code>$LINUXVER</code>%0A"

# Build LLVM
msg "$KERNEL_NAME: Upstreaming To $LINUXVER"
tg_post_msg "<b>$KERNEL_NAME: Upstreaming To $LINUXVER</b>"
TomTal=$(nproc)
if [[ ! -z "${2}" ]];then
    TomTal=$(($TomTal*2))
fi

#upstream
git remote add upstream https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/
git fetch upstream $LINUXVER
git merge FETCH_HEAD

tg_post_msg "<b>$LLVM_NAME: Upstream Complete</b>%0A<b>Linux Version : </b><code>$LINUXVER</code>%0A<b>

# Push to GitHub
# Update Git repository
git config --global user.name $GH_USERNAME
git config --global user.email $GH_EMAIL
pushd rel_repo || exit
rm -fr ./*
cp -r ../install/* .
git checkout README.md # keep this as it's not part of the toolchain itself
git add .
git commit -asm "$KERNEL_NAME: Bump to $rel_date build

Builder commit: https://$GH_PUSH_REPO_URL/commit/$builder_commit"
git push -f
popd || exit
tg_post_msg "<b>$LLVM_NAME: Toolchain pushed to <code>https://$GH_PUSH_REPO_URL</code></b>"
