#!/usr/bin/env perl

use 5.20.0;
use warnings;

use experimental 'signatures';

use IO::Async::Loop;
use IO::Async::SSL;
use IO::Async::SSLStream;

$IO::Socket::SSL::DEBUG = 3;

my $loop = IO::Async::Loop->new;

my $server = $loop->SSL_listen(
   host     => '0.0.0.0',
   socktype => 'stream',
   service  => 9932,

   SSL_key_file  => './host.key',
   SSL_cert_file => './host.crt',
   SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_PEER | IO::Socket::SSL::SSL_VERIFY_FAIL_IF_NO_PEER_CERT,
   SSL_verify_callback => sub ($, $, $, $, $x509, @) {
      (lc Net::SSLeay::X509_get_fingerprint($x509, 'sha256') =~ s/://gr) eq 'cd4723f0b6415e4784518ebf8c89541c99088ac9431ada9f03ac16fe587c47bf' ? 1 : 0
   },

   on_stream => sub ($stream) {
      $stream->configure(
         on_read => sub ($self, $buffref, $eof) {
            $stream->write($stream->read_handle->get_fingerprint . ': ' . $$buffref);
            $$buffref = '';
            0
         },
      );

      $loop->add( $stream );
   },

   on_ssl_error     => sub { die "Cannot negotiate SSL - $_[-1]\n"; },
   on_resolve_error => sub { die "Cannot resolve - $_[1]\n"; },
   on_listen_error  => sub { die "Cannot listen - $_[1]\n"; },

   on_listen => sub ($s) {
      warn "listening on: " . $s->sockhost . ':' . $s->sockport . "\n";
   },

);

$loop->run;
