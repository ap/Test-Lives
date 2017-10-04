use 5.006; use strict; use warnings;

package Test::Lives;

# ABSTRACT: decorate tests with a no-exceptions assertion

use Test::Builder ();

my $Tester = Test::Builder->new;
*Level = \$Test::Builder::Level;

sub lives_and (&;$) {
	my ( $code, $name ) = @_;

	local our $Level = $Level + 1; # this function

	my $ok;

	eval {
		local $Level = $Level + 2; # eval block + callback
		local $Carp::Internal{(__PACKAGE__)} = 1;
		$ok = $code->() for $name;
		1;
	} or do {
		my $e = "$@";
		$ok = $Tester->ok( 0, $name );
		$Tester->diag( $e );
	};

	return $ok;
}

sub import {
	my $class = shift;
	do { die "Unknown symbol: $_" if $_ ne 'lives_and' } for @_;
	no strict 'refs';
	*{ caller . '::lives_and' } = \&lives_and;
}

1;

__END__

=pod

=head1 SYNOPSIS

 use Test::More;
 use Test::Lives;

 use System::Under::Test 'might_die';

 lives_and { is might_die, 'correct', $_ } 'system under test is correct';

=head1 DESCRIPTION

This module provides only one function, C<lives_and>, which allows you to test
things that could (but shouldn't) throw an exception, without having to have
two separate tests with two separate results (and two separate descriptions).

You pass it a block of code to run (which should contain one test assertion)
and a test description to give the assertion inside the block.

The description will be available inside the block in the C<$_> variable.

If the block ends up throwing an exception, a test failure will be logged.

=head1 SEE ALSO

=over 4

=item * L<Test::Exception>

The original perpetrator of the C<lives_and> design as an assertion decorator.
Unfortunately it has grown several questionable dependencies.

=item * L<Test::Fatal>

Recommended for any exception-related testing needs beyond C<lives_and>.

=back
