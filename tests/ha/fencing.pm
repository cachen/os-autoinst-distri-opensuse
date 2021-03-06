# SUSE's openQA tests
#
# Copyright (c) 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Execute fence command on one of the cluster nodes
# Maintainer: Loic Devulder <ldevulder@suse.com>

use base 'hacluster';
use strict;
use testapi;
use autotest;
use lockapi;

sub run {
    my $self = shift;
    barrier_wait('BEFORE_FENCING_' . $self->cluster_name);
    if ($self->is_node(1)) {
        reset_consoles;
    }
    elsif ($self->is_node(2)) {
        # Fence the node
        assert_script_run 'crm -F node fence ' . get_var('HA_CLUSTER_JOIN');

        # Wait to be sure that node is fenced and HA has time to recover
        sleep 120;
    }

    # Do a check of the cluster with a screenshot
    $self->save_state;
}

sub test_flags {
    return {milestone => 1, fatal => 1};
}

sub post_fail_hook {
    my $self = shift;

    # Save a screenshot before trying further measures which might fail
    save_screenshot;

    # Try to save logs as a last resort
    $self->export_logs();
}

1;
# vim: set sw=4 et:
