#perl -T 

BEGIN {
    eval { require Test::Base };
    if ($@) {
        require Test::More;
        Test::More::plan(skip_all => "Test::Base required for module tests");
    }
}

use Test::Base;

my $OUTFILE = 'test-block.pl';
my $PERL5OPTS = '-Mblib -MCarp::Always';

sub Test::Base::Filter::exec_perl_stderr {
    my $self = shift;       # The Test::Base::Filter object
    my $tmpfile = $OUTFILE;
    $self->_write_to($tmpfile, @_);
    open my $execution, "$^X $PERL5OPTS $OUTFILE 2>&1 |"
      or die "Couldn't open subprocess: $!\n";
    local $/;
    my $output = <$execution>;
    close $execution;
    unlink($tmpfile)
      or die "Couldn't unlink $tmpfile: $!\n";
    return $output;
}

filters { perl => 'exec_perl_stderr' };
run_is_deeply 'perl', 'stderr';

__END__

=== basic test
--- perl

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

--- stderr
Beware! at test-block.pl line 1
	A::f() called at test-block.pl line 2
	A::g() called at test-block.pl line 3

=== interpreter-thrown warnings

--- perl

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

--- stderr
Can't use an undefined value as an ARRAY reference at test-block.pl line 1
	A::f() called at test-block.pl line 2
	A::g() called at test-block.pl line 3
