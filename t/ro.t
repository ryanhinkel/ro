#!perl

use Test::More;
use Test::Mojo;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;

# player 1
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->json_message_is({welcome => 1});
my $p1 = $t->tx;

# player 2
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->json_message_is({welcome => 2});
my $p2 = $t->tx;

$p1 = $p1->send('rock');
$p2 = $p2->send('scissors');

my ($p1_result, $p2_result);
$p1->on(json => sub($c,$msg) { $p1_result = $msg; });
$p2->on(json => sub($c,$msg) { $p2_result = $msg; });
Mojo::IOLoop->timer(1 => sub { shift->stop } );
Mojo::IOLoop->start;

is_deeply $p1_result, {you => "win", opponent => 2, yours => "rock", theirs => "scissors"};
is_deeply $p2_result, {you => "lose", opponent => 1, yours => "scissors", theirs => "rock"};

done_testing();

