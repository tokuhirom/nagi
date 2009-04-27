package Nagi;
use strict;
use warnings;
use HTTPx::Dispatcher;
use CGI;
use Text::MicroTemplate;
our $VERSION = '0.01';

my @rules; # array of rules
my %codes; # pattern => coderef
my $req;

sub import {
    strict->import;
    warnings->import;
    utf8->import;
    binmode *STDOUT, ':utf8';
    binmode *STDERR, ':utf8';

    $req = CGI->new;

    $^H |= 0x120000;
    {
        no strict 'refs';
        *{"main::get"} = sub {
            my ($pattern, $code) = @_;
            push @rules, HTTPx::Dispatcher::Rule->new($pattern);
            $codes{$pattern} = $code;
        };
        *{"main::req"} = sub { $req };
        $^H{franck_scope} = Nagi::Finalizer->new;
    }
}

package # hide from cpan
    Nagi::Finalizer;

sub new { bless [], shift }

sub DESTROY {
    for my $rule (@rules) {
        if ($rule->match($req)) {
            my $code = $codes{$rule->pattern};
            my $res = $code->();
            print "Content-Type: text/html\r\n\r\n";
            print $res;
            return;
        }
    }
    print "Status: 404\r\nContent-Type: text/html\r\n\r\n404 not found\n";
    return;
}

1;
__END__

=head1 NAME

Nagi -

=head1 SYNOPSIS

    use Nagi;

=head1 DESCRIPTION

Nagi is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
