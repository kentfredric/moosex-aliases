package Moose::Exception::Aliases::AliasedMethodMissing;

# ABSTRACT: A specified method to create an alias for does not exist

use Moose;
extends 'Moose::Exception';

has 'original_method' => (
    is       => 'ro',
    isa      => 'Any',
    required => 1,
);

sub _build_message {
    my ($self) = @_;
    return sprintf 'Cannot find method %s to alias', $self->original_method;
}

1;
