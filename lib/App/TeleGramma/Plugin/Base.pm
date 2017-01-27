package App::TeleGramma::Plugin::Base;

use Mojo::Base -base;

use App::TeleGramma::Constants qw/:const/;

has 'app_config';
has 'app';


sub short_name {
  my $self = shift;
  my $package = ref($self);
  $package =~ s/^App::TeleGramma::Plugin:://;
  $package =~ s/::/-/g;

  return "plugin-" . $package;
}

# override: optional
sub default_config { {} }

# override: optional
sub check_prereqs {
  1;
}

# override: optional but HIGHLY RECOMMENDED
sub synopsis {
  "My author did not provide a synopsis!";
}

# override: REQUIRED
sub register {
  my $self = shift;
  die ref($self) .  " did not supply a register method\n";
}

sub create_default_config_if_necessary {
  my $self = shift;
  my $section = $self->short_name();

  $self->app_config->read();

  if (! %{ $self->read_config }) {
    $self->app_config->config->{$section} = $self->default_config;
    $self->app_config->config->{$section}->{enable} = 'no';
    $self->app_config->write();
  }
}

sub read_config {
  my $self = shift;
  my $section = $self->short_name();
  $self->app_config->read();
  return $self->app_config->config->{$section} || {};
}

sub reply_to {
  my $self  = shift;
  my $msg   = shift;
  my $reply = shift;

  my $app = $self->app;

  $app->send_message_to_chat_id($msg->chat->id, $reply);
}

1;
