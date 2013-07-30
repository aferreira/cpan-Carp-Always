#perl -T 

use strict;
use Test::More;

BEGIN {
    unless ($ENV{RELEASE_TESTING}) {
        plan(skip_all => 'these tests are for release candidate testing');
    }
}

use Test::Pod 1.18;
all_pod_files_ok(all_pod_files("."));
