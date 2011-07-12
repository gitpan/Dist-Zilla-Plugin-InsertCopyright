use 5.008001;
use strict;
use warnings;
use utf8;

package Dist::Zilla::Plugin::InsertCopyright;
BEGIN {
  $Dist::Zilla::Plugin::InsertCopyright::VERSION = '0.001';
}
# ABSTRACT: Insert copyright statement into source code files

use PPI::Document;
use Moose;

with 'Dist::Zilla::Role::FileMunger';

# -- public methods

sub munge_file {
    my ($self, $file) = @_;

    return $self->_munge_perl($file) if $file->name    =~ /\.(?:pm|pl|t)$/i;
    return $self->_munge_perl($file) if $file->content =~ /^#!(?:.*)perl(?:$|\s)/;
    return;
}

# -- private methods

#
# $self->_munge_perl($file);
#
# munge content of perl $file: add stuff at a #COPYRIGHT comment
#

sub _munge_perl {
  my ($self, $file) = @_;

  my @copyright = (
    '',
    "This file is part of " . $self->zilla->name,
    '',
    split(/\n/, $self->zilla->license->notice),
    '',
  );

  my @copyright_comment = map { length($_) ? "# $_" : '#' } @copyright;

  my $content = $file->content;

  my $doc = PPI::Document->new(\$content)
    or croak( PPI::Document->errstr );

  my $comments = $doc->find('PPI::Token::Comment');

  if ( ref($comments) eq 'ARRAY' ) {
    foreach my $c ( @{ $comments } ) {
      if ( $c =~ /^(\s*)(\#\s+COPYRIGHT\b)$/xms ) {
        my ( $ws, $comment ) =  ( $1, $2 );
        my $code = join( "\n", map { "$ws$_" } @copyright_comment );
        $c->set_content("$code\n");
        $self->log_debug("Added copyright to " . $file->name);
        last;
      }
    }
    $file->content( $doc->serialize );
  }

  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

#
# This file is part of Dist-Zilla-Plugin-InsertCopyright
#
# This software is Copyright (c) 2011 by David Golden.
#
# This is free software, licensed under:
#
#   The Apache License, Version 2.0, January 2004
#



=pod

=head1 NAME

Dist::Zilla::Plugin::InsertCopyright - Insert copyright statement into source code files

=head1 VERSION

version 0.001

=head1 SYNOPSIS

In your F<dist.ini>:

    [InsertCopyright]

In your source files (before C<__END__>):

  # COPYRIGHT

=head1 DESCRIPTION

This module replaces a special C<# COPYRIGHT> comment in your Perl source
files with a short notice appropriate to your declared copyright.  The
special comment B<must> be placed before C<__END__>.  Only the first such
comment will be replaced.

It is inspired by excellent L<Dist::Zilla::Plugin::Prepender> but gives control
of the copyright notice placement instead of always adding it at the start of a
file.

I wrote this to let me put copyright statements at the end of my code to keep
line numbers of code consistent between the generated distribution and the
repository source.  See L<Dist::Zilla::Plugin::OurPkgVersion> for another
useful plugin that preserves line numbering.

=encoding utf8

=for Pod::Coverage munge_file

=head1 ACKNOWLEDGMENTS

Code in this module is based heavily on Dist::Zilla::Plugin::OurPkgVersion
by Caleb Cushing and Dist::Zilla::Plugin::Prepender by Jérôme Quelin.  Thank
you to both of them for their work and for releasing it as open source for
reuse.

=head1 SEE ALSO

=over 4

=item *

L<Dist::Zilla> and L<dzil.org|http://dzil.org/>

=item *

L<Dist::Zilla::Plugin::OurPkgVersion>

=item *

L<Dist::Zilla::Plugin::Prepender>

=back

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-dist-zilla-plugin-insertcopyright at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-InsertCopyright>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<http://github.com/dagolden/dist-zilla-plugin-insertcopyright>

  git clone http://github.com/dagolden/dist-zilla-plugin-insertcopyright

=head1 AUTHOR

David Golden <dagolden@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2011 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut


__END__


