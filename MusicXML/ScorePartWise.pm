#
# MusicXML
#
# This module provides access to <score-partwise> elements.
#
# Author: Richard Lewis
# Email: richard@rjlewis.me.uk

use XML::XPath;
use strict;

package ScorePartWise;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse part set_part parts xpath measures notes);

sub new {
    my $self = {parts    => [],
		musicxml => undef};
    bless($self);
    return $self;
}

sub parse {
    my ($self, $musicxml) = @_;
    $self->{musicxml} = XML::XPath->new(xml => $musicxml);

    foreach my $part ($self->{musicxml}->find(q(//score-part))->get_nodelist) {
	my $id = $self->{musicxml}->findvalue(q(@id), $part);
	my $new_part = Part->new($self);
	$new_part->parse($self->{musicxml}->find(qq(//part[\@id="$id"]))->get_node(1));
	push @{ $self->{parts} }, $new_part;
    }
}

sub part {
    my ($self, $part_id) = @_;
    for my $part (@{ $self->{parts} }) {
	if ($part->id eq $part_id) { return $part; }
    }
}

sub set_part {
    my ($self, $part_number, $part) = @_;
    splice(@{ $self->{parts} }, $part_number, $part);
}

sub parts { $_[0]->{parts}; }

sub xpath {
    my ($self, $xpath) = @_;
    return $self->{musicxml}->find($xpath)->get_nodelist;
}

sub measures {
    my $self = shift;
    my @measures = ();
    for my $measure_frag ($self->xpath(q(//measure))) {
	push @measures, Measure->new(undef)->parse($measure_frag);
    }
    return @measures;
}

sub notes {
    my $self = shift;
    my @notes = ();
    for my $note_frag ($self->xpath(q(//note))) {
	push @notes, Note->new(undef)->parse($note_frag);
    }
    return @notes;
}

package Part;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse key set_key time set_time clef set_clef);

sub new {
    my $self = {score     => shift,
		id        => undef,
		part_name => undef,

		# FIXME These are really <measure> properties, but
		# let's just get them from the first <measure> and
		# maybe die if such properties are found elsewhere
		divisions => undef,
		key       => {fifths => undef, mode => undef},
		time      => {beats => undef, beat_type => undef},
		clef      => {sign => undef, line => undef},
		measures  => []
    };
    bless($self);
    return $self;
}

sub parse {
    my ($part_frag) = @_;
}

sub score { $_[0]->{score}; }

sub id { $_[0]->{id}; }
sub set_id {
    my ($self, $id) = @_;
    $self->{id} = $id;
}


sub key { $_[0]->{key}; }
sub set_key {
    my ($self, $fifths, $mode) = @_;
    $self->{key} = {fifths => $fifths, mode => $mode};
}

sub time { $_[0]->{time}; }
sub set_time {
    my ($self, $beats, $beat_type) = @_;
    $self->{time} = {beats => $beats, beat_type => $beat_type};
}

sub clef { $_[0]->{clef}; }
sub set_clef {
    my ($self, $sign, $line) = @_;
    $self->{clef} = {sign => $sign, line => $line};
}

package Measure;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse number set_number);

sub new {
    my $self = {part   => shift,
		number => undef,
		notes  => []};
    bless($self);
    return $self;
}

sub parse {
    my ($measure_frag) = @_;
}

sub part { $_[0]->{part}; }

sub number { $_[0]->{number}; }
sub set_number {
    my ($self, $number) = @_;
    $self->{number} = $number;
}

package Note;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse pitch set_pitch duration set_duration type set_type lyric set_lyric);

sub new {
    my $self = {measure  => shift,
		pitch    => {step => undef, octave => undef},
		duration => undef,
		type     => undef,
		lyric    => {syllabic => undef, text => undef}
    };
    bless($self);
    return $self;
}

sub parse {
    my ($note_frag) = @_;
}

sub measure { $_[0]->{measure}; }

sub pitch { $_[0]->{pitch}; }
sub set_pitch {
    my ($self, $step, $octave) = @_;
    $self->{pitch} = {step => $step, octave => $octave};
}

sub duration { $_[0]->{duration}; }
sub set_duration {
    my ($self, $duration) = @_;
    $self->{duration} = $duration;
}

sub type { $_[0]->{type}; }
sub set_type {
    my ($self, $type) = @_;
    $self->{type} = $type;
}

sub lyric { $_[0]->{lyric}; }
sub set_lyric {
    my ($self, $syllabic, $text) = @_;
    $self->{lyric} = {syllabic => $syllabic, text => $text};
}

1;
