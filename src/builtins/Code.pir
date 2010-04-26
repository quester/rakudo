## $Id$

=head1 TITLE

Code - Perl 6 Code class

=head1 DESCRIPTION

This file sets up the Perl 6 C<Code> class, the base class
for executable objects.

=cut

.namespace ['Code']

.sub 'onload' :anon :load :init
    .local pmc p6meta, codeproto
    p6meta = get_hll_global ['Mu'], '$!P6META'
    $P0 = get_hll_global 'Callable'
    codeproto = p6meta.'new_class'('Code', 'parent'=>'Cool', 'attr'=>'$!do $!multi $!signature $!lazy_sig_init', 'does_role'=>$P0)
    $P1 = new ['Role']
    $P1.'name'('invokable')
    p6meta.'compose_role'(codeproto, $P1)
.end


=item new(do)

=cut

.sub 'new' :method
    .param pmc do
    .param pmc multi
    .param pmc lazy_sig_init :optional
    $P0 = getprop '$!p6type', do
    if null $P0 goto need_create
    .return ($P0)
  need_create:
    $P0 = self.'HOW'()
    $P0 = getattribute $P0, 'parrotclass'
    $P0 = new $P0
    transform_to_p6opaque $P0
    setattribute $P0, '$!do', do
    setattribute $P0, '$!multi', multi
    setattribute $P0, '$!lazy_sig_init', lazy_sig_init
    if multi != 2 goto proto_done
    $P1 = box 1
    setprop $P0, 'proto', $P1
  proto_done:
    setprop do, '$!p6type', $P0
    .return ($P0)
.end


=item clone(do)

=cut

.sub 'clone' :method
    $P0 = getattribute self, '$!do'
    $P0 = clone $P0
    $P1 = getattribute self, '$!multi'
    $P2 = getattribute self, '$!lazy_sig_init'
    $P3 = self.'new'($P0, $P1, $P2)
    .return ($P3)
.end


=item assumming()

Returns a curried version of self.

=cut

.sub 'assuming' :method :subid('assuming')
    .param pmc args :slurpy
    .param pmc named_args :slurpy :named
    .local pmc curried
    .lex '@args', args
    .lex '%args', named_args
    .lex '$obj', self
    .const 'Sub' curried = 'assuming_helper'
    # capture_lex curried
    curried = newclosure curried
    .return (curried)
.end

.sub 'assuming_helper' :outer('assuming')
    .param pmc args :slurpy
    .param pmc named_args :slurpy :named
    .local pmc obj, assumed_args, assumed_named_args, result
    find_lex obj, '$obj'
    find_lex assumed_args, '@args'
    find_lex assumed_named_args, '%args'
    result = obj(assumed_args :flat, args :flat, assumed_named_args :flat :named, named_args :flat :named)
    .return (result)
.end


=item callwith(...)

Just calls this block with the supplied parameters.

=cut

.sub 'callwith' :method :vtable('invoke')
    .param pmc pos_args    :slurpy
    .param pmc named_args  :slurpy :named
    $P0 = getattribute self, '$!do'
    .tailcall $P0(pos_args :flat, named_args :flat :named)
.end


=item multi

=cut

.sub 'multi' :method
    $P0 = getattribute self, '$!multi'
    if $P0 goto is_multi
    $P1 = get_hll_global ['Bool'], 'False'
    .return ($P1)
  is_multi:
    $P1 = get_hll_global ['Bool'], 'True'
    .return ($P1)
.end


=item name

=cut

.sub 'name' :method
    $S0 = self
    .return ($S0)
.end


=item perl()

Return a response to .perl.

=cut

.namespace ['Code']
.sub 'perl' :method
    .return ('{ ... }')
.end

=item signature()

Gets the signature for the block, or returns Failure if it lacks one.

=cut

.sub 'signature' :method
    .local pmc do, ll_sig, lazy_sig

    # Do we have a cached result?
    $P0 = getattribute self, '$!signature'
    if null $P0 goto create_signature
    .return ($P0)
  create_signature:

    # Look up the signature if the block already has one.
    do = getattribute self, '$!do'
    ll_sig = getprop '$!signature', do
    unless null ll_sig goto have_sig

    # No signautre yet, but maybe we have a lazy creator.
    lazy_sig = getattribute self, '$!lazy_sig_init'
    if null lazy_sig goto srsly_no_sig
push_eh lazyerr
    ll_sig = lazy_sig()
    setprop do, '$!signature', ll_sig
    goto have_sig
  srsly_no_sig:
    .tailcall '!FAIL'('No signature found')

    # Now we have the signature; need to make it a high level one.
  have_sig:
    $P1 = get_hll_global 'Signature'
    $P1 = $P1.'new'('ll_sig' => ll_sig)
    setattribute self, '$!signature', $P1
    .return ($P1)
  lazyerr:
  pop_eh
  say lazy_sig
.end

=item do()

=cut

.sub 'do' :method
    $P0 = getattribute self, '$!do'
    .return ($P0)
.end

=item Str()

=cut

.sub 'Str' :method
    $P0 = getattribute self, '$!do'
    $S0 = $P0
    .return ($S0)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
