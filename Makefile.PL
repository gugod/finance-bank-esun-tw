use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/Finance/Bank/Esun/TW.pm';

build_requires  'Test::More'        => '0.42';

requires
    'WWW::Mechanize' => 1.50,
    'Text::Trim' => 0,
    'HTML::TableExtract' => 1.50,
    'List::MoreUtils' => 0;

WriteAll;


