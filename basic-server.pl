#!/usr/bin/env perl

use 5.20.0;
use warnings;

use IO::Socket::SSL;
$IO::Socket::SSL::DEBUG = 3;

# simple server
my $server = IO::Socket::SSL->new(
    # where to listen
    LocalAddr => '127.0.0.1',
    LocalPort => 9934,
    Listen => 10,

    # which certificate to offer
    # with SNI support there can be different certificates per hostname
    SSL_cert_file => './host.crt',
    SSL_key_file => './host.key',
) or die "failed to listen: $!";

# accept client
my $client = $server->accept or die
    "failed to accept or ssl handshake: $!,$SSL_ERROR";

while (my $line = <$client>) {
   print $client $line
}
