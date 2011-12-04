#
# Musescore.com
#
# This module wraps over the Musescore.com API.
#
# Author: Richard Lewis
# Email: richard@rjlewis.me.uk

use LWP::UserAgent;
use URI;
use XML::XPath;
use XML::XPath::XMLParser;
use strict;

package API;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(get_scores get_score post_score delete_score);

sub extract_http_args {
    my ($arg_names, $supplied_args) = @_;
    my $http_args = {};

    foreach my $arg_name (@{ $arg_names }) {
	$http_args->{$arg_name} = $supplied_args->{$arg_name} if (exists $supplied_args->{$arg_name});
    }

    return $http_args;
}

sub get_scores {
    my $args = shift;
    my $http_args = extract_http_args([qw(text part parts language)], $args);
    $http_args->{oauth_consumer_key} = "musichackday";

    my $ua = LWP::UserAgent->new;
    $ua->agent("MusicHackDay/0.1");

    my $score_resource = URI->new("http://api.musescore.com/services/rest/score");

    my $scores = [];

    my $page = 0;
    my $results = 1;

    while ($results) {
	$http_args->{page} = $page;
	$score_resource->query_form($http_args);

	my $req = HTTP::Request->new(GET => $score_resource);
	$req->header("Accept", "application/xml");

	my $response = $ua->request($req);

	if ($response->is_success) {
	    my $xp = XML::XPath->new(xml => $response->content);
	    my $nodeset = $xp->find("//score");
	    $results = $nodeset->size();

	    foreach my $score ($nodeset->get_nodelist) {
		push @$scores, {id       => $xp->find('id', $score),
				secret   => $xp->find('secret', $score),
				uri      => $xp->find('uri', $score),
				title    => $xp->find('title', $score),
				composer => $xp->find('metadata/composer', $score)};

		return $scores if (exists $args->{count} and scalar @$scores >= $args->{count});
	    }
	} else {
	    die sprintf("Failed fetching %s: %s\n", $score_resource, $response->status_line);
	}

	$page++;
    }

    return $scores;
}

sub get_score { }

sub post_score { }

sub delete_score { }
