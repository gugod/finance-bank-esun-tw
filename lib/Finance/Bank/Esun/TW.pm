package Finance::Bank::Esun::TW;

use 5.008;
use warnings;
use strict;
use WWW::Mechanize;
use utf8;
use List::MoreUtils qw(mesh);
# use IO::All;
use Text::Trim;
use HTML::TableExtract;

our $VERSION = '0.01';

{
    my $ua;
    sub _ua {
        return $ua if $ua;
        $ua = WWW::Mechanize->new(
            env_proxy => 1,
            keep_alive => 1,
            timeout => 60,
        );
        $ua->agent_alias("Windows IE 6");
        return $ua;
    }
}

sub currency_exchange_rate {
    _ua->get('http://www.esunbank.com.tw/info/rate_spot_exchange.aspx');
    my $content = _ua->content;

    # For Debuging:
    # io("/tmp/esun-currency.html")->utf8->print($content);
    # my $content = io("/tmp/esun-currency.html")->utf8->all;

    my $te = HTML::TableExtract->new(attribs => { class => "default-color1" });
    $te->parse($content);

    my @ret;
    binmode(STDOUT, ":utf8");
    my @columns = qw(en_currency_name zh_currency_name buy_at sell_at);

    foreach my $row ($te->rows) {
        next if $row->[0] eq "幣 別";

        my @cell = map { trim } @$row;

        push @ret,
            { mesh @columns, @{[ _t($cell[0]), @cell[0..2] ]} },
            { mesh @columns, @{[ _t($cell[3]), @cell[3..5] ]} };
    }

    return \@ret;
}

my %dict = (
    '美元現金'   => "USD CASH",
    '美元一般'   => "USD",
    '港幣現金'   => "HKD CASH",
    '港幣'       => "HKD",
    '日圓現金'   => "JPY CASH",
    '日圓'       => "JPY",
    '歐元現金'   => "EUR CASH",
    '歐元'       => "EUR",
    '英鎊'       => "GBP",
    '澳幣'       => "AUD",
    '加拿大幣'   => "CAD",
    '瑞士法郎'   => "SWF",
    '新加坡幣'   => "SGD",
    '泰國銖'     => "THB",
    '紐西蘭幣'   => "NZD",
    '瑞典幣'     => "SEK",
    '南非幣'     => "ZAR",
    '人民幣現金' => "MCY CASH"
);

sub _t {
    my $zh = shift;
    return $dict{$zh} || $zh;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Finance::Bank::Esun::TW - Check Taiwan Esun bank info

=head1 VERSION

This document describes Finance::Bank::Esun::TW version 0.01

=head1 SYNOPSIS

    use Finance::Bank::Esun::TW;
    use YAML;

    print YAML::Dump(Finance::Bank::Esun::TW->currency_exchange_rate);

=head1 DESCRIPTION

This module provides a rudimentary interface to the online Esun Bank
system at L<http://www.esunbank.com.tw>

=head1 INTERFACE 

=over

=item currency_exchange_rate

Return the extracted table (as an array of hash) of currency exchange
rate from L<http://www.esunbank.com.tw/info/rate_spot_exchange.aspx>

It returns an arrayref with each item inside is a hashref looks like:

    {
        zh_currency_name => "美金現金",
        en_currency_name => "USD CASH",
        buy_at           => 33.06,
        sell_at          => 33.56
    }

=back

=head1 WARNING

This is code for B<online banking>, and that means B<your money>, and
that means B<BE CAREFUL>. You are encouraged, nay, expected, to audit
the source of this module yourself to reassure yourself that I am not
doing anything untoward with your banking data. This software is useful
to me, but is provided under B<NO GUARANTEE>, explicit or implied.

=head1 CONFIGURATION AND ENVIRONMENT

Finance::Bank::Esun::TW requires no configuration files or environment variables.

=head1 DEPENDENCIES

L<WWW::Mechanize>, L<Crypt::SSLeay>, L<IO::Socket::SSL>,
L<Text::Trim>, L<HTML::TableExtract>, L<List::MoreUtils>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-finance-bank-esun-tw@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Kang-min Liu C<< <gugod@gugod.org> >>.

This is free software, licensed under:

    The MIT (X11) License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
