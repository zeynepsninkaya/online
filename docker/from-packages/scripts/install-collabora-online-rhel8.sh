#!/bin/sh
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.


# Install some more fonts (I did not find open-sans-fonts in RHEL repos)
# dnf install -y open-sans-fonts

# Install cpio (missing dependency needed by loolwsd-systemplate-setup)
dnf install -y cpio

# Install gnupg2
dnf install -y gnupg2

# install ca-certificates
dnf install -y ca-certificates

# install ssh-keygen binary for the WOPI proof key
dnf install -y openssh

# Install curl for simple healthchecks and wget
dnf install -y curl wget

# Add Collabora repos
wget https://collaboraoffice.com/${repo:-repos}/CollaboraOnline/CODE-centos8/repodata/repomd.xml.key && rpm --import repomd.xml.key

if [ "$type" == "cool" ] && [ -n ${secret_key+set} ]; then
    echo "Based on the provided build arguments Collabora Online from customer repo will be used."
    dnf config-manager --add-repo https://collaboraoffice.com/${repo:-repos}/CollaboraOnline/${version:-6.4}/customer-centos8-${secret_key}
elif [ "$type" == "key" ]; then
    echo "Based on the provided build arguments license key enabled Collabora Online was selected, but it's available only on Ubuntu. Collabora Online Development Edition will be used."
    type="code"
    dnf config-manager --add-repo https://collaboraoffice.com/${repo:-repos}/CollaboraOnline/CODE-centos8
else
    echo "Based on the provided build arguments Collabora Online Development Edition will be used."
    dnf config-manager --add-repo https://collaboraoffice.com/${repo:-repos}/CollaboraOnline/CODE-centos8
fi

# Install the Collabora packages
if [ "$version" == "4.2" ] && [ "$type" != "code" ]; then
    corever=6.2
else
    corever=6.4
fi

dnf install -y loolwsd collaboraoffice$corever-dict* collaboraofficebasis$corever-ar collaboraofficebasis$corever-as collaboraofficebasis$corever-ast collaboraofficebasis$corever-bg collaboraofficebasis$corever-bn-IN collaboraofficebasis$corever-br collaboraofficebasis$corever-ca collaboraofficebasis$corever-calc collaboraofficebasis$corever-ca-valencia collaboraofficebasis$corever-core collaboraofficebasis$corever-cs collaboraofficebasis$corever-cy collaboraofficebasis$corever-da collaboraofficebasis$corever-de collaboraofficebasis$corever-draw collaboraofficebasis$corever-el collaboraofficebasis$corever-en-GB collaboraofficebasis$corever-en-US collaboraofficebasis$corever-es collaboraofficebasis$corever-et collaboraofficebasis$corever-eu collaboraofficebasis$corever-extension-pdf-import collaboraofficebasis$corever-fi collaboraofficebasis$corever-fr collaboraofficebasis$corever-ga collaboraofficebasis$corever-gd collaboraofficebasis$corever-gl collaboraofficebasis$corever-graphicfilter collaboraofficebasis$corever-gu collaboraofficebasis$corever-he collaboraofficebasis$corever-hi collaboraofficebasis$corever-hr collaboraofficebasis$corever-hu collaboraofficebasis$corever-id collaboraofficebasis$corever-images collaboraofficebasis$corever-impress collaboraofficebasis$corever-is collaboraofficebasis$corever-it collaboraofficebasis$corever-ja collaboraofficebasis$corever-km collaboraofficebasis$corever-kn collaboraofficebasis$corever-ko collaboraofficebasis$corever-lt collaboraofficebasis$corever-lv collaboraofficebasis$corever-ml collaboraofficebasis$corever-mr collaboraofficebasis$corever-nb collaboraofficebasis$corever-nl collaboraofficebasis$corever-nn collaboraofficebasis$corever-oc collaboraofficebasis$corever-ooofonts collaboraofficebasis$corever-ooolinguistic collaboraofficebasis$corever-or collaboraofficebasis$corever-pa-IN collaboraofficebasis$corever-pl collaboraofficebasis$corever-pt collaboraofficebasis$corever-pt-BR collaboraofficebasis$corever-ro collaboraofficebasis$corever-ru collaboraofficebasis$corever-sk collaboraofficebasis$corever-sl collaboraofficebasis$corever-sr collaboraofficebasis$corever-sr-Latn collaboraofficebasis$corever-sv collaboraofficebasis$corever-ta collaboraofficebasis$corever-te collaboraofficebasis$corever-tr collaboraofficebasis$corever-uk collaboraofficebasis$corever-vi collaboraofficebasis$corever-writer collaboraofficebasis$corever-zh-CN collaboraofficebasis$corever-zh-TW

if [ "$type" == "cool" ] || [ "$type" == "key" ]; then
    dnf -y install collabora-online-brand
else
    dnf -y install CODE-brand
fi

# Install inotifywait and killall to automatic restart loolwsd, if loolwsd.xml changes
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y inotify-tools psmisc perl

# Cleanup
dnf clean all

# Remove WOPI Proof key generated by the package, we need unique key for each container
rm -rf /etc/loolwsd/proof_key*

# Fix permissions
chown -R lool:lool /opt/
chown -R lool:lool /etc/loolwsd