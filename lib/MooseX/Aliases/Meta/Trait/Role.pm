package MooseX::Aliases::Meta::Trait::Role;
use Moose::Role;

sub composition_class_roles { 'MooseX::Aliases::Meta::Trait::Role::Composite' }

no Moose::Role;

1;
