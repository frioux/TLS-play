#!/usr/bin/env perl

use 5.20.1;
use warnings;

use IO::Socket::SSL;

use experimental 'signatures';

$IO::Socket::SSL::DEBUG = 3;

my $client = IO::Socket::SSL->new(
   PeerHost => '127.0.0.1',
   PeerPort => 9932,
   SSL_key_file  => './host.key',
   SSL_cert_file => './host.crt',
   SSL_use_cert => 1,
   SSL_verify_callback => sub ($, $, $, $, $x509, @) {
      warn "verifying\n";
      (lc Net::SSLeay::X509_get_fingerprint($x509, 'sha256') =~ s/://gr) eq 'cd4723f0b6415e4784518ebf8c89541c99088ac9431ada9f03ac16fe587c47bf' ? 1 : 0
   },

   SSL_ca_file => './rootCA.crt',
) or die "failed connect or ssl handshake: $!,$SSL_ERROR";
