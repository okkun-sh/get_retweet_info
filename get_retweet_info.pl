#!/usr/bin/perl
use strict;
use warnings;
use feature qw( say state );

use Net::Twitter;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Data::Validator;
use Encode qw ( encode_utf8 );

my $tweet_id;
my $print_key;
my $help;
GetOptions('i=i' => \$tweet_id, 'p=s' => \$print_key, h => \$help);
if ($help) {
    die show_help();
}
validate( tweet_id => $tweet_id, print_key => $print_key );

my $account = {
    consumer_key        => '%CONSUMER_KEY%',
    consumer_secret     => '%CONSUMER_SECRET%',
    access_token        => '%ACCESS_TOKEN%',
    access_token_secret => '%ACCESS_TOKEN_SECRET%',
};

my $nt = Net::Twitter->new({
    traits   => [qw/API::RESTv1_1/],
    consumer_key        => $account->{consumer_key},
    consumer_secret     => $account->{consumer_secret},
    access_token        => $account->{access_token},
    access_token_secret => $account->{access_token_secret},
});

my $retweet_user_ids = $nt->retweeters_ids({
    id            => $tweet_id,
    stringify_ids => 'true',
});

my $user;
my $retweet_user_list = [];
map { 
    $user = $nt->show_user({ user_id => $_}); 
    push @$retweet_user_list, $user
} @{ $retweet_user_ids->{ids} };

map { say encode_utf8 $_->{$print_key} } @$retweet_user_list;

sub validate {
    eval {
        state $rule = Data::Validator->new(
            tweet_id  => { isa => 'Int' },
            print_key => { isa => 'Str' },
        );
        my $args = $rule->validate(@_);
    };
    if ($@) {
        die show_help();
        exit;
    }
}

sub show_help {
    my $help_doc = <<EOF;

    get retweet info script

    Usage:
        perl $0 [options]

    Options:
        -i : tweet_id (Int)

        -p : print_key (Str)
            ex )
                id, screen_name, location
                https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-show            

        -h : help


    Author
        okkun_sh <okkun.sh\@gmail.com> (\@okkun_sh on Twitter)
EOF
    return $help_doc;
}