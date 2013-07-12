package MooseX::Aliases::Meta::Trait::Role::ApplicationToRole;
use Moose::Role;

around apply => sub {
    my $orig  = shift;
    my $self  = shift;
    my ($role1, $role2) = @_;

    $role2 = Moose::Util::MetaRole::apply_metaroles(
        for             => $role2,
        role_metaroles => {
            application_to_class => [
                'MooseX::Aliases::Meta::Trait::Role::ApplicationToClass',
            ],
            application_to_role => [
                'MooseX::Aliases::Meta::Trait::Role::ApplicationToRole',
            ],
        }
    );

    $self->$orig( $role1, $role2 );
};

no Moose::Role;

=for Pod::Coverage

=cut

1;
