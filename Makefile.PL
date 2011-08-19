
use 5.006;
use ExtUtils::MakeMaker;

my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME              => 'Carp::Always',
    VERSION_FROM      => 'lib/Carp/Always.pm',
    PREREQ_PM         => {
        Carp       => 0,
        Test::More => 0,
    },
    ($] >= 5.005 ? (
        ABSTRACT_FROM => 'lib/Carp/Always.pm',
        AUTHOR        => 'Adriano R. Ferreira <ferreira@cpan.org>'
    ) : ()),
    ($EUMM_VERSION >= 6.31 ? (
        LICENSE => 'perl', 
        EXTRA_META => "recommends:\n    Test::Pod:                     1.18\n" .
                                   "    Test::Pod::Coverage:           1.04\n" .
                                   "    Test::Base:                    0\n",
    ) :())

);
