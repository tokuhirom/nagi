use inc::Module::Install;
name 'Franck';
all_from 'lib/Franck.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
