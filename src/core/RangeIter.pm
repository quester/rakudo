
multi sub RangeIterCmp($a, $b) {
    $a cmp $b;
}

multi sub RangeIterCmp(Str $a, Str $b) {
    $a.chars <=> $b.chars || $a cmp $b;
}

class RangeIter is Iterator {
    has $!value;
    has $!max;
    has $!excludes_max;
    has $!last_flag;

    multi method new(Range $r) {
        self.bless(*, :value($r.excludes_min ?? $r.min.succ !! $r.min),
                      :max($r.max),
                      :excludes_max($r.excludes_max),
                      :last_flag(False)
                    );
    }

    method get() {
        my $current = $!value;
        if $!last_flag {
            return EMPTY;
        }
        unless $!max ~~ ::Whatever {
            if RangeIterCmp($current, $!max) == 1
               || $!excludes_max && RangeIterCmp($current, $!max) != -1 {
                return EMPTY;
            }
        }
        $!value .= succ;
        if ($!value cmp $current) == 0 {
            $!last_flag = True;
        }
        $current;
    }
}
