#perl -T 
use strict;
use warnings;

use Test::More tests => 4;
use Carp;

my $OUTFILE = 'test-block.pl';
my @PERL5OPTS = ((map "-I$_", @INC), '-MCarp::Always');

sub is_output {
    my ($code, $expected, $name) = @_;
    $expected =~ s/\.$//m
      if $Carp::VERSION < '1.25';

    open my $fh, '>', $OUTFILE or die "can't write to $OUTFILE: $!";
    print { $fh } $code;
    close $fh;

    open my $execution, join(' ', $^X, @PERL5OPTS, $OUTFILE) . ' 2>&1 |'
      or die "Couldn't open subprocess: $!\n";
    my $output = do { local $/; <$execution> };
    close $execution;
    unlink($OUTFILE)
      or die "Couldn't unlink $OUTFILE: $!\n";

    is $output, $expected, $name;
}

is_output <<'END_CODE', <<'END_OUTPUT', 'basic test';
package A;

sub f {
#line 1
    warn  "Beware!";
}

sub g {
#line 2
    f();
}

package main;

#line 3
A::g();
END_CODE
Beware! at test-block.pl line 1.
	A::f() called at test-block.pl line 2
	A::g() called at test-block.pl line 3
END_OUTPUT

is_output <<'END_CODE', <<'END_OUTPUT', 'interpreter-thrown warnings';
package A;

sub f {
	use strict;
	my $a;
#line 1
	my @a = @$a;
}

sub g {
#line 2
	f();
}

package main;

#line 3
A::g();

END_CODE
Can't use an undefined value as an ARRAY reference at test-block.pl line 1.
	A::f() called at test-block.pl line 2
	A::g() called at test-block.pl line 3
END_OUTPUT

is_output <<'END_CODE', <<'END_OUTPUT', 'foo at bar';
die "foo at bar"
END_CODE
foo at bar at test-block.pl line 1.
END_OUTPUT

is_output <<'END_CODE', <<'END_OUTPUT', 'exception objects';

package error;
use overload '""' => sub { "Exception: " . shift->{error} . "\n" };

package main;
die bless { error => 'bad' }, error;

END_CODE
Exception: bad
END_OUTPUT

