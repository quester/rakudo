use MONKEY_TYPING;
augment class Pair {
    multi method perl() {
        $.key.perl ~ ' => ' ~ $.value.perl;
    }
}
