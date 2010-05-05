## $Id$

=head1 NAME

src/classes/Callable.pir - Callable Role

=head1 DESCRIPTION

This implements the parametric role Callable[::T = Mu].

=cut

.namespace ['Callable[::T]']

.sub '' :load :init
    # Create a parametric role with 1 possible candidate.
    .local pmc role
    .const 'Sub' $P0 = '_callable_role_body'
    role = new ['Perl6Role']
    $P1 = box 'Callable'
    setattribute role, '$!shortname', $P1
    role.'!add_variant'($P0)
    set_hll_global 'Callable', role
.end


# This defines the body of the role, which is run per type the role is
# parameterized with.
.sub '' :subid('_callable_role_body')
    .param pmc type :optional

    .const 'Sub' $P0 = 'callable_role_returns'
    capture_lex $P0
    .const 'Sub' $P1 = 'callable_role_of'
    capture_lex $P1

    # Capture type.
    if null type goto no_type
    type = type.'WHAT'()
    goto type_done
  no_type:
    type = get_hll_global 'Mu'
  type_done:
    .lex 'T', type

    # Create role.
    .tailcall '!create_parametric_role'("Callable[::T]")
.end
.sub '' :load :init
    .local pmc block, signature
    .const 'Sub' $P0 = '_callable_role_body'
    block = $P0
    signature = allocate_signature 1
    setprop block, "$!signature", signature
    null $P1
    set_signature_elem signature, 0, "T", SIG_ELEM_IS_OPTIONAL, $P1, $P1, $P1, $P1, $P1, $P1, ""
.end


=item returns

Returns the type constraining what may be returned.

=cut

.sub 'returns' :method :outer('_callable_role_body') :subid('callable_role_returns')
    $P0 = find_lex 'T'
    .return ($P0)
.end
.sub '' :load :init
    .local pmc block, signature
    .const 'Sub' $P0 = 'callable_role_returns'
    block = $P0
    signature = allocate_signature 0
    setprop block, "$!signature", signature
.end


=item of

Returns the type constraining what may be returned.

=cut

.sub 'of' :method :outer('_callable_role_body') :subid('callable_role_of')
    $P0 = find_lex 'T'
    .return ($P0)
.end
.sub '' :load :init
    .local pmc block, signature
    .const 'Sub' $P0 = 'callable_role_of'
    block = $P0
    signature = allocate_signature 0
    setprop block, "$!signature", signature
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

