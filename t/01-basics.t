#!perl

use 5.010;
use strict;
use warnings;

use Module::XSOrPP qw(is_xs is_pp);
use Test::More 0.98;

ok( is_xs("List::Util"));
ok(!is_pp("List::Util"));

ok(!is_xs("Test::More"));
ok( is_pp("Test::More"));

ok(!defined(is_xs("FooBar")));

done_testing;
