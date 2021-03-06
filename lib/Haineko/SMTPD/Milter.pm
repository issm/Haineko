package Haineko::SMTPD::Milter;
use strict;
use warnings;
use Module::Load;

sub import {
    my $class = shift;
    my $argvs = shift || return 0;  # (Ref->Array) Module names
    my $llist = [];

    return 0 unless ref $argvs eq 'ARRAY';
    for my $e ( @$argvs ){
        # Load each module
        $e =~ s/\A/Haineko::SMTPD::Milter::/ unless $e =~ /\A[+]/;
        $e =~ s/\A[+]//;
        eval { Module::Load::load( $e ); };
        next if $@;
        push @$llist, $e;
    }

    return $llist;
}

sub libs {
    my $class = shift;
    my $argvs = shift || return 0;  # (Ref->Array) Path names
    my $count = 0;

    return 0 unless ref $argvs eq 'ARRAY';
    for my $e ( @$argvs ){
        next if grep { $e eq $_ } @$INC;
        unshift @INC, $e;
        $count++;
    }
    return scalar $count;
}

sub conn {
    # Implement at sub class
    return 1;
}

sub ehlo {
    # Implement at sub class
    return 1;
}

sub mail {
    # Implement at sub class
    return 1
}

sub rcpt {
    # Implement at sub class
    return 1;
}

sub head {
    # Implement at sub class
    return 1;
}

sub body {
    # Implement at sub class
    return 1;
}

1;
__END__

=encoding utf8

=head1 NAME

Haineko::SMTPD::Milter - Haineko milter base class

=head1 DESCRIPTION

Check or rewrite contents like a milter program at each phase of SMTP session.
Each method is called from /submit for example: MAIL -> mail(), RCPT -> rcpt().

=head1 SYNOPSIS

    use Haineko::SMTPD::Milter;
    Haineko::SMTPD::Milter->libs( [ '/path/to/lib1', '/path/to/lib2' ] );
    my $x = Haineko::SMTPD::Milter->import( [ 'Neko' ] );   # Load Haineko::SMTPD::Milter::Neko
    warn Dumper $x;                                         # [ Haineko::SMTPD::Milter::Neko ]

    my $y = Haineko::SMTPD::Milter->import( [ '+My::Encrypt' ]);    # Load My::Encrypt module
    warn Dumper $y;                                                 # [ 'My::Encrypt' ]

=head1 CLASS METHODS

=head2 B<libs( I<[ ... ]> )>

Add paths in the argument into @INC for finding modules of milter. It may be useful
when modules used as a milter are not installed in directories of @INC.

=head2 B<import( I<[ ... ]> )>

Load modules in the argument as a module for milter. If a module name begin with
``B<+>'' such as ``+My::Encrypt'', B<My::Encrypt> module will be loaded. A Module
which doesn't begin with ``+'' such as ``Neko'', ``Haineko::SMTPD::Milter::Neko''
will be loaded.

=head1 IMPLEMENT MILTER METHODS (Overridden by Haineko::SMTPD::Milter::*)

Each method is called from /submit at each phase of SMTP session. If you want to
reject the smtp connection, set required values into Haineko::SMTPD::Response 
object and return 0 or undef as a return value of each method. However you want
to only rewrite contents or passed your contents filter, return 1 or true as a 
return value.


=head2 B<conn( I<Haineko::SMTPD::Response>, I<REMOTE_HOST>, I<REMOTE_ADDR> )>

conn() method is for checking a client hostname and client IP address.

=head3 Arguments

=head4 B<Haineko::SMTPD::::Response> object

If your milter program rejects a message, set 1 by ->error(1), set error message
by ->message( [ 'Error message' ]), and override SMTP status code by ->code(), 
Default SMTP status codes is 421 in this method.

=head4 B<REMOTE_HOST>

The host name of the message sender, as picked from HTTP REMOTE_HOST variable.

=head4 B<REMOTE_ADDR>

The host address, as picked from HTTP REMOTE_ADDR variable.


=head2 B<ehlo( I<Haineko::SMTPD::Response>, I<HELO_HOST> )>

ehlo() method is for checking a hostname passed as an argument of EHLO.

=head3 Arguments

=head4 B<HainekoSMTPD::::Response> object

If your milter program rejects a message, set 1 by ->error(1), set error message
by ->message( [ 'Error message' ]), and override SMTP status code by ->code(), 
override D.S.N value by ->dsn(). Default SMTP status codes is 521 in this method.

=head4 B<HELO_HOST>

Value defined in "ehlo" field in HTTP-POSTed JSON data, which should be the 
domain name of the sending host or IP address enclosed square brackets.


=head2 B<mail( I<Haineko::SMTPD::Response>, I<ENVELOPE_SENDER> )>

mail() method is for checking an envelope sender address.

=head3 Arguments

=head4 B<Haineko::SMTPD::Response> object

If your milter program rejects a message, set 1 by ->error(1), set error message
by ->message( [ 'Error message' ]), and override SMTP status code by ->code(), 
override D.S.N value by ->dsn(). Default SMTP status codes is 501, dsn is 5.1.8
in this method.

=head4 B<ENVELOPE_SENDER>

Value defined in "mail" field in HTTP-POSTed JSON data, which should be the 
valid email address.


=head2 B<rcpt( I<Haineko::SMTPD::Response>, I< [ ENVELOPE_RECIPIENTS ] > )>

rcpt() method is for checking envelope recipient addresses. Envelope recipient
addresses are passwd as an array reference.

=head3 Arguments

=head4 B<Haineko::SMTPD::Response> object

If your milter program rejects a message, set 1 by ->error(1), set error message
by ->message( [ 'Error message' ]), and override SMTP status code by ->code(), 
override D.S.N value by ->dsn(). Default SMTP status codes is 553, dsn is 5.7.1
in this method.

=head4 B<ENVELOPE_RECIPIENTS>

Values defined in "rcpt" field in HTTP-POSTed JSON data, which should be the 
valid email address.


=head2 B<head( I<Haineko::SMTPD::Response>, I< { EMAIL_HEADER } > )>

head() method is for checking email header. Email header is passwd as an hash
reference.

=head3 Arguments

=head4 B<Haineko::SMTPD::Response> object

If your milter program rejects a message, set 1 by ->error(1), set error message
by ->message( [ 'Error message' ]), and override SMTP status code by ->code(), 
override D.S.N value by ->dsn(). Default SMTP status codes is 554, dsn is 5.7.1
in this method.

=head4 B<EMAIL_HEADER>

Values defined in "header" field in HTTP-POSTed JSON data.


=head2 B<body( I<Haineko::SMTPD::Response>, I< \EMAIL_BODY > )>

body() method is for checking email body. Email body is passwd as an scalar
reference.

=head3 Arguments

=head4 B<Haineko::SMTPD::Response> object

If your milter program rejects a message, set 1 by ->error(1), set error message
by ->message( [ 'Error message' ]), and override SMTP status code by ->code(), 
override D.S.N value by ->dsn(). Default SMTP status codes is 554, dsn is 5.6.0
in this method.

=head4 B<EMAIL_BODY>

Value defined in "body" field in HTTP-POSTed JSON data.


=head1 SEE ALSO

https://www.milter.org/developers/api/

=head1 REPOSITORY

https://github.com/azumakuniyuki/Haineko

=head1 AUTHOR

azumakuniyuki E<lt>perl.org [at] azumakuniyuki.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

=cut
