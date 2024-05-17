package Feature;
use Moose;
use Location;
use Data::Dumper;

has 'id' => (
	is  => 'rw',
	isa => 'Str'
);

has 'chrom' => (
	is  => 'rw',
	isa => 'Str'
);

has 'name' => (
	is      => 'rw',
	isa     => 'Str',
	default => ' '
);

has 'parent' => (
	is      => 'rw',
	default => 'NA'
);

has 'type' => (
	is      => 'rw',
	isa     => 'Str',
	default => 'mRNA'
);

has 'children' => (
	is      => 'rw',
	isa     => 'ArrayRef',
	default => sub { [] }
);

has 'locations' => (
	is  => 'rw',
	isa => 'ArrayRef',
);

has 'start' => (
	is      => 'rw',
	isa     => 'Int',
	default => '9999999999'
);

has 'end' => (
	is      => 'rw',
	isa     => 'Int',
	default => '0'
);

has 'strand' => (
	is      => 'rw',
	isa     => 'Str',
	default => '+'
);

sub print() {
	my ( $this, $fh ) = @_;
	my @rowArray;
	push( @rowArray, $this->chrom );
	push( @rowArray, "." );
	push( @rowArray, $this->type );
	push( @rowArray, $this->start );
	push( @rowArray, $this->end );
	push( @rowArray, "." );
	push( @rowArray, $this->strand );
	push( @rowArray, "." );

	if (   $this->type eq 'cds'
		or $this->type eq 'exon'
		or $this->type eq 'reagent'
		or $this->type eq 'amplicon' )
	{
		push( @rowArray, "Parent=" . $this->parent );
	}
	else {
			push( @rowArray, "ID=" . $this->id . ";Name=" . $this->name);
	}
	local $, = "\t";
	if (@rowArray) {
		if($this->type ne 'CDS'){
			print $fh @rowArray, "\n";
		}
	}
	else {
		print "undefined\t", this->id(), "\n";
	}
	for my $child ( @{ $this->children() } ) {
		$child->print($fh);
	}
}

sub fastaToFeature() {
	my ( $this, $fastaHeader ) = @_;
	my @annotations = split( /;\s?/, $fastaHeader );
	my $locationCount = 0;
	$this->locations( [] );
	$this->children(  [] );
	my @locAnnotations;
	foreach my $annotation (@annotations) {
		if ( $annotation =~ /parent=(.*)/ ) {
			my @parents = split( /,/, $1 );
			$this->parent( $parents[-1] );
		}
		elsif ( $annotation =~ /type=(\w+)/ ) {
			$this->type($1);
		}
		elsif ( $annotation =~ /name=([-\w()]+)/ ) {
			$this->name($1);
		}
		elsif ( $annotation =~ /loc=(\w+):(.*)/ ) {
			my $chromosome = $1;
			$this->chrom($chromosome);
			my $locationString = $2;
			my $strand         = '+';
			if ( $locationString =~ /(join|complement)\((.*)\)/ ) {
				my $strandType       = $1;
				my $locStringNumbers = $2;
				if ( $strandType eq 'complement' ) {
					$strand = '-';
					if ( $this->type() eq 'gene' ) {
						$this->strand('-');
					}
				}

		   #Save location numbers until the rest of the required fields have been parsed from header
				push(
					@locAnnotations,
					{
						chrom     => $chromosome,
						locString => $locStringNumbers,
						strand    => $strand
					}
				);
			}
			elsif ( $locationString =~ /(\d+?)\.\.(\d+)/ ) {
				push(
					@locAnnotations,
					{
						chrom     => $chromosome,
						locString => $locationString,
						strand    => $strand
					}
				);
			}
			else {
				print "Unexpected format of $locationString ", $locationString, "\n";
			}
		}
		else {
		}
	}
	for my $locAnnotation (@locAnnotations) {

		#print Dumper($locAnnotation), "\n";
		my ( $start, $end ) = processLocationNumbers(
			$this,
			$locAnnotation->{locString},
			$locAnnotation->{chrom},
			$locAnnotation->{strand}
		);
		$this->start($start);
		$this->end($end);
	}
}
1;

sub processLocationNumbers {
	my ( $this, $locationNumbers, $chromosome, $strand ) = @_;
	my @locations;
	my $start = 9999999999;
	my $end   = 0;
	while ( $locationNumbers =~ /(\d+?)\.\.(\d+)/g ) {
		if ( $2 > $end ) {
			$end = $2;
		}
		if ( $1 < $start ) {
			$start = $1;
		}
		my $childType = '';
		my $parent    = '';
		if ( $this->type() eq 'gene' ) {
			$childType = 'Gene';
			$parent    = '';
		}
		elsif ( $this->type() eq 'mRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'ncRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'miRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'tRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'pre_miRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'snoRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'rRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'miscRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'snRNA' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'pseudogene' ) {
			$childType = 'exon';
			$parent    = $this->id();
		}
		elsif ( $this->type() eq 'CDS' ) {
			$childType = 'cds';
			$parent    = $this->parent();
		}
		else {
			print "unexpected type ", $this->type(), "\n";
		}
		if ( $childType eq 'cds' or $childType eq 'exon' ) {

			my $child = Feature->new( id => $childType );
			$child->start($1);
			$child->end($2);
			$child->chrom( $this->chrom() );
			$child->strand( $this->strand() );
			$child->parent($parent);
			$child->type($childType);
			push( @{ $this->children() }, $child );
		}
	}
	return ( $start, $end );
}
