class Rat is Cool does Real {
    has $.numerator;
    has $.denominator;

    our sub gcd(Int $a is copy, Int $b is copy) {
        $a = -$a if ($a < 0);
        $b = -$b if ($b < 0);
        while $a > 0 && $b > 0 {
            ($a, $b) = ($b, $a) if ($b > $a);
            $a %= $b;
        }
        return $a + $b;
    }

    multi method new() {
        self.bless(*, :numerator(0), :denominator(1));

    }

    multi method new(Int $numerator is copy, Int $denominator is copy) {
        if $denominator < 0 {
            $numerator = -$numerator;
            $denominator = -$denominator;
        }
        my $gcd = gcd($numerator, $denominator);
        $numerator = $numerator div $gcd;
        $denominator = $denominator div $gcd;
        self.bless(*, :numerator($numerator), :denominator($denominator));
    }

    multi method ACCEPTS($other) {
        self.Num.ACCEPTS($other);
    }

    multi method perl() { "$!numerator/$!denominator"; }

    method Bridge() {
        $!denominator == 0 ?? Inf * $!numerator.sign
                           !! $!numerator.Bridge / $!denominator.Bridge;
    }

    our Bool multi method Bool() { $!numerator != 0 ?? Bool::True !! Bool::False }

    multi method Num() {
        $!denominator == 0 ?? Inf * $!numerator.sign
                           !! $!numerator.Num / $!denominator.Num;
    }

    multi method Rat() { self; }

    multi method Int() { self.Num.Int; }

    multi method Str() { $.Num.Str; }

    multi method nude() { $.numerator, $.denominator; }

    multi method succ {
        Rat.new($!numerator + $!denominator, $!denominator);
    }
    multi method pred {
        Rat.new($!numerator - $!denominator, $!denominator);
    }
}

multi sub infix:<+>(Rat $a, Rat $b) {
    my $gcd = Rat::gcd($a.denominator, $b.denominator);
    ($a.numerator * ($b.denominator div $gcd) + $b.numerator * ($a.denominator div $gcd))
        / (($a.denominator div $gcd) * $b.denominator);
}

multi sub infix:<+>(Rat $a, Int $b) {
    ($a.numerator + $b * $a.denominator) / $a.denominator;
}

multi sub infix:<+>(Int $a, Rat $b) {
    ($a * $b.denominator + $b.numerator) / $b.denominator;
}

multi sub infix:<->(Rat $a, Rat $b) {
    my $gcd = Rat::gcd($a.denominator, $b.denominator);
    ($a.numerator * ($b.denominator div $gcd) - $b.numerator * ($a.denominator div $gcd))
        / (($a.denominator div $gcd) * $b.denominator);
}

multi sub infix:<->(Rat $a, Int $b) {
    ($a.numerator - $b * $a.denominator) / $a.denominator;
}

multi sub infix:<->(Int $a, Rat $b) {
    ($a * $b.denominator - $b.numerator) / $b.denominator;
}

multi sub prefix:<->(Rat $a) {
    Rat.new(-$a.numerator, $a.denominator);
}

multi sub infix:<*>(Rat $a, Rat $b) {
    ($a.numerator * $b.numerator) / ($a.denominator * $b.denominator);
}

multi sub infix:<*>(Rat $a, Int $b) {
    ($a.numerator * $b) / $a.denominator;
}

multi sub infix:<*>(Int $a, Rat $b) {
    ($a * $b.numerator) / $b.denominator;
}

multi sub infix:</>(Rat $a, Rat $b) {
    ($a.numerator * $b.denominator) / ($a.denominator * $b.numerator);
}

multi sub infix:</>(Rat $a, Int $b) {
    $a.numerator / ($a.denominator * $b);
}

multi sub infix:</>(Int $a, Rat $b) {
    ($b.denominator * $a) / $b.numerator;
}

multi sub infix:</>(Int $a, Int $b) {
    Rat.new($a, $b);
}

augment class Int {
    # CHEAT: Comes from Int.pm, moved here for the moment.
    our Rat multi method Rat() { Rat.new(self, 1); }
}

# vim: ft=perl6 sw=4 ts=4 expandtab
