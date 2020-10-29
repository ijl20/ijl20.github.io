# Ucampas template for University of Cambridge 2012 "Project Light" house style
use 5.016;
ucampas->VERSION("1.003"); # check minimally required API version

my %theme =
    (
     blue      => 1,
     turquoise => 2,
     purple    => 3,
     green     => 4,
     orange    => 5,
     red       => 6,    );

# auxiliary function to prepare a
# <li><a href="$cur->rurl($c)">$c->navtitle</a>
# link to node $c
sub linkitem {
    my ($cur, $c) = @_;
    my $title = $c->navtitle;
    $title .= ' ➥' if $c->str_meta eq 'link';
    my $h = text($title);
    if ($cur->nid != $c->nid) {
        my $url = $c->rurl($cur);
        $h = c('*a')
            ->addkey('href', text($url))
            ->append($h) if defined $url;
    }
    $h = c('*li')->append($h);
    return $h;
}

# remove spurious whitespace strings between the
# children of a block-level elements (e.g., <div>)
sub clean_whitespace {
    my ($el) = @_;
    if ($el->tag == META && $el->str =~ /^body|div|ul\z/) {
        for my $c ($el->list) {
            if ($c->tag == TEXT) {
                $c->cut if $c->str =~ /^\s*$/;
            } else {
                clean_whitespace($c);
            }
        }
    }
}

