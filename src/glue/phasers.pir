=head1 NAME

src/glue/phasers.pir -- internal handling of phasers

=head2 Subs

=over 4

=item !add_phaser(bank, phaser)

Add a phaser to a given C<bank>, which is usually one of
C<BEGIN>, C<CHECK>, C<INIT>, or C<END>.  The C<CHECK>
and C<END> banks have new entries placed at the beginning (LIFO),
all others are at the end.

=cut

.namespace []
.sub '!add_phaser'
    .param string bank
    .param pmc phaser

    .local pmc our, phash, pbank
    our = get_hll_namespace
    $P0 = get_root_namespace ['parrot';'Hash']
    phash = vivify our, '%!PHASERS', $P0
    pbank = vivify phash, bank, ['ResizablePMCArray']
    if bank == 'CHECK' goto bank_lifo
    if bank == 'END' goto bank_lifo
  bank_fifo:
    push pbank, phaser
    goto done
  bank_lifo:
    unshift pbank, phaser
  done:
.end


=item !fire_phasers(bank)

Fire all of the phasers in C<bank>, removing them as we go
and firing them if they haven't been fired yet. Also store
the values that they evaluate to.

=cut

.namespace []
.sub '!fire_phasers'
    .param string bank

    .local pmc our, phash, pbank
    our = get_hll_namespace
    phash = our['%!PHASERS']
    if null phash goto fire_done
    pbank = phash[bank]
    if null pbank goto fire_done

    .local pmc fhash, result
    $P0 = get_root_namespace ['parrot';'Hash']
    fhash = vivify our, '%!PHASERS_FIRED', $P0
  fire_bank:
    unless pbank goto fire_done
    .local pmc phaser
    phaser = shift pbank
    $S0 = phaser.'get_subid'()
    $P0 = fhash[$S0]
    unless null $P0 goto fire_bank
    result = phaser()
    fhash[$S0] = result
    goto fire_bank

  fire_done:
.end


=item !get_phaser_result

Gets the result value that a phaser produced.

=cut

.sub '!get_phaser_result'
    .param string subid
    
    .local pmc our, fhash, result
    our = get_hll_namespace
    $P0 = get_root_namespace ['parrot';'Hash']
    fhash = vivify our, '%!PHASERS_FIRED', $P0
    result = fhash[subid]    
    if null result goto phaser_failed_to_fire_captain
    .return (result)

  phaser_failed_to_fire_captain:
    result = get_hll_global 'Any'
    .return (result)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
