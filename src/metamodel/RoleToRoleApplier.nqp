=begin

=head1 TITLE

Perl6::Metamodel::RoleToRoleApplier

=head1 DESCRIPTION

Applies roles to another role.

=head1 METHODS

=over 4

=item apply(target, composees)

Applies all of the composees to target.

=end

class Perl6::Metamodel::RoleToRoleApplier;

method apply($target, @composees) {
    # Aggregate all of the methods sharing names.
    my %meth_info;
    for @composees {
        my @methods := $_.HOW.methods($_);
        for @methods {
            my $name := ~$_;
            my $meth := $_;
            my @meth_list;
            if pir::defined(%meth_info{$name}) {
                @meth_list := %meth_info{$name};
            }
            else {
                %meth_info{$name} := @meth_list;
            }
            my $found := 0;
            for @meth_list {
                if $meth =:= $_ {
                    $found := 1;
                }
            }
            unless $found {
                @meth_list.push($meth);
            }
        }
    }

    # Also need methods of target.
    my %target_meth_info;
    my @target_meths := $target.HOW.methods($target);
    for @target_meths {
        %target_meth_info{~$_} := $_;
    }

    # Process method list.
    for %meth_info {
        my $name := ~$_;
        my @add_meths := %meth_info{$name};

        # Do we already have a method of this name? If so, ignore all of the
        # methods we have from elsewhere unless it's multi.
        if pir::defined(%target_meth_info{$name}) {
            if %target_meth_info{$name}.multi {
                # Add them anyway.
                for @add_meths {
                    $target.HOW.add_method($target, $name, $_);
                }
            }
        }
        else {
            # No methods in the target role. If only one, it's easy...
            if +@add_meths == 1 {
                $target.HOW.add_method($target, $name, @add_meths[0]);
            }
            else {
                # More than one - add to collisions list unless all multi.
                my $num_multi := 0;
                for @add_meths {
                    if $_.multi { $num_multi := $num_multi + 1; }
                }
                if +@add_meths == $num_multi {
                    for @add_meths {
                        $target.HOW.add_method($target, $name, $_);
                    }
                }
                else {
                    $target.HOW.add_collision($target, $name);
                }
            }
        }
    }

    # Now do the other bits.
    my @all_composees;
    for @composees {
        my $how := $_.HOW;

        # Compose is any attributes, unless there's a conflict.
        my @attributes := $how.attributes($_);
        for @attributes {
            my $add_attr := $_;
            my $skip := 0;
            my @cur_attrs := $target.HOW.attributes($target, :local(1));
            for @cur_attrs {
                if $_ =:= $add_attr {
                    $skip := 1;
                }
                else {
                    if $_.name eq $add_attr.name {
                        pir::die("Attribute '" ~ $_.name ~ "' conflicts in role composition");
                    }
                }
            }
            unless $skip {
                $target.HOW.add_attribute($target, $add_attr);
            }
        }

        # Pass along any requirements.
        my @requirements := $how.requirements($_);
        for @requirements {
            $target.HOW.add_requirement($target, $_);
        }

        # Pass along any parents.
        my @parents := $how.parents($_);
        for @parents {
            $target.HOW.add_parent($target, $_);
        }

        # Build up full list.
        my @composees := $how.composees($_, :transitive(1));
        for @composees {
            @all_composees.push($_);
        }
    }

    return @all_composees;
}

=begin

=back

=end
