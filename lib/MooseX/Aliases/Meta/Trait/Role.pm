package MooseX::Aliases::Meta::Trait::Role;
use Moose::Role;

sub composition_class_roles { 'MooseX::Aliases::Meta::Trait::Role::Composite' }

no Moose::Role;

=pod

=begin Pod::Coverage

composition_class_roles

=end Pod::Coverage

=cut

1;
