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
   addr => {
      family   => 'inet',
      socktype => 'stream',
      port     => 9932,
      ip       => '127.0.0.1',
   },

   SSL_key_file  => './host.key',
   SSL_cert_file => './host.crt',

   on_stream => sub {
      my ( $stream ) = @_;

      $stream->configure(
         on_read => sub ($self, $buffref, $eof) {
            $stream->write($$buffref);
            $$buffref = '';
            0
         },
      );

      $loop->add( $stream );
   },

   on_ssl_error     => sub { print STDERR "Cannot negotiate SSL - $_[-1]\n"; },
   on_resolve_error => sub { die "Cannot resolve - $_[1]\n"; },
   on_listen_error  => sub { die "Cannot listen - $_[1]\n"; },
);

$loop->run;
