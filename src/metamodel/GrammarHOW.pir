## $Id$

=head1 TITLE

GrammarHOW - metaclass for grammars.

=head1 DESCRIPTION

This just subclasses the final compose method to make sure we inherit from
Grammar by default.

=cut

.namespace ['GrammarHOW']

.sub 'onload' :anon :init :load
    .local pmc p6meta
    p6meta = get_hll_global ['Mu'], '$!P6META'
    p6meta.'new_class'('GrammarHOW', 'parent'=>'ClassHOW')
.end


=head2 Methods on GrammarHOW

=over

=item compose(meta)

If there is no explicit parent, makes Grammar the default parent and then
delegates to ClassHOW.

=cut

.sub 'compose' :method
    .param pmc obj
    .local pmc parrotclass
    parrotclass = getattribute self, 'parrotclass'
    $P0 = inspect parrotclass, 'parents'
    if $P0 goto have_parents
    $P0 = get_hll_global 'Grammar'
    self.'add_parent'(obj, $P0)
  have_parents:
    $P0 = get_hll_global 'ClassHOW'
    $P0 = find_method $P0, 'compose'
    .tailcall $P0(self, obj)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
