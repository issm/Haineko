use lib qw|./lib ./blib/lib|;
use strict;
use warnings;
use Haineko;
use Test::More;
use Plack::Test;
use HTTP::Request;

my $nekochan = Haineko->start;
my $pathlist = {
    '/' => 'Haineko',
    '/neko' => 'Nyaaaaa',
};
my $nekotest = sub {
    my $callback = shift;
    my $request1 = undef;
    my $response = undef;

    for my $e ( keys %$pathlist ) {
        $request1 = HTTP::Request->new( 'GET' => 'http://127.0.0.1:2794'.$e );
        $response = $callback->( $request1 );

        is $response->code, 200, $e;
        is $response->content, $pathlist->{ $e }, $e;
    }
};

test_psgi $nekochan, $nekotest;
done_testing();
