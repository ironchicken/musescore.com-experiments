#
# MusicXML
#
# This module provides access to <score-partwise> elements.
#
# Author: Richard Lewis
# Email: richard@rjlewis.me.uk

use strict;

package ScorePartWise;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse part set_part);

sub new {
    my $self = {};
    $self->{parts} = [];
    bless($self);
    return $self;
}

sub parse {

}

sub part {
    my ($self, $part_number) = @_;
    return $self->{parts}[$part_number];
}

sub set_part {
    my ($self, $part_number, $part) = @_;
    $self->{parts}[$part_number] = $part;
}

package Part;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse key set_key time set_time clef set_clef);

sub new {
    my $self = {id        => undef,
		part_name => undef,

		# FIXME These are really <measure> properties, but
		# let's just get them from the first <measure> and
		# maybe die if such properties are found elsehwhere
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

}

sub key      { $_[0]->{key}; }
sub set_key  { my ($self, $fifths, $mode) = @_;     $self->{key}  = {fifths => $fifths, mode     => $mode}; }
sub time     { $_[0]->{time}; }
sub set_time { my ($self, $beats, $beat_type) = @_; $self->{time} = {beats  => $beats, beat_type => $beat_type}; }
sub clef     { $_[0]->{clef}; }
sub set_clef { my ($self, $sign, $line) = @_;       $self->{clef} = {sign    => $sign, line      => $line}; }

package Measure;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new parse number set_number);

sub new {
    my $self = {number => undef,
		notes  => []};
    bless($self);
    return $self;
}

sub parse {

}

sub number { $_[0]->{number}; }

sub set_number {
    my ($self, $number) = @_;
    $self->{number} = $number;
}
   
1;
