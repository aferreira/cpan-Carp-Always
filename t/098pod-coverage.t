#perl -T 

use Test::More;

BEGIN {
    unless ($ENV{RELEASE_TESTING}) {
        plan(skip_all => 'these tests are for release candidate testing');
    }
}

use Test::Pod::Coverage 1.04;
all_pod_coverage_ok();

