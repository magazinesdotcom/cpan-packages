use inc::Module::Install;

name     'CPAN-Packages';
all_from 'lib/CPAN/Packages.pm';
author   q{Cory G Watson <gphat@cpan.org>};
license  'perl';

build_requires 'Test::More';

requires 'File::Slurp';
requires 'IO::Uncompress::Gunzip';
requires 'IO::Uncompress::Gzip';
requires 'Moose';
requires 'version';

WriteAll;

