use lib qw|./lib ./blib/lib|;
use strict;
use warnings;
use Haineko::SMTPD::Relay::ESMTP;
use Test::More;

my $modulename = 'Haineko::SMTPD::Relay::ESMTP';
my $pkgmethods = [ 'new' ];
my $objmethods = [ 'sendmail' ];
my $methodargv = {
    'mail' => 'kijitora@example.jp',
    'rcpt' => 'mikeneko@example.org',
    'head' => { 
        'From', 'Kijitora <kijitora@example.jp>',
        'To', 'Mikechan <mikenkeko@example.org>',
        'Subject', 'Nyaa--',
    },
    'body' => \'Nyaaaaaaaaaaaaa',
    'host' => '192.0.2.1',
    'port' => 25,
    'attr' => {},
    'retry' => 0,
    'sleep' => 1,
    'timeout' => 2,
};
my $testobject = $modulename->new();

isa_ok $testobject, $modulename;
can_ok $modulename, @$pkgmethods;
can_ok $testobject, @$objmethods;

INSTANCE_METHODS: {

    for my $e ( qw/mail rcpt head body host port attr mxrr auth username password/ ) {
        is $testobject->$e, undef, '->'.$e.' => undef';
    }

    my $o = $modulename->new( %$methodargv );
    my $r = undef;
    my $m = undef;

    isa_ok $o->time, 'Time::Piece';
    ok $o->time, '->time => '.$o->time->epoch;

    is $o->mail, $methodargv->{'mail'}, '->mail => '.$o->mail;
    is $o->rcpt, $methodargv->{'rcpt'}, '->rcpt => '.$o->rcpt;
    is $o->host, $methodargv->{'host'}, '->host => '.$o->host;
    is $o->port, $methodargv->{'port'}, '->port => '.$o->port;
    is $o->body, $methodargv->{'body'}, '->body => '.$o->body;

    is ref $o->attr, 'HASH';
    is $o->mxrr, undef, '->mxrr => undef';
    is $o->auth, undef, '->auth => undef';
    is $o->timeout, 2, '->timeout => 2';
    is $o->username, undef, '->username => undef';
    is $o->password, undef, '->password => undef';
    is $o->retry, 0, '->retry => 1';
    is $o->sleep, 1, '->sleep => 1';
    is $o->starttls, undef, '->starttls => undef';
    is $o->sendmail, 0, '->sendmail => 0';

    $r = $o->response;
    $m = shift @{ $o->response->message };

    is $r->dsn, undef, '->response->dsn => undef';
    is $r->code, 421, '->response->code => 421';
    is $r->error, 1, '->response->error=> 1';
    is $r->command, 'CONN', '->response->command => CONN';
    like $m, qr/Cannot connect SMTP Server/, '->response->message => '.$m;
}

done_testing;
__END__
