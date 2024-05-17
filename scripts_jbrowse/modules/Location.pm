package Location;
#!/usr/bin/perl
use Moose;

has 'chrom' => (
	is  => 'rw',
	isa => 'Str'
);

has 'start' => (
	is  => 'rw',
	isa => 'Int'
);

has 'end' => (
	is  => 'rw',
	isa => 'Int'
);

has 'strand' => (
	is  => 'rw',
	isa => 'Str',
	default => '+'
);
1;
