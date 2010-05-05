## $Id$

=head1 TITLE

RoleHOW - default metaclass for Perl 6 roles

=head1 DESCRIPTION

This is the metaclass for roles.

We use a P6role as our backing store. However, we keep a list of parents
separately - we simply pass these on to the class as an "implementation
detail". We also don't want Parrot's immediate-composition semantics, so
we also have an attribute collecting roles to flatten and compose later
on.

=cut

.namespace ['RoleHOW']

.sub 'onload' :anon :init :load
    .local pmc p6meta, rolehowproto
    p6meta = get_hll_global ['Mu'], '$!P6META'
    rolehowproto = p6meta.'new_class'('RoleHOW', 'parent'=>'Mu', 'attr'=>'parrotclass shortname longname protoobject $!parents $!composees $!requirements $!collisions $!attributes $!done')
.end


=item new()

Creates a new instance of the meta-class.

=cut

.sub 'new' :method
    .param pmc name :optional
    .local pmc how, p6role

    # Create P6role object, which is what we will install in the namespace.
    p6role = new ['P6role']

    # Stash in metaclass instance, init a couple of other fields,
    # and associate it with the P6role object, then hand that back.
  have_p6role:
    how = new ['RoleHOW']
    setattribute how, 'parrotclass', p6role
    $P0 = new ['ResizablePMCArray']
    setattribute how, '$!parents', $P0
    $P0 = new ['ResizablePMCArray']
    setattribute how, '$!attributes', $P0
    $P0 = new ['ResizablePMCArray']
    setattribute how, '$!composees', $P0
    $P0 = new ['ResizablePMCArray']
    setattribute how, '$!requirements', $P0
    $P0 = new ['ResizablePMCArray']
    setattribute how, '$!collisions', $P0
    setprop p6role, 'metaclass', how
    setattribute how, 'protoobject', p6role
    
    .return (p6role)
.end


=item add_parent

Stores the parent; we'll add it to a class at compose time.

=cut

.sub 'add_parent' :method
    .param pmc role
    .param pmc parent
    $P0 = getattribute self, '$!parents'
    push $P0, parent
.end


=item add_requirement

Adds the name of a required method to the requirements list for the role.

=cut

.sub 'add_requirement' :method
    .param pmc role
    .param pmc requirement
    $P0 = getattribute self, '$!requirements'
    push $P0, requirement
.end


=item add_collision

Adds the name of a colliding method that needs the class or a role to resolve
it to the collisions list for the role.

=cut

.sub 'add_collision' :method
    .param pmc role
    .param pmc collision
    $P0 = getattribute self, '$!collisions'
    push $P0, collision
.end


=item add_attribute

Adds an attribute to the role.

=cut

.sub 'add_attribute' :method
    .param pmc role
    .param pmc attribute
    $P0 = getattribute self, '$!attributes'
    push $P0, attribute
.end


=item add_composable

Stores something that we will compose (e.g. a role) at class composition time.

=cut

.sub 'add_composable' :method
    .param pmc role
    .param pmc composee
    $P0 = getattribute self, '$!composees'
    push $P0, composee
.end

=item add_meta_method(meta, name, code_ref)

Add a metamethod to the given meta.

=cut

.sub 'add_meta_method' :method
    .param pmc role
    .param string name
    .param pmc meth
    '&die'("Adding meta-methods to roles is not yet implemented.")
.end

=item add_method(meta, name, code_ref)

Add a method to the given meta.

=cut

.sub 'add_method' :method
    .param pmc role
    .param string name
    .param pmc meth
    $P0 = getattribute self, 'parrotclass'
    push_eh add_fail
    addmethod $P0, name, meth
    pop_eh
    .return ()
  add_fail:
    pop_eh
    
    # May be that we need to merge multis.
    $P1 = $P0.'methods'()
    $P1 = $P1[name]
    $I0 = isa $P1, 'MultiSub'
    unless $I0 goto error
    $I0 = isa meth, 'MultiSub'
    unless $I0 goto error
    $P1.'incorporate_candidates'(meth)
    .return ()
  error:
    '&die'('Can not add two methods to a role if they are not multis')
.end

=item methods

Gets the list of methods that this role does.

=cut

