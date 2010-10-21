use Test::More;

use CPAN::Packages;
use version;

my $pks = CPAN::Packages->new(file => 't/data/02packages.details.txt.gz');
ok(defined($pks), 'got an object');

cmp_ok($pks->get_header('Columns'), 'eq', 'package name, version, path', 'got Columns');

is_deeply([ $pks->get_columns_as_list ], ['package name', 'version', 'path'], 'get_columns_as_list');

my $ach = $pks->get_package('ACH');
cmp_ok($ach->{'package name'}, 'eq', 'ACH', 'package name');
cmp_ok($ach->{version}->stringify, 'eq', version->parse('0.01')->stringify, 'version (stringify)');
cmp_ok($ach->{path}, 'eq', 'C/CP/CPKOIS/ACH/ACH-0.01.tar.gz', 'package path');

diag($pks->as_string);

done_testing;