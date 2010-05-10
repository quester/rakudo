class Complex does Numeric is Cool {
    has $.re;
    has $.im;

    multi method new($re, $im) {
        self.bless(*, :re($re), :im($im));
    }

    multi method ACCEPTS(Complex $topic) {
        ($topic.re ~~ $.re) && ($topic.im ~~ $.im);
    }
    multi method ACCEPTS($topic) {
        ($topic.Num ~~ $.re) && ($.im == 0);
    }

    multi method Complex() { self }

    our Bool multi method Bool() { ( $!re != 0 || $!im != 0 ) ?? Bool::True !! Bool::False }

    multi method perl() {
        "Complex.new($.re, $.im)";
    }

    multi method Str() {
        "$.re + {$.im}i";
    }

    method abs(Complex $x:) {
        ($x.re * $x.re + $x.im * $x.im).sqrt
    }

    multi method exp() {
        Complex.new($.re.Num.exp * $.im.Num.cos, $.re.Num.exp * $.im.Num.sin);
    }

    multi method exp(Complex $exponent: Numeric $base) {
        $base ** $exponent;
    }

    method ln() {
        Q:PIR {
            .local pmc self
            self = find_lex 'self'
            $P0 = get_root_namespace ['parrot'; 'Complex' ]
            $P0 = get_class $P0
            $P0 = $P0.'new'()
            $N0 = self.'re'()
            $P0[0] = $N0
            $N1 = self.'im'()
            $P0[1] = $N1
            $P0 = $P0.'ln'()
            $N0 = $P0[0]
            $P2 = box $N0
            $N1 = $P0[1]
            $P3 = box $N1
            $P1 = get_hll_global 'Complex'
            $P1 = $P1.'new'($P2, $P3)
            %r  = $P1
        }
    }

    method sin(Complex $x: $base = Radians) {
        $x.re.sin($base) * $x.im.cosh($base) + ($x.re.cos($base) * $x.im.sinh($base))i;
    }

    multi method asin($base = Radians) {
        (-1i * log((self)i + sqrt(1 - self * self))).from-radians($base);
    }

    multi method cos($base = Radians) {
        $.re.cos($base) * $.im.cosh($base) - ($.re.sin($base) * $.im.sinh($base))i;
    }

    multi method acos($base = Radians) {
      (pi / 2).from-radians($base) - self.asin($base);
    }

    multi method tan($base = Radians) {
        self.sin($base) / self.cos($base);
    }

    multi method atan($base = Radians) {
       ((log(1 - (self)i) - log(1 + (self)i))i / 2).from-radians($base);
    }

    multi method sec($base = Radians) {
        1 / self.cos($base);
    }

    multi method asec($base = Radians) {
        (1 / self).acos($base);
    }

    multi method cosec($base = Radians) {
        1 / self.sin($base);
    }

    multi method acosec($base = Radians) {
        (1 / self).asin($base);
    }

    multi method cotan($base = Radians) {
        self.cos($base) / self.sin($base);
    }

    multi method acotan($base = Radians) {
        (1 / self).atan($base);
    }

    multi method sinh($base = Radians) {
        -((1i * self).sin($base))i;
    }

    multi method asinh($base = Radians) {
       (self + sqrt(1 + self * self)).log.from-radians($base);
    }

    multi method cosh($base = Radians) {
        (1i * self).cos($base);
    }

    multi method acosh($base = Radians) {
       (self + sqrt(self * self - 1)).log.from-radians($base);
    }

    multi method tanh($base = Radians) {
        -((1i * self).tan($base))i;
    }

    multi method atanh($base = Radians) {
       (((1 + self) / (1 - self)).log / 2).from-radians($base);
    }

    multi method sech($base = Radians) {
        1 / self.cosh($base);
    }

    multi method asech($base = Radians) {
        (1 / self).acosh($base);
    }

    multi method cosech($base = Radians) {
        1 / self.sinh($base);
    }

    multi method acosech($base = Radians) {
        (1 / self).asinh($base);
    }

    multi method cotanh($base = Radians) {
        1 / self.tanh($base);
    }

    multi method acotanh($base = Radians) {
        (1 / self).atanh($base);
    }

    multi method polar() {
        $.abs, atan2($.im, $.re);
    }

    multi method roots($n is copy) {
       # my ($mag, $angle) = @.polar;
       my $mag = $.abs;
       my $angle = atan2($.im, $.re);
       if $n < 1
       {
           return NaN;
       }

       if $n == 1
       {
           return self;
       }

       # return NaN  if $!re|$!im ~~  Inf|NaN|-Inf;
       $n = $n.Int;
       $mag **= 1/$n;
       # (^$n).map: { $mag.unpolar( ($angle + $_ * 2 * pi) / $n) };
       (0 ... ($n-1)).map: { $mag.unpolar( ($angle + $^x * 2 * 312689/99532) / $n) };
    }

    multi method sign() {
        fail('Cannot take the sign() of a Complex number');
    }

    method sqrt() {
        Q:PIR {
            .local pmc self
            self = find_lex 'self'
            $P0 = get_root_namespace ['parrot'; 'Complex' ]
            $P0 = get_class $P0
            $P0 = $P0.'new'()
            $N0 = self.'re'()
            $P0[0] = $N0
            $N1 = self.'im'()
            $P0[1] = $N1
            $P0 = $P0.'sqrt'()
            $N0 = $P0[0]
            $P2 = box $N0
            $N1 = $P0[1]
            $P3 = box $N1
            $P1 = get_hll_global 'Complex'
            $P1 = $P1.'new'($P2, $P3)
            %r  = $P1
        }
    }

    multi method cosec($base = Radians) {
        1.0 / self.to-radians($base).sin;
    }

    multi method cosech($base = Radians) {
        1.0 / self.to-radians($base).sinh;
    }

    multi method acosec($base = Radians) {
        (1.0 / self).asin.to-radians($base);
    }

    multi method cotan($base = Radians) {
        1.0 / self.to-radians($base).tan;
    }

    multi method cotanh($base = Radians) {
        1.0 / self.to-radians($base).tanh;
    }

    multi method acotan($base = Radians) {
        (1.0 / self).atan.to-radians($base);
    }

    multi method acosech($base = Radians) {
        (1.0 / self).asinh.to-radians($base);
    }

    multi method acotanh($base = Radians) {
        (1.0 / self).atanh.to-radians($base);
    }

    multi method Num {
        if $!im == 0 {
            $!re;
        } else {
            fail "You can only coerce a Complex to Num if the imaginary part is zero"
        }
    }
}