.sub 'methods' :method
    .param pmc role
    .local pmc result, it, p6role
    result = root_new ['parrot';'ResizablePMCArray']
    p6role = getattribute self, 'parrotclass'
    $P0 = inspect p6role, 'methods'
    it = iter $P0
  it_loop:
    unless it goto it_loop_end
    $S0 = shift it
    $P1 = $P0[$S0]
    push result, $P1
    goto it_loop
  it_loop_end:
    .return (result)
.end


=item parents

Gets the parents list for this role (e.g. the parents we are passing along for
later being added to the class).

=cut

.sub 'parents' :method
    .param pmc role
    $P0 = getattribute self, '$!parents'
    .return ($P0)
.end


=item requirements

Accessor for list of method names a role requires.

=cut

.sub 'requirements' :method
    .param pmc role
    $P0 = getattribute self, '$!requirements'
    .return ($P0)
.end


=item collisions

Accessor for list of method names in conflict; the class must resolve them.

=cut

.sub 'collisions' :method
    .param pmc role
    $P0 = getattribute self, '$!collisions'
    .return ($P0)
.end


=item attributes

Accessor for list of attributes in the role.

=cut

.sub 'attributes' :method
    .param pmc role
    $P0 = getattribute self, '$!attributes'
    .return ($P0)
.end


=item composees

Returns all of the composees that this role has. With the :trasitive flag
it represents all of those that have been composed in from other roles too.

XXX This is non-spec ATM.

=cut

.sub 'composees' :method
    .param pmc role
    .param pmc transitive :named('transitive') :optional
    if null transitive goto intransitive
    unless transitive goto intransitive
    $P0 = getattribute self, '$!done'
    .return ($P0)
  intransitive:
    $P0 = getattribute self, '$!composees'
    .return ($P0)
.end


=item applier_for

For now, we can't use a class as a composable thing. In the future we can
instead extract a role from the class (or rather, hand back a composer that
knows how to do that).

=cut

.sub 'applier_for' :method
    .param pmc role
    .param pmc for
    
    $I0 = isa for, 'ClassHOW'
    if $I0 goto class_applier
    $I0 = isa for, 'RoleHOW'
    if $I0 goto role_applier
    goto instance_applier

  class_applier:
    $P0 = get_hll_global ['Perl6';'Metamodel'], 'RoleToClassApplier'
    .return ($P0)

  role_applier:
    $P0 = get_hll_global ['Perl6';'Metamodel'], 'RoleToRoleApplier'
    .return ($P0)

  instance_applier:
    $P0 = get_hll_global ['Perl6';'Metamodel'], 'RoleToInstanceApplier'
    .return ($P0)
.end


=item compose(meta)

Completes the creation of the metaclass and return the P6role.

=cut

.sub 'compose' :method
    .param pmc role
    .local pmc p6role
    p6role = getattribute self, 'parrotclass'

    # See if we have anything to compose. Also, make sure our composees
    # all want the same composer.
    .local pmc composees, chosen_applier, composee_it, done
    composees = getattribute self, '$!composees'
    $I0 = elements composees
    if $I0 == 0 goto composition_done
    if $I0 == 1 goto one_composee
    composee_it = iter composees
  composee_it_loop:
    unless composee_it goto apply_composees
    $P0 = shift composee_it
    if null chosen_applier goto first_composee
    $P1 = $P0.'HOW'()
    $P1 = $P1.'applier_for'($P0, self)
    $P2 = chosen_applier.'WHAT'()
    $P3 = $P1.'WHAT'()
    $I0 = '&infix:<===>'($P2, $P3)
    if $I0 goto composee_it_loop
    die 'Can not compose multiple composees that want different appliers'
  first_composee:
    $P1 = $P0.'HOW'()
    chosen_applier = $P1.'applier_for'($P0, self)
    goto composee_it_loop
  one_composee:
    $P0 = composees[0]
    $P1 = $P0.'HOW'()
    chosen_applier = $P1.'applier_for'($P0, self)
  apply_composees:
    done = chosen_applier.'apply'(role, composees)
  composition_done:
    unless null done goto done_done
    done = root_new ['parrot';'ResizablePMCArray']
  done_done:
    done.'unshift'(p6role)
    setattribute self, '$!done', done

    # Associate the metaclass with the p6role.
    .return (role)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
