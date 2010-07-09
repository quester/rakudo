## $Id$

=head1 NAME

src/glue/role.pir - internals bits to do with roles

=head1 SUBS

=over 4

.namespace []

=item !create_master_role

Creates a master-role object, containing all the various role variants.

=cut

.sub '!create_master_role'
    .param pmc shortname
    .param pmc existing :optional
    if null existing goto need_new
    $I0 = isa existing, 'Perl6Role'
    unless $I0 goto need_new
    .return (existing)
  need_new:
    $P0 = new ['Perl6Role']
    transform_to_p6opaque $P0
    setattribute $P0, '$!shortname', shortname
    .return ($P0)
.end


=item !create_parametric_role

Helper method for creating parametric roles from PIR. Note that
this just assumes we source methods from the Parrot namespace,
and that the roles have no attributes, don't do any other roles
and so forth.

=cut

.sub '!create_parametric_role'
    .param string name

    # Parse the name.
    .local pmc nsarray
    $P0 = get_hll_global [ 'Perl6';'Grammar' ], 'parse_name'
    nsarray = $P0(name)

    # This is a little fun. We only want to create the Parrot role and suck
    # in the methods once per role definition. We do this and it is attached to
    # the namespace. After that, we can just use it to suck in methods and
    # build up a proper role through the HOW.
    .local pmc ns, info, parrotrole
    ns = get_hll_namespace nsarray
    parrotrole = get_class ns
    unless null parrotrole goto have_role
    info = root_new ['parrot';'Hash']
    $P0 = nsarray[-1]
    info['name'] = $P0
    info['namespace'] = nsarray
    parrotrole = root_new ['parrot';'P6role'], info
  have_role:

    # Create new HOW instance.
    .local pmc RoleHOW, role, how
    RoleHOW = get_hll_global 'RoleHOW'
    role = RoleHOW.'new'()
    how = role.'HOW'()

    # Clone all of the methods from the Parrot role, to make sure they
    # capture type variables as they currently stand. Provided Method is
    # defined, we also wrap the Parrot subs in it.
    .local pmc meths, meth_iter, Method
    Method = get_hll_global 'Method'
    $I0 = isa Method, 'NameSpace'
    unless $I0 goto method_check_done
    die "Attempt to create role when Method not defined"
    null Method
  method_check_done:
    meths = parrotrole.'methods'()
    meth_iter = iter meths
  it_loop:
    unless meth_iter goto it_loop_end
    $S0 = shift meth_iter
    $P0 = meths[$S0]
    if null Method goto unwrapped
    $P1 = $P0.'!get_closure'(Method)
    goto have_method
  unwrapped:
    $P1 = clone $P0
    $P2 = prophash $P0
    x_setprophash $P1, $P2
  have_method:
    how.'add_method'(role, $S0, $P1)
    goto it_loop
  it_loop_end:

    # Compose and we're done.
    $P1 = how.'compose'(role)
    .return ($P1)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
