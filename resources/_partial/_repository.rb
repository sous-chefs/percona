# frozen_string_literal: true

property :version, String, default: '8.4'
property :cluster, [true, false], default: false
property :apt_key, String, default: '/usr/share/keyrings/percona-keyring.gpg'
property :apt_uri, String, default: 'https://repo.percona.com'
property :yum_description, String, default: 'Percona Packages'
property :yum_baseurl, String, default: 'https://repo.percona.com'
property :yum_gpgkey, String, default: 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY'
property :yum_gpgcheck, [true, false], default: true
property :yum_sslverify, [true, false], default: true
