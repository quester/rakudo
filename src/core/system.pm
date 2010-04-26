sub run($commandline) {
    Q:PIR {
        .local pmc    commandline_pmc
        .local string commandline_str
        .local int    status
        commandline_pmc = find_lex '$commandline'
        commandline_str = commandline_pmc
        push_eh run_catch
        spawnw status, commandline_str
        shr status, 8
        goto run_finally
      run_catch:
        status = 255          # is this the most appropriate error code?
      run_finally:
        pop_eh
        %r = box status
    }
}

sub sleep($seconds) {         # fractional seconds also allowed
    my $time1 = time;
    pir::sleep__vN($seconds);
    my $time2 = time;
    return $time2 - $time1;
}

sub time() {
    pir::time__n()
}
