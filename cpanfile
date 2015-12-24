requires 'perl', '5.006';
requires 'strict';
requires 'warnings';
requires 'Test::Builder';

requires 'Exporter::Tidy';

on test => sub {
	requires 'Test::Builder::Tester';
	requires 'Test::More';
};

# vim: ft=perl
