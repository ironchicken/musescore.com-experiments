#
# Musescore.com
#
# This module provides a facility for downloading and storing scores
# from Musescore.com
#
# Author: Richard Lewis
# Email: richard@rjlewis.me.uk

use DBI;
use LWP::UserAgent;
use URI;
use IO::Uncompress::Unzip qw(unzip);
use XML::XPath;
use strict;

package Caching;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(cache_all cache_score);

my %db_attrs = (RaiseError  => 1,
		PrintError  => 0);

my %db_opts = (database => "DBI:mysql:musescore",
	       user     => "root",
	       password => "tbatst",
	       attrs    => \%db_attrs);

sub make_dbh {
    DBI->connect($db_opts{database},
		 $db_opts{user},
		 $db_opts{password})
	or die ("Could not connect to database.\n");
}

sub cache_all {
    my $scores = shift;

    my $dbh = make_dbh();

    my $insert_score = $dbh->prepare(qq(INSERT INTO scores (id, musicxml) VALUES (?,?)));

    foreach my $score (@{ $scores }) {
	cache_score($insert_score, $score->{id}, $score->{secret});
    }
}

sub cache_score {
    my ($insert_stmt, $id, $secret) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent("MusicHackDay/0.1");

    my $score_resource = URI->new(sprintf("http://static.musescore.com/%s/%s/score.mxl", $id, $secret));

    my $req = HTTP::Request->new(GET => $score_resource);

    my $response = $ua->request($req);

    if ($response->is_success) {
	my $mxl = $response->content;
	my $container; my $musicxml;
	IO::Uncompress::Unzip::unzip (\$mxl, \$container, Name => "META-INF/container.xml");
	my $xp = XML::XPath->new(xml => $container);
	my $musicxml_file = $xp->findvalue(q(//rootfile[1]/@full-path));
	IO::Uncompress::Unzip::unzip (\$mxl, \$musicxml, Name => $musicxml_file);
	$insert_stmt->execute($id, $musicxml);
    }
    printf("cache_score: Cached: %s\n", $id);
}

