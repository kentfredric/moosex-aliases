package Moose::Exception::Aliases::InitArgConflict;

# ABSTRACT: Too many aliases for C<init_args>

use Moose;
extends 'Moose::Exception';

has 'init_arg_aliases' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

sub _build_message {
    my ($self) = @_;
    return sprintf 'Conflicting init_args: (%s)',
      ( join q{, }, @{ $self->init_arg_aliases } );
}

1;