multi sub infix:<+>(Complex $a, Complex $b) {
    Complex.new($a.re + $b.re, $a.im + $b.im);
}

multi sub infix:<+>(Complex $a, Real $b) {
   Complex.new($a.re + $b, $a.im);
}

multi sub infix:<+>(Real $a, Complex $b) {
    # Was $b + $a; but that trips a ng bug, and also means
    # that Num + Complex is slower than Complex + Num, which
    # seems daft.
    Complex.new($a + $b.re, $b.im);
}

# Originally infix:<-> was implemented in terms of addition, but
# that adds an extra function call to each.  This repeats ourselves,
# but should avoid odd performance anomalies.

multi sub infix:<->(Complex $a, Complex $b) {
    Complex.new($a.re - $b.re, $a.im - $b.im);
}

multi sub infix:<->(Complex $a, Real $b) {
   Complex.new($a.re - $b, $a.im);
}

multi sub infix:<->(Real $a, Complex $b) {
    Complex.new($a - $b.re, -$b.im);
}

multi sub infix:<*>(Complex $a, Complex $b) {
    Complex.new($a.re * $b.re - $a.im * $b.im, $a.im * $b.re + $a.re * $b.im);
}

multi sub infix:<*>(Complex $a, Real $b) {
   Complex.new($a.re * $b, $a.im * $b);
}

multi sub infix:<*>(Real $a, Complex $b) {
    Complex.new($a * $b.re, $a * $b.im);
}

multi sub infix:</>(Complex $a, Complex $b) {
    my $d = $b.re * $b.re + $b.im * $b.im;
    Complex.new(($a.re * $b.re + $a.im * $b.im) / $d,
                ($a.im * $b.re - $a.re * $b.im) / $d);
}

multi sub infix:</>(Complex $a, Real $b) {
    Complex.new($a.re / $b, $a.im / $b);
}

multi sub infix:</>(Real $a, Complex $b) {
    Complex.new($a, 0) / $b;
}

multi sub postfix:<i>($x) {
    Complex.new(0, +$x);
}

multi sub postfix:<i>(Complex $z) {
    Complex.new(-$z.im, $z.re);
}

multi sub prefix:<->(Complex $a) {
    Complex.new(-$a.re, -$a.im);
}

multi sub infix:<**>(Complex $a, Complex $b) {
   ($a.log * $b).exp;
}

multi sub infix:<**>(Complex $a, Real $b) {
   ($a.log * $b).exp;
}

multi sub infix:<**>(Real $a, Complex $b) {
    ($a.log * $b).exp;
}

multi sub log(Complex $x) {
    $x.log()
}

multi sub sign(Complex $x) { $x.sign }

# vim: ft=perl6