# this file feeds a hash table of parameters associated with the template
{
    'style_url'  => 'https://www.cl.cam.ac.uk/style/ucam2012/',

    # adjust template for this page
    'adjust' => sub {
        my ($t, $out, $cur, $src) = @_;

        # clean up template body
        my $outbody = $out->cd('.l(*html)', '.l(*body)')
            or die('No <body> found in template!\n');
        clean_whitespace($outbody);

	# breadcrumb + section title container
	my $bc = $t->{id}{'breadcrumb'}->up;
	# horizontal breadcrumbs
	my $breadcrumbs =
	    breadcrumbs($cur, ul => 1, firstclass => 'first-child',
			includecur => 1,
			class => 'campl-unstyled-list campl-horizontal-navigation clearfix');
	if ($breadcrumbs && $breadcrumbs->listlen) {
	    # fix-up first and last list item
	    my $li = $breadcrumbs->cl(0);
	    add_class($li->cl(0), 'campl-home', 'ir');
	    my $li = $breadcrumbs->cl($breadcrumbs->listlen-1);
	    my $current = $li->cl(0);
	    $current->setstr('p'); # change <a> to <p>
	    $current->deletekey(text 'href');
	    add_class($current, 'campl-current');

	    $t->{id}{'breadcrumb'}->append($breadcrumbs);
	} else {
	    $t->{id}{'breadcrumb'}->cut();
	}
	# page title
	my $title = $cur->param('organization');
	$bc->append(c('*p(class="campl-page-title campl-sub-section-title")')
		    ->append(text $title));
	# up link for mobile version
	my $up = $cur->up;
	if ($up) {
	    $bc->append(c('*p(class="campl-mobile-parent")')
			->append(c('*a')->setatt(href => $up->rurl($cur))
				 ->append(
				     c('*span(class="campl-back-btn campl-menu-indicator")'),
				     text $up->navtitle)
	));
	}

	# horizontal navigation tabs
        if ($cur->param('menubar') // 1) {
            my $hnav = navbar($cur, undef, domain => 'menu', div => 0,
                              touchtext => 'Overview',
                              topopen => 3, forwardopen => 3, stoplength => 20,
                              class=>"campl-unstyled-list local-dropdown-menu",
                              markonpath =>
                              sub { add_class($_[2], 'campl-selected') },
                              markcurrent =>
                              sub { add_class($_[0], 'campl-active-page') }
                );
            if ($hnav) {
                for my $ul ($hnav->list) {
                    # first level is no local-dropdown-menu
                    $ul->setatt(class => "campl-unstyled-list")
                };
                $t->{id}->{'local-nav'}->append(
                    c('*div(class="campl-local-navigation-container")')
                    ->append($hnav));
            }
        }

        # main columns
	my $content = $t->{id}{'content'};
        my $wrap = $content->up;

        my $main_columns = 9;
        if ($cur->param('navbar')) {
            # left-hand navigation bar (campl-tertiary-navigation-structure)
            my $nav = $wrap->cl(0, 0, 0);
            # vertical breadcrumb
            my @path = $cur->path;
            my $cat = pop @path; # "category page" = non-leaf node
            $cat = pop @path if @path && !$cat->listlen;
            my $bc = c('*ul(class="campl-unstyled-list campl-vertical-breadcrumb")');
            my @bc;
            my $bcind = c('*span(class="campl-vertical-breadcrumb-indicator")');
            for my $c (@path) {
                my $crumb = linkitem($cur, $c);
                $crumb->append($bcind);
                push @bc, $crumb;
            }
            $nav->append($bc->append(@bc)) if @bc;
            # split visible siblings of current "category" node into
            # predecessors and successors
            my @pred;
            my @succ;
            if ($cat->depth) {
                @succ = _visiblelist($cur, $cat->parent);
                while (@succ && $succ[0]->nid != $cat->nid) {
                    push @pred, splice(@succ, 0, 1);
                }
                shift @succ; # remove $cat
            }
            # list predecessors after current "category" node
            # (this reordering of siblings is implemented as a
            # separate step here so we can later skip it as an option)
            unshift @succ, splice(@pred);
            # current "category" node
            my $bcn = c('*ul(class="campl-unstyled-list campl-vertical-breadcrumb-navigation")');
            my $crumb = linkitem($cur, $cat)->setatt(class => 'campl-selected');
            # child nodes
            $crumb->append(
                navbar($cur, $cat, topopen=>1, forwardopen=>1,
                       class => 'campl-unstyled-list campl-vertical-breadcrumb-children',
                       marklink => sub { $_[2]->append(text ' ➥') }
                ));
            $bcn->append($crumb); # append <li> for current "category" node
            $bcn->append(map { linkitem($cur, $_) } @succ); # append <li>s for remaining siblings
            $nav->append($bcn);
        } else {
            # remove left-hand navigation bar
            $wrap->splice(0, 1); # delete <div class="campl-column3">...</div>
            $main_columns += 3;
        }
        $content->setatt(class=>"campl-column$main_columns campl-main-content");

        # source body
        my $body = $src->cd('.l(*html)', '.l(*body)')
            or die('No <body> found!\n');
	my @bodyclasses = split(/\s+/, $body->get('class') || '');
	# destination body
	add_class($outbody, @bodyclasses);
	# transfer body content
	$content->append(c('*div(class="campl-content-container")')
			 ->movelist($body));

        # apply colour theme
        my $theme = $theme{$cur->style_param('colours')};
        add_class($outbody, "campl-theme-$theme") if $theme;

        # sub-title
        my $subtitle = $t->{id}{'sub-title'};
        my $title;
        $title = $cur->param('section');
        $title = $cur->title unless defined $title;
        $subtitle->append(text $title);
        # adjust column of subtitle
        my $subtitle_column = $subtitle->up(2);
        $subtitle_column->setatt('class', "campl-column$main_columns");
        $subtitle_column->prev->cut unless $cur->param('navbar');
        #$subtitle_column->prev->setatt('class', "campl-column" .
        #                               (12-$main_columns) . " campl-spacing-column");

        # local and global footers
        my $localfooter = $t->{id}{'local-footer'};
        my $globalfooter = $localfooter->next;
        while ($globalfooter->tag == TEXT) { $globalfooter = $globalfooter->next; } # skip space

        # local footer
        my $footer = c(<<'EOT');
(
 ((*h3(*a(href='', 'About the Faculty')),
   *ul(*li(*a(href='', 'Lorem ipsum dolor')),
       *li(*a(href='', 'Sit amet'))),
   *h3(*a(href='', 'Research')),
   *ul(*li(*a(href='', 'Ut labore et dolore')),
      *li(*a(href='', 'Ut enim ad minim veniam')))
 )),
 ((*h3(*a(href='', 'About the University')),
   *ul(*li(*a(href='', 'Lorem ipsum dolor')),
       *li(*a(href='', 'Sit amet')))),
  (*h3(*a(href='', 'Libraries and facilities')),
   *ul(*li(*a(href='', 'Ut labore et dolore')),
       *li(*a(href='', 'Ut enim ad minim veniam'))))
 ),
 ((*h3(*a(href='', 'Graduate')),
   *ul(*li(*a(href='', 'Lorem ipsum dolor')),
       *li(*a(href='', 'Sit amet')))),
 ),
 ((*h3(*a(href='', 'Subjects')),
   *ul(*li(*a(href='', 'Lorem ipsum dolor')),
       *li(*a(href='', 'Sit amet')))),
 ),
)
EOT

        # prepare a standard ucampas footer
        my $ucampas_footer = c(<<'EOT');
*div(class='campl-wrap clearfix',
     *div(class='campl-column12',
          *div(class='campl-side-padding',
               *img(alt="University of Cambridge", class="campl-scale-with-grid",
               style="padding-bottom: 20px"),
              )
         )
    )
EOT
        my @footer = ( page_copyright($cur, "University of Cambridge"),
                       page_contact($cur, "Information provided by "),
                       page_access($cur)
        );
        @footer = interleave(meta 'br', grep { $_ } @footer);
        my $container = $ucampas_footer->cl(0, 0);
        my $logo = $container->cl(0);
        if ($cur->param('global_footer') eq '0') {
            # keep and configure University logo
            $logo->setatt('src', prefix_url($t->{images_url}, 'img/main-logo-small.png'));
        } else {
            # remove duplicate logo (there will be already follow one in the global footer below)
            $logo->cut;
        }
        $container->append(c('*p(style="margin:0")')->append(@footer));
        $localfooter->splice(0);
        $localfooter->append($ucampas_footer);

        #earlier attempt to format lists of links
        if (0 && $footer && $footer->listlen) {
            $localfooter->splice(0);
            my $w = $localfooter->append0()
                ->move(c('*div(class="campl-wrap clearfix")'));
            my $columns = $footer->listlen;
            my $gridcolumns = int(12/$columns);
            die("number of footer columns ($columns) does not divide 12\n")
                unless $columns * $gridcolumns == 12;
            # a footer is structured into multiple columns,
            # each of which can contain have multiple containers
            # (sections that might start with an <h3>)
            for my $column ($footer->list) {
                $column->settstr(META, 'div');
                $column->setatt(class => "campl-column$gridcolumns campl-footer-navigation");
                for my $container ($column->list) {
                    $container->settstr(META, 'div');
                    add_class($container, 'campl-content-container'); # 20px padding
                    add_class($container, 'campl-navigation-list');   # except on top
                }
            }
            $w->append($footer->list);
            add_class($w->cl(-1), 'last');
            #say $localfooter->print;
        } else {
#            $localfooter->cut;
        }

        # global footer
        $globalfooter->cut if $cur->param('global_footer') eq '0';
        my $copyright = $t->{id}->{'ucam2012-global-copyright'};
        if ($copyright) {
            # remove global copyright (in favour of configurable one in local footer)
            $copyright->cut;
        }
    }
}
